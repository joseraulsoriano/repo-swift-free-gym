import SwiftUI
#if os(macOS)
import AppKit
#endif

// Importar componentes y modelos necesarios
// Los componentes están en Components/
// Los modelos y repositorios están en Domain/

struct ContentView: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @StateObject private var goalRepo = GoalRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingSettings = false
    @State private var showingWorkout = false
    @State private var showingNutrition = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vista Principal
            NavigationView {
                ZStack {
                    // Fondo degradado naranja tenue (adaptado a modo oscuro)
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
                            // Racha de entrenamientos (estilo Duolingo)
                            WorkoutStreakView()
                            
                        // Resumen del día
                        DailySummaryCard()
                        
                        // Próximo entrenamiento
                        NextWorkoutCard()
                        
                        // Progreso rápido
                        QuickProgressCard()
                        
                        // Nutrición del día
                        NutritionCard()
                    }
                    .padding()
                    }
                }
                .navigationTitle("Inicio")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingProfile = true }) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                        }
                    }
                }
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(0)
            
            // Vista de Entrenamientos Rápido
            QuickWorkoutView()
                .tabItem {
                    Label("Entrenar", systemImage: "figure.walk")
                }
                .tag(1)
            
            // Vista de Objetivos
            GoalsView()
                .tabItem {
                    Label("Objetivos", systemImage: "target")
                }
                .tag(2)
            
            // Vista de Progreso
            ProgresoSimplificadoView()
                .tabItem {
                    Label("Progreso", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)
            
            // Vista de Nutrición
            NutritionView()
                .tabItem {
                    Label("Nutrición", systemImage: "fork.knife")
                }
                .tag(4)
        }
        .accentColor(Color(red: 1.0, green: 0.55, blue: 0.25))
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .errorHandling(errorHandler)
        .notifications(notificationManager)
    }
}

struct DailySummaryCard: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @Environment(\.colorScheme) var colorScheme
    
    var todaySessions: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return sessionRepo.items.filter { 
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                Text("Resumen del Día")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                HStack(spacing: 12) {
                    // Sesiones
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.6, blue: 1.0),
                                            Color(red: 0.3, green: 0.5, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "figure.walk")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Text("\(todaySessions)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Sesiones")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Objetivos
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.8, blue: 0.5),
                                            Color(red: 0.2, green: 0.7, blue: 0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "target")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Text("\(GoalRepository.shared.getActiveGoals().count)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Objetivos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    
                    // Progreso
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.65, blue: 0.35),
                                            Color(red: 1.0, green: 0.55, blue: 0.25)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Text("Activo")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                        
                        Text("Progreso")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
    }
}

struct NextWorkoutCard: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var routineRepo = RoutineRepository.shared
    @State private var showingQuickWorkout = false
    
    var activeRoutine: Routine? {
        routineRepo.getActiveRoutine()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                Text("Próximo Entrenamiento")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    if let routine = activeRoutine {
                        Text(routine.name)
                            .font(.headline)
                                .foregroundColor(.primary)
                        Text("\(routine.exercises.count) ejercicios")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Nuevo Entrenamiento")
                            .font(.headline)
                                .foregroundColor(.primary)
                        Text("Toca para comenzar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                    Button(action: {
                        showingQuickWorkout = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Comenzar")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        .sheet(isPresented: $showingQuickWorkout) {
            QuickWorkoutView()
        }
            .onAppear {
                // Actualizar datos del widget
                updateNextWorkoutWidget()
            }
        }
        
        private func updateNextWorkoutWidget() {
            if let routine = activeRoutine {
                WidgetDataManager.shared.saveNextWorkout(
                    name: routine.name,
                    exerciseCount: routine.exercises.count,
                    hasWorkout: true
                )
            } else {
                WidgetDataManager.shared.saveNextWorkout(
                    name: nil,
                    exerciseCount: 0,
                    hasWorkout: false
                )
        }
    }
}

struct QuickProgressCard: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var goalRepo = GoalRepository.shared
    @StateObject private var metricRepo = BodyMetricRepository.shared
    
    var activeGoals: [FitnessGoal] {
        goalRepo.getActiveGoals()
    }
    
    var latestWeight: BodyMetric? {
        metricRepo.getLatestMetric(.weight)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                Text("Progreso Rápido")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            if activeGoals.isEmpty && latestWeight == nil {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.85, blue: 0.7),
                                            Color(red: 1.0, green: 0.75, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "target")
                                .font(.system(size: 36))
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                        }
                        
                        VStack(spacing: 8) {
                            Text("Sin objetivos")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Define objetivos para ver tu progreso")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                    HStack(spacing: 12) {
                    if let weight = latestWeight, let value = weight.value {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                                    Color(red: 0.3, green: 0.5, blue: 0.9)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "scalemass")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                Text(String(format: "%.1f kg", value))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Peso")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    
                    if let goal = activeGoals.first(where: { $0.type == .strength }) as? FitnessGoal {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.8, blue: 0.5),
                                                    Color(red: 0.2, green: 0.7, blue: 0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                Text(String(format: "%.1f kg", goal.startValue))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(goal.exerciseName ?? "Fuerza")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("→ \(String(format: "%.1f", goal.targetValue))")
                                    .font(.caption2)
                                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
    }
}

struct NutritionCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Nutrición del Día")
                .font(.headline)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            VStack(spacing: 10) {
                NutritionBar(name: "Proteínas", value: 0.7, color: .blue)
                NutritionBar(name: "Carbohidratos", value: 0.5, color: .green)
                NutritionBar(name: "Grasas", value: 0.3, color: .orange)
            }
            
            HStack {
                Text("Calorías restantes: 850")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button("Registrar comida") {
                    // Acción para registrar comida
                }
                .font(.caption)
                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgressItem: View {
    let title: String
    let value: String
    let change: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
            Text(change)
                .font(.caption)
                .foregroundColor(change.hasPrefix("+") ? .green : .red)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NutritionBar: View {
    let name: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .font(.caption)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.1)
                        .foregroundColor(color)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * value, height: 8)
                        .foregroundColor(color)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @State private var showingEditProfile = false
    
    var totalSessions: Int {
        sessionRepo.items.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado naranja tenue (adaptado a modo oscuro)
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
                        // Header del perfil
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.65, blue: 0.35),
                                                Color(red: 1.0, green: 0.55, blue: 0.25)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 8)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Usuario Demo")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                                
                                Text("usuario@demo.com")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Información Personal
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Información Personal")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            VStack(spacing: 12) {
                                ProfileInfoRow(icon: "calendar", title: "Edad", value: "28 años", color: Color(red: 0.4, green: 0.6, blue: 1.0))
                                ProfileInfoRow(icon: "ruler", title: "Altura", value: "175 cm", color: Color(red: 0.3, green: 0.8, blue: 0.5))
                                ProfileInfoRow(icon: "scalemass", title: "Peso", value: "75.5 kg", color: Color(red: 1.0, green: 0.65, blue: 0.35))
                                ProfileInfoRow(icon: "target", title: "Objetivo", value: "Ganar masa muscular", color: Color(red: 1.0, green: 0.55, blue: 0.25))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Estadísticas
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Estadísticas")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            HStack(spacing: 12) {
                                StatBoxProfile(
                                    icon: "figure.walk",
                                    title: "Entrenamientos",
                                    value: "\(totalSessions)",
                                    subtitle: "sesiones",
                                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                                )
                                
                                StatBoxProfile(
                                    icon: "flame.fill",
                                    title: "Calorías",
                                    value: "12,450",
                                    subtitle: "kcal",
                                    color: Color(red: 1.0, green: 0.55, blue: 0.25)
                                )
                                
                                StatBoxProfile(
                                    icon: "clock.fill",
                                    title: "Tiempo",
                                    value: "36",
                                    subtitle: "horas",
                                    color: Color(red: 0.3, green: 0.8, blue: 0.5)
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Botón cerrar sesión
                        Button(action: {
                        // Acción de cerrar sesión
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.8))
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        showingEditProfile = true
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
        )
    }
}

struct StatBoxProfile: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(ErrorHandler())
        .environmentObject(NotificationManager())
}
