//
//  GoalsView.swift
//  APP_GYM
//
//  Vista de objetivos claros y medibles
//

import SwiftUI
import Charts

struct GoalsView: View {
    @StateObject private var goalRepo = GoalRepository.shared
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingAddGoal = false
    @State private var isRefreshing = false
    
    var activeGoals: [FitnessGoal] {
        goalRepo.getActiveGoals()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if activeGoals.isEmpty {
                        EmptyStateView(
                            icon: "target",
                            title: "Sin objetivos definidos",
                            message: "Define 1-3 objetivos claros para medir tu progreso",
                            actionTitle: "Crear Objetivo",
                            action: {
                                showingAddGoal = true
                            }
                        )
                    } else {
                        ForEach(activeGoals) { goal in
                            GoalCardView(
                                goal: goal,
                                currentValue: getCurrentValue(for: goal)
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Objetivos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FloatingActionButton(icon: "plus") {
                        showingAddGoal = true
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .pullToRefresh(isRefreshing: $isRefreshing) {
                // Refrescar datos
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isRefreshing = false
                    notificationManager.info("Objetivos actualizados")
                }
            }
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
    
    private func getCurrentValue(for goal: FitnessGoal) -> Double {
        switch goal.type {
        case .strength:
            // Buscar PR del ejercicio
            if let exerciseName = goal.exerciseName {
                let analysisService = ProgressAnalysisService()
                let prs = analysisService.getPersonalRecords(for: exerciseName)
                if let maxWeightPR = prs.first(where: { $0.recordType == .maxWeight }) {
                    return maxWeightPR.value
                }
            }
            return goal.startValue
            
        case .weight:
            // Último peso corporal registrado
            let metricRepo = BodyMetricRepository.shared
            if let latestWeight = metricRepo.getLatestMetric(.weight) {
                return latestWeight.value ?? goal.startValue
            }
            return goal.startValue
            
        case .mass, .habit:
            // Para masa y hábito, calcular desde sesiones
            let calendar = Calendar.current
            let startDate = goal.startDate
            let now = Date()
            
            if goal.type == .habit {
                // Sesiones por semana
                let sessions = sessionRepo.getSessionsInDateRange(from: startDate, to: now)
                let weeks = calendar.dateComponents([.weekOfYear], from: startDate, to: now).weekOfYear ?? 1
                return Double(sessions.count) / Double(max(weeks, 1))
            }
            
            return goal.startValue
        }
    }
}

struct GoalCardView: View {
    let goal: FitnessGoal
    let currentValue: Double
    
    var progress: Double {
        let range = goal.targetValue - goal.startValue
        guard range != 0 else { return 0 }
        let currentProgress = currentValue - goal.startValue
        return min(max((currentProgress / range) * 100, 0), 100)
    }
    
    var daysRemaining: Int {
        goal.daysRemaining
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goalTypeLabel(goal.type))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    if let exerciseName = goal.exerciseName {
                        Text(exerciseName)
                            .font(.headline)
                    } else {
                        Text(goalTypeTitle(goal.type))
                            .font(.headline)
                    }
                }
                Spacer()
                BadgeView("\(daysRemaining) días", color: .blue)
            }
            
            // Progreso visual con anillo
            HStack(spacing: 20) {
                ZStack {
                    ProgressRing(progress: progress / 100, lineWidth: 12, color: progressColor)
                        .frame(width: 80, height: 80)
                    
                    Text("\(Int(progress))%")
                        .font(.headline)
                        .bold()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(String(format: "%.1f", currentValue)) \(goal.metric.rawValue)")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Text("→ \(String(format: "%.1f", goal.targetValue))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Indicador de progreso
                    HStack {
                        if progress >= 100 {
                            Label("¡Objetivo alcanzado!", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        } else if progress > 75 {
                            Label("Muy cerca", systemImage: "arrow.up.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        } else if progress > 50 {
                            Label("A mitad de camino", systemImage: "arrow.right.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        } else {
                            Label("En progreso", systemImage: "arrow.down.circle.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    var progressColor: Color {
        if progress >= 100 {
            return .green
        } else if progress > 75 {
            return .blue
        } else if progress > 50 {
            return .orange
        } else {
            return .gray
        }
    }
    
    private func goalTypeLabel(_ type: GoalType) -> String {
        switch type {
        case .strength: return "FUERZA"
        case .mass: return "MASA"
        case .weight: return "PESO"
        case .habit: return "HÁBITO"
        }
    }
    
    private func goalTypeTitle(_ type: GoalType) -> String {
        switch type {
        case .strength: return "Aumentar Fuerza"
        case .mass: return "Ganar Masa"
        case .weight: return "Peso Corporal"
        case .habit: return "Consistencia"
        }
    }
}


struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var goalRepo = GoalRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    
    @State private var selectedType: GoalType = .strength
    @State private var exerciseName: String = ""
    @State private var startValue: String = ""
    @State private var targetValue: String = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado naranja tenue
                Group {
                    if colorScheme == .dark {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.12),
                                Color(red: 0.08, green: 0.08, blue: 0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.95, blue: 0.9),
                                Color(red: 1.0, green: 0.9, blue: 0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tipo de Objetivo
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Tipo de Objetivo")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            Picker("", selection: $selectedType) {
                                Text("Fuerza").tag(GoalType.strength)
                                Text("Masa").tag(GoalType.mass)
                                Text("Peso Corporal").tag(GoalType.weight)
                                Text("Consistencia").tag(GoalType.habit)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Ejercicio (si es fuerza)
                        if selectedType == .strength {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Ejercicio")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                                
                                TextField("Ej: Press Banca", text: $exerciseName)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                    )
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                        }
                        
                        // Valores
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Valores")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Valor Inicial")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.0", text: $startValue)
                                        #if os(iOS)
                                        .keyboardType(.decimalPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Valor Objetivo")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0.0", text: $targetValue)
                                        #if os(iOS)
                                        .keyboardType(.decimalPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Fecha Objetivo
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Fecha Objetivo")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Botón Guardar
                        Button(action: {
                            saveGoal()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Guardar Objetivo")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.35),
                                        Color(red: 1.0, green: 0.55, blue: 0.25)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1.0 : 0.6)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nuevo Objetivo")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let start = Double(startValue),
              let target = Double(targetValue) else {
            return false
        }
        
        if selectedType == .strength {
            return !exerciseName.isEmpty
        }
        
        return true
    }
    
    private func saveGoal() {
        guard let start = Double(startValue),
              let target = Double(targetValue) else {
            errorHandler.show(.invalidData("Valores inválidos"))
            return
        }
        
        if selectedType == .strength && exerciseName.isEmpty {
            errorHandler.show(.invalidData("Debes ingresar un nombre de ejercicio"))
            return
        }
        
        let goal = FitnessGoal(
            userId: UUID(), // TODO: Obtener del usuario actual
            type: selectedType,
            metric: selectedType == .strength ? .kilograms : .kilograms,
            exerciseName: selectedType == .strength ? exerciseName : nil,
            startValue: start,
            targetValue: target,
            targetDate: targetDate
        )
        
        goalRepo.save(goal)
        notificationManager.success("Objetivo creado", message: "¡Comienza a trabajar hacia tu meta!")
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    GoalsView()
}

