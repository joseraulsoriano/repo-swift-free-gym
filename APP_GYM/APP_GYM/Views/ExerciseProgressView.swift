//
//  ExerciseProgressView.swift
//  APP_GYM
//
//  Vista de progreso por ejercicio con PRs y detección de estancamiento
//

import SwiftUI
import Charts

struct ExerciseProgressView: View {
    let exerciseName: String
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var analysis: ProgressAnalysis?
    @State private var isLoading = false
    
    private let analysisService = ProgressAnalysisService()
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView("Analizando progreso...")
            } else if let analysis = analysis {
                ScrollView {
                    VStack(spacing: 20) {
                        // Análisis de progreso
                        ProgressAnalysisCard(analysis: analysis)
                        
                        // PRs
                        PersonalRecordsCard(exerciseName: exerciseName)
                        
                        // Gráfico de progreso
                        ProgressChartCard(exerciseName: exerciseName)
                        
                        // Historial reciente
                        RecentSessionsCard(exerciseName: exerciseName)
                    }
                    .padding()
                }
            } else {
                EmptyStateView(
                    icon: "chart.bar",
                    title: "Sin datos",
                    message: "No hay suficiente información para analizar",
                    actionTitle: nil,
                    action: nil
                )
            }
        }
        .navigationTitle(exerciseName)
        .onAppear {
            loadAnalysis()
        }
        .errorHandling(errorHandler)
        .notifications(notificationManager)
    }
    
    private func loadAnalysis() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            analysis = analysisService.analyzeProgress(for: exerciseName)
            isLoading = false
        }
    }
}

struct ProgressAnalysisCard: View {
    let analysis: ProgressAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader("Análisis de Progreso")
            
            HStack {
                StatCard(
                    title: "Tendencia",
                    value: trendText,
                    icon: trendIcon,
                    color: trendColorValue
                )
                
                if let pr = analysis.lastPR {
                    StatCard(
                        title: "PR Actual",
                        value: String(format: "%.1f kg", pr.value),
                        icon: "trophy.fill",
                        color: .green
                    )
                }
            }
            
            if analysis.isStagnant {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Estancado \(analysis.weeksStagnant ?? 0) semanas")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let recommendation = analysis.recommendation {
                Text(recommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .cardStyle()
    }
    
    var trendIcon: String {
        analysis.trendIcon
    }
    
    var trendColorValue: Color {
        switch analysis.trend {
        case .improving: return .green
        case .stable: return .gray
        case .declining: return .red
        }
    }
    
    var trendText: String {
        switch analysis.trend {
        case .improving: return "Mejorando"
        case .stable: return "Estable"
        case .declining: return "Bajando"
        }
    }
}

struct PersonalRecordsCard: View {
    let exerciseName: String
    private let analysisService = ProgressAnalysisService()
    
    var prs: [PersonalRecord] {
        analysisService.getPersonalRecords(for: exerciseName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader("Récords Personales")
            
            if prs.isEmpty {
                Text("Aún no hay récords registrados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(prs) { pr in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pr.typeDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Text(pr.formattedValue)
                                .font(.headline)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(pr.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            BadgeView("PR", color: .green)
                        }
                    }
                    .padding(.vertical, 8)
                    .cardStyle()
                }
            }
        }
        .cardStyle()
    }
    
}

struct ProgressChartCard: View {
    let exerciseName: String
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    
    var chartData: [ChartDataPoint] {
        let sessions = sessionRepo.getSessionsForExercise(exerciseName)
        let exercises = sessions.flatMap { session in
            session.performedExercises.filter { $0.exerciseName == exerciseName }
        }
        
        return exercises.enumerated().map { index, exercise in
            let session = sessions.first { $0.performedExercises.contains { $0.id == exercise.id } }
            return ChartDataPoint(
                date: session?.date ?? Date(),
                value: exercise.maxWeight,
                volume: exercise.totalVolume
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader("Evolución del Peso")
            
            if chartData.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Sin datos",
                    message: "No hay datos suficientes para mostrar el gráfico",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                Chart {
                    ForEach(chartData) { point in
                        LineMark(
                            x: .value("Fecha", point.date),
                            y: .value("Peso", point.value)
                        )
                        .foregroundStyle(.blue)
                        
                        PointMark(
                            x: .value("Fecha", point.date),
                            y: .value("Peso", point.value)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200)
            }
        }
        .cardStyle()
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let volume: Double
}

struct RecentSessionsCard: View {
    let exerciseName: String
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    
    var recentSessions: [WorkoutSession] {
        sessionRepo.getSessionsForExercise(exerciseName)
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader("Sesiones Recientes")
            
            if recentSessions.isEmpty {
                Text("No hay sesiones registradas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(recentSessions) { session in
                    if let exercise = session.performedExercises.first(where: { $0.exerciseName == exerciseName }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(session.date, style: .date)
                                    .font(.headline)
                                
                                HStack(spacing: 12) {
                                    BadgeView("Max: \(String(format: "%.1f", exercise.maxWeight))kg", color: .blue)
                                    BadgeView("\(exercise.sets.count) series", color: .green)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .cardStyle()
                    }
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    NavigationView {
        ExerciseProgressView(exerciseName: "Press Banca")
    }
}

