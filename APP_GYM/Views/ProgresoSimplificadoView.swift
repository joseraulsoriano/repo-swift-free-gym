//
//  ProgresoSimplificadoView.swift
//  APP_GYM
//
//  Vista simplificada de progreso - lista de ejercicios con acceso rápido
//

import SwiftUI

struct ProgresoSimplificadoView: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    var uniqueExercises: [String] {
        var seen = [String: Bool]()
        let allExercises = sessionRepo.items.flatMap { session in
            session.performedExercises.map { $0.exerciseName }
        }
        return allExercises.filter { seen.updateValue(true, forKey: $0) == nil }.sorted()
    }
    
    var filteredExercises: [String] {
        if searchText.isEmpty {
            return uniqueExercises
        }
        return uniqueExercises.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if uniqueExercises.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar.doc.horizontal",
                            title: "Sin ejercicios registrados",
                            message: "Comienza a entrenar para ver tu progreso"
                        )
                } else {
                    List {
                        ForEach(filteredExercises, id: \.self) { exerciseName in
                            NavigationLink(destination: ExerciseProgressView(exerciseName: exerciseName)) {
                                ExerciseListItem(exerciseName: exerciseName)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Buscar ejercicio")
                    .pullToRefresh(isRefreshing: $isRefreshing) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isRefreshing = false
                            notificationManager.info("Progreso actualizado")
                        }
                    }
                }
            }
            .navigationTitle("Progreso")
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
}

struct ExerciseListItem: View {
    let exerciseName: String
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    private let analysisService = ProgressAnalysisService()
    
    var analysis: ProgressAnalysis {
        analysisService.analyzeProgress(for: exerciseName)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseName)
                    .font(.headline)
                
                if let pr = analysis.lastPR {
                    HStack {
                        BadgeView("PR: \(String(format: "%.1f", pr.value)) kg", color: .green)
                    }
                } else {
                    Text("Sin PR registrado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Indicador de tendencia
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: trendIcon)
                    .foregroundColor(trendColor)
                    .font(.title3)
                
                if analysis.isStagnant {
                    BadgeView("Estancado", color: .orange)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var trendIcon: String {
        switch analysis.trend {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    var trendColor: Color {
        switch analysis.trend {
        case .improving: return .green
        case .stable: return .gray
        case .declining: return .red
        }
    }
}


#Preview {
    ProgresoSimplificadoView()
        .environmentObject(ErrorHandler())
        .environmentObject(NotificationManager())
}

