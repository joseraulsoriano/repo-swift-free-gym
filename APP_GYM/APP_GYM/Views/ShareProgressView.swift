//
//  ShareProgressView.swift
//  APP_GYM
//
//  Generación de imágenes para compartir en redes sociales (estilo Strava)
//

import SwiftUI
import Charts
#if os(iOS)
import UIKit
#endif

struct ShareProgressView: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @StateObject private var goalRepo = GoalRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedFormat: ShareFormat = .story
    @State private var selectedExercise: String? = nil
    @State private var showingShareSheet = false
    #if os(iOS)
    @State private var generatedImage: UIImage?
    #else
    @State private var generatedImage: Data?
    #endif
    @State private var isGenerating = false
    
    enum ShareFormat {
        case story      // 1080x1920 (Instagram Stories)
        case post       // 1080x1080 (Instagram Post)
        case wide       // 1200x630 (Facebook/Twitter)
        
        var size: CGSize {
            switch self {
            case .story: return CGSize(width: 1080, height: 1920)
            case .post: return CGSize(width: 1080, height: 1080)
            case .wide: return CGSize(width: 1200, height: 630)
            }
        }
        
        var name: String {
            switch self {
            case .story: return "Historia"
            case .post: return "Post"
            case .wide: return "Ancho"
            }
        }
    }
    
    var uniqueExercises: [String] {
        var seen = [String: Bool]()
        let allExercises = sessionRepo.items.flatMap { session in
            session.performedExercises.map { $0.exerciseName }
        }
        return allExercises.filter { seen.updateValue(true, forKey: $0) == nil }.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Selector de formato
                Picker("Formato", selection: $selectedFormat) {
                    ForEach([ShareFormat.story, .post, .wide], id: \.self) { format in
                        Text(format.name).tag(format)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Selector de ejercicio (opcional)
                if !uniqueExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ejercicio (opcional)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    selectedExercise = nil
                                }) {
                                    Text("Todos")
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(selectedExercise == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedExercise == nil ? .white : .primary)
                                        .cornerRadius(20)
                                }
                                
                                ForEach(uniqueExercises, id: \.self) { exercise in
                                    Button(action: {
                                        selectedExercise = exercise
                                    }) {
                                        Text(exercise)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 8)
                                            .background(selectedExercise == exercise ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedExercise == exercise ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Preview de la imagen
                #if os(iOS)
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                } else {
                    // Vista previa del diseño
                    SharePreviewView(format: selectedFormat, exerciseName: selectedExercise)
                        .frame(height: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                }
                #else
                if generatedImage != nil {
                    Text("Imagen generada")
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                } else {
                    // Vista previa del diseño
                    SharePreviewView(format: selectedFormat, exerciseName: selectedExercise)
                        .frame(height: 400)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                }
                #endif
                
                // Botones de acción
                VStack(spacing: 15) {
                    if isGenerating {
                        LoadingView("Generando imagen...")
                    } else {
                        GradientButton(
                            "Generar Imagen",
                            icon: "photo.fill",
                            gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing),
                            action: {
                                generateImage()
                            }
                        )
                        
                        if generatedImage != nil {
                            GradientButton(
                                "Compartir",
                                icon: "square.and.arrow.up.fill",
                                gradient: LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing),
                                action: {
                                    showingShareSheet = true
                                    notificationManager.info("Listo para compartir")
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Compartir Progreso")
            .sheet(isPresented: $showingShareSheet) {
                #if os(iOS)
                if let image = generatedImage {
                    ActivityViewController(activityItems: [image])
                }
                #endif
            }
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
    
    private func generateImage() {
        isGenerating = true
        DispatchQueue.main.async {
            let view = SharePreviewView(format: selectedFormat, exerciseName: selectedExercise)
                .frame(width: selectedFormat.size.width, height: selectedFormat.size.height)
                .background(Color.clear)
            
            #if os(iOS)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 3.0 // Alta resolución para redes sociales
            
            // En iOS 16+, ImageRenderer tiene uiImage directamente
            if #available(iOS 16.0, *) {
                if let uiImage = renderer.uiImage {
                    self.generatedImage = uiImage
                    notificationManager.success("Imagen generada", message: "Lista para compartir")
                } else {
                    errorHandler.show(GymAppError.repositoryError("No se pudo generar la imagen"))
                }
            } else {
                // Fallback para versiones anteriores
                if let cgImage = renderer.cgImage {
                    self.generatedImage = UIImage(cgImage: cgImage)
                    notificationManager.success("Imagen generada", message: "Lista para compartir")
                } else {
                    errorHandler.show(GymAppError.repositoryError("No se pudo generar la imagen"))
                }
            }
            #else
            errorHandler.show(GymAppError.repositoryError("Generación de imágenes no disponible en esta plataforma"))
            #endif
            isGenerating = false
        }
    }
}

// MARK: - Vista Preview del Compartir
struct SharePreviewView: View {
    let format: ShareProgressView.ShareFormat
    let exerciseName: String?
    
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @StateObject private var goalRepo = GoalRepository.shared
    private let analysisService = ProgressAnalysisService()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo degradado
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: format == .story ? 30 : 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("APP_GYM")
                            .font(.system(size: format == .story ? 40 : 30, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let exerciseName = exerciseName {
                            Text(exerciseName)
                                .font(.system(size: format == .story ? 32 : 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("Mi Progreso")
                                .font(.system(size: format == .story ? 32 : 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, format == .story ? 60 : 40)
                    
                    // Estadísticas principales
                    if let exerciseName = exerciseName {
                        ExerciseStatsView(exerciseName: exerciseName, format: format)
                    } else {
                        OverallStatsView(format: format)
                    }
                    
                    Spacer()
                    
                    // Footer con fecha
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: format == .story ? 24 : 18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, format == .story ? 60 : 40)
                }
            }
        }
    }
}

// MARK: - Estadísticas de Ejercicio Específico
struct ExerciseStatsView: View {
    let exerciseName: String
    let format: ShareProgressView.ShareFormat
    private let analysisService = ProgressAnalysisService()
    
    var analysis: ProgressAnalysis {
        analysisService.analyzeProgress(for: exerciseName)
    }
    
    var prs: [PersonalRecord] {
        analysisService.getPersonalRecords(for: exerciseName)
    }
    
    var sessions: [WorkoutSession] {
        WorkoutSessionRepository.shared.getSessionsForExercise(exerciseName)
    }
    
    var totalVolume: Double {
        let exercises = sessions.flatMap { $0.performedExercises }
            .filter { $0.exerciseName == exerciseName }
        return exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    var body: some View {
        VStack(spacing: format == .story ? 25 : 20) {
            // PR Principal
            if let maxWeightPR = prs.first(where: { $0.recordType == PersonalRecord.PRType.maxWeight }) {
                VStack(spacing: 10) {
                    Text("RÉCORD PERSONAL")
                        .font(.system(size: format == .story ? 20 : 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("\(String(format: "%.1f", maxWeightPR.value)) kg")
                        .font(.system(size: format == .story ? 72 : 56, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Logrado el \(maxWeightPR.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: format == .story ? 16 : 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Estadísticas en grid
            if format == .story {
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        StatBox(
                            title: "Sesiones",
                            value: "\(sessionCount)",
                            format: format
                        )
                        
                        StatBox(
                            title: "Tendencia",
                            value: trendText,
                            format: format
                        )
                    }
                    
                    StatBox(
                        title: "Volumen Total",
                        value: String(format: "%.0f kg", totalVolume),
                        format: format
                    )
                }
            } else {
                HStack(spacing: 20) {
                    StatBox(
                        title: "Sesiones",
                        value: "\(sessionCount)",
                        format: format
                    )
                    
                    StatBox(
                        title: "Tendencia",
                        value: trendText,
                        format: format
                    )
                }
            }
        }
        .padding(.horizontal, format == .story ? 40 : 30)
    }
    
    var sessionCount: Int {
        sessions.count
    }
    
    var trendText: String {
        switch analysis.trend {
        case .improving: return "↑ Mejorando"
        case .stable: return "→ Estable"
        case .declining: return "↓ Bajando"
        }
    }
}

// MARK: - Estadísticas Generales
struct OverallStatsView: View {
    let format: ShareProgressView.ShareFormat
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @StateObject private var goalRepo = GoalRepository.shared
    
    var totalSessions: Int {
        sessionRepo.items.count
    }
    
    var activeGoalsCount: Int {
        goalRepo.getActiveGoals().count
    }
    
    var uniqueExercises: Int {
        var seen = [String: Bool]()
        let allExercises = sessionRepo.items.flatMap { $0.performedExercises.map { $0.exerciseName } }
        let unique = allExercises.filter { seen.updateValue(true, forKey: $0) == nil }
        return unique.count
    }
    
    var totalVolume: Double {
        sessionRepo.items.reduce(0) { $0 + $1.totalVolume }
    }
    
    var body: some View {
        VStack(spacing: format == .story ? 25 : 20) {
            // Total de sesiones
            VStack(spacing: 10) {
                Text("SESIONES TOTALES")
                    .font(.system(size: format == .story ? 20 : 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\(totalSessions)")
                    .font(.system(size: format == .story ? 72 : 56, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Estadísticas adicionales
            if format == .story {
                VStack(spacing: 20) {
                    HStack(spacing: 30) {
                        StatBox(
                            title: "Ejercicios",
                            value: "\(uniqueExercises)",
                            format: format
                        )
                        
                        StatBox(
                            title: "Volumen Total",
                            value: String(format: "%.0f kg", totalVolume),
                            format: format
                        )
                    }
                    
                    if activeGoalsCount > 0 {
                        StatBox(
                            title: "Objetivos Activos",
                            value: "\(activeGoalsCount)",
                            format: format
                        )
                    }
                }
            } else {
                HStack(spacing: 20) {
                    StatBox(
                        title: "Ejercicios",
                        value: "\(uniqueExercises)",
                        format: format
                    )
                    
                    StatBox(
                        title: "Volumen",
                        value: String(format: "%.0f kg", totalVolume),
                        format: format
                    )
                }
            }
        }
        .padding(.horizontal, format == .story ? 40 : 30)
    }
}

// MARK: - Caja de Estadística
struct StatBox: View {
    let title: String
    let value: String
    let format: ShareProgressView.ShareFormat
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: format == .story ? 36 : 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(title.uppercased())
                .font(.system(size: format == .story ? 14 : 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(format == .story ? 20 : 15)
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
    }
}


#Preview {
    ShareProgressView()
        .environmentObject(ErrorHandler())
        .environmentObject(NotificationManager())
}

