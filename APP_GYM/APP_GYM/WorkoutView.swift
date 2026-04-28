import SwiftUI
#if os(macOS)
import AppKit
#endif

struct WorkoutView: View {
    @State private var selectedCategory: WorkoutCategory = .strength
    @State private var showingNewWorkout = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Categorías
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(WorkoutCategory.allCases) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding()
                }
                
                // Lista de rutinas
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredWorkouts) { workout in
                            WorkoutCard(workout: workout)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Entrenamientos")
            .searchable(text: $searchText, prompt: "Buscar rutinas")
            #if os(iOS)
            .navigationBarItems(trailing: Button(action: {
                showingNewWorkout = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            })
            #else
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewWorkout = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            #endif
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
        }
    }
    
    var filteredWorkouts: [Workout] {
        Workout.sampleWorkouts.filter { workout in
            (searchText.isEmpty || workout.name.localizedCaseInsensitiveContains(searchText)) &&
            workout.category == selectedCategory
        }
    }
}

enum WorkoutCategory: String, CaseIterable, Identifiable {
    case strength = "Fuerza"
    case cardio = "Cardio"
    case flexibility = "Flexibilidad"
    case hiit = "HIIT"
    case yoga = "Yoga"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.circle.fill"
        case .flexibility: return "figure.walk"
        case .hiit: return "timer"
        case .yoga: return "figure.mind.and.body"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .blue
        case .cardio: return .red
        case .flexibility: return .green
        case .hiit: return .orange
        case .yoga: return .purple
        }
    }
}

struct CategoryButton: View {
    let category: WorkoutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            #if os(iOS)
            .background(isSelected ? category.color.opacity(0.2) : Color(.systemGray6))
            #else
            .background(isSelected ? category.color.opacity(0.2) : Color(NSColor.controlBackgroundColor))
            #endif
            .foregroundColor(isSelected ? category.color : .primary)
            .cornerRadius(15)
        }
    }
}

struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let category: WorkoutCategory
    let duration: Int // en minutos
    let difficulty: String
    let exercises: [Exercise]
    let description: String
    let calories: Int
    
    static let sampleWorkouts: [Workout] = [
        Workout(
            name: "Entrenamiento de Fuerza Superior",
            category: .strength,
            duration: 45,
            difficulty: "Intermedio",
            exercises: [
                Exercise(name: "Press de Banca", sets: 4, reps: "8-10", rest: 90),
                Exercise(name: "Remo con Barra", sets: 4, reps: "8-10", rest: 90),
                Exercise(name: "Press Militar", sets: 3, reps: "10-12", rest: 60),
                Exercise(name: "Curl de Bíceps", sets: 3, reps: "12-15", rest: 60)
            ],
            description: "Rutina enfocada en el desarrollo de la fuerza del tren superior.",
            calories: 350
        ),
        Workout(
            name: "HIIT Cardio",
            category: .hiit,
            duration: 30,
            difficulty: "Avanzado",
            exercises: [
                Exercise(name: "Burpees", sets: 4, reps: "30 seg", rest: 30),
                Exercise(name: "Mountain Climbers", sets: 4, reps: "30 seg", rest: 30),
                Exercise(name: "Jumping Jacks", sets: 4, reps: "30 seg", rest: 30),
                Exercise(name: "High Knees", sets: 4, reps: "30 seg", rest: 30)
            ],
            description: "Entrenamiento de alta intensidad para quemar calorías.",
            calories: 450
        )
    ]
}

struct Exercise {
    let name: String
    let sets: Int
    let reps: String
    let rest: Int // en segundos
}

struct WorkoutCard: View {
    let workout: Workout
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(workout.name)
                            .font(.headline)
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(workout.duration) min")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(workout.difficulty)
                            .font(.caption)
                            .padding(5)
                            .background(workout.category.color.opacity(0.2))
                            .foregroundColor(workout.category.color)
                            .cornerRadius(5)
                    }
                }
                
                HStack {
                    Label("\(workout.exercises.count) ejercicios", systemImage: "figure.walk")
                    Spacer()
                    Label("\(workout.calories) cal", systemImage: "flame.fill")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.controlBackgroundColor))
            #endif
            .cornerRadius(15)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            WorkoutDetailView(workout: workout)
        }
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.presentationMode) var presentationMode
    @State private var showingStartWorkout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Información general
                    VStack(alignment: .leading, spacing: 10) {
                        Text(workout.description)
                            .font(.body)
                        
                        HStack(spacing: 20) {
                            WorkoutInfoItem(icon: "clock", value: "\(workout.duration) min")
                            WorkoutInfoItem(icon: "flame.fill", value: "\(workout.calories) cal")
                            WorkoutInfoItem(icon: "figure.walk", value: workout.difficulty)
                        }
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(.systemBackground))
                    #else
                    .background(Color(NSColor.controlBackgroundColor))
                    #endif
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    
                    // Lista de ejercicios
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ejercicios")
                            .font(.headline)
                        
                        ForEach(workout.exercises, id: \.name) { exercise in
                            ExerciseRow(exercise: exercise)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle(workout.name)
            .navigationBarItems(
                leading: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Comenzar") {
                    showingStartWorkout = true
                }
                .buttonStyle(.borderedProminent)
            )
            .sheet(isPresented: $showingStartWorkout) {
                ActiveWorkoutView(workout: workout)
            }
        }
    }
}

struct WorkoutInfoItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title3)
            Text(value)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.subheadline)
                    .bold()
                Text("\(exercise.sets) series × \(exercise.reps)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(exercise.rest)s")
                .font(.caption)
                .padding(5)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(5)
        }
    }
}

struct ActiveWorkoutView: View {
    let workout: Workout
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @State private var currentExerciseIndex = 0
    @State private var currentSet = 1
    @State private var isResting = false
    @State private var timeRemaining = 0
    @State private var showingFinishAlert = false
    @State private var showingResultEntry = false
    @State private var workoutResults: [ExerciseResult] = []
    
    var currentExercise: Exercise {
        workout.exercises[currentExerciseIndex]
    }
    
    struct ExerciseResult {
        let exerciseName: String
        let sets: Int
        let reps: Int
        let weight: Double
        let feeling: Int
        let fatigue: String
        let comments: String
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progreso
                ProgressView(value: Double(currentExerciseIndex), total: Double(workout.exercises.count))
                    .padding()
                
                // Ejercicio actual
                VStack(spacing: 15) {
                    Text(currentExercise.name)
                        .font(.title)
                        .bold()
                    
                    if isResting {
                        Text("Descanso")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("\(timeRemaining)s")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.blue)
                    } else {
                        Text("Serie \(currentSet) de \(currentExercise.sets)")
                            .font(.headline)
                        
                        Text(currentExercise.reps)
                            .font(.system(size: 60, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(NSColor.controlBackgroundColor))
                #endif
                .cornerRadius(15)
                .shadow(radius: 2)
                
                // Botones de control
                HStack(spacing: 30) {
                    Button(action: previousExercise) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title)
                    }
                    .disabled(currentExerciseIndex == 0)
                    
                    Button(action: toggleRest) {
                        Image(systemName: isResting ? "play.circle.fill" : "pause.circle.fill")
                            .font(.title)
                    }
                    
                    Button(action: nextExercise) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title)
                    }
                }
                
                // Botón para registrar resultado de la serie
                if !isResting && currentSet > 0 {
                    Button(action: {
                        showingResultEntry = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Registrar Serie \(currentSet)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Entrenamiento en Progreso")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Finalizar") {
                        showingFinishAlert = true
                    }
                }
            }
            .alert("¿Finalizar entrenamiento?", isPresented: $showingFinishAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Finalizar", role: .destructive) {
                    saveWorkoutResults()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("¿Estás seguro de que quieres finalizar el entrenamiento?")
            }
            .sheet(isPresented: $showingResultEntry) {
                ResultEntryView(
                    exerciseName: currentExercise.name,
                    setNumber: currentSet,
                    totalSets: currentExercise.sets,
                    onSave: { result in
                        saveExerciseResult(result)
                        showingResultEntry = false
                    },
                    onCancel: {
                        showingResultEntry = false
                    }
                )
            }
        }
    }
    
    private func saveExerciseResult(_ result: ExerciseResult) {
        workoutResults.append(result)
    }
    
    private func saveWorkoutResults() {
        // Crear una sesión de entrenamiento con los resultados
        var session = WorkoutSession()
        
        // Agrupar resultados por ejercicio
        let exercisesDict = Dictionary(grouping: workoutResults) { $0.exerciseName }
        
        for (exerciseName, results) in exercisesDict {
            var performedExercise = PerformedExercise(
                sessionId: session.id,
                exerciseName: exerciseName,
                sets: [],
                order: session.performedExercises.count
            )
            
            // Convertir resultados a sets
            for (index, result) in results.enumerated() {
                let workoutSet = APP_GYM.Set(
                    performedExerciseId: performedExercise.id,
                    weight: result.weight,
                    repetitions: result.reps,
                    order: index
                )
                performedExercise.sets.append(workoutSet)
            }
            
            session.performedExercises.append(performedExercise)
        }
        
        // Guardar la sesión
        sessionRepo.save(session)
    }
    
    private func toggleRest() {
        isResting.toggle()
        if isResting {
            timeRemaining = currentExercise.rest
            // Aquí iría la lógica del timer
        }
    }
    
    private func nextExercise() {
        if currentSet < currentExercise.sets {
            currentSet += 1
        } else if currentExerciseIndex < workout.exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
        }
    }
    
    private func previousExercise() {
        if currentSet > 1 {
            currentSet -= 1
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSet = workout.exercises[currentExerciseIndex].sets
        }
    }
}

struct NewWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var workoutName = ""
    @State private var selectedCategory: WorkoutCategory = .strength
    @State private var duration = 30
    @State private var difficulty = "Intermedio"
    @State private var description = ""
    
    let difficulties = ["Principiante", "Intermedio", "Avanzado"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Básica")) {
                    TextField("Nombre del entrenamiento", text: $workoutName)
                    
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(WorkoutCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    Stepper("Duración: \(duration) min", value: $duration, in: 5...120, step: 5)
                    
                    Picker("Dificultad", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { level in
                            Text(level)
                        }
                    }
                }
                
                Section(header: Text("Descripción")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Crear Entrenamiento") {
                        // Aquí iría la lógica para crear el entrenamiento
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
            .navigationTitle("Nuevo Entrenamiento")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ResultEntryView: View {
    let exerciseName: String
    let setNumber: Int
    let totalSets: Int
    let onSave: (ActiveWorkoutView.ExerciseResult) -> Void
    let onCancel: () -> Void
    
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var feeling: Int = 3
    @State private var fatigue: String = "Normal"
    @State private var comments: String = ""
    
    let fatigueOptions = ["Muy Baja", "Baja", "Normal", "Alta", "Muy Alta"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información de la Serie")) {
                    HStack {
                        Text("Ejercicio:")
                        Spacer()
                        Text(exerciseName)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Serie:")
                        Spacer()
                        Text("\(setNumber) de \(totalSets)")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Resultados")) {
                    HStack {
                        Text("Peso (kg)")
                        Spacer()
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Repeticiones")
                        Spacer()
                        TextField("0", text: $reps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("Sensación")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("¿Cómo te sentiste? (1-5)")
                            .font(.subheadline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { value in
                                Button(action: {
                                    feeling = value
                                }) {
                                    Image(systemName: feeling >= value ? "star.fill" : "star")
                                        .foregroundColor(feeling >= value ? .yellow : .gray)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Fatiga")) {
                    Picker("Nivel de Fatiga", selection: $fatigue) {
                        ForEach(fatigueOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Comentarios")) {
                    TextEditor(text: $comments)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: saveResult) {
                        Text("Guardar Resultado")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(weight.isEmpty || reps.isEmpty)
                }
            }
            .navigationTitle("Registrar Serie")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    onCancel()
                }
            )
        }
    }
    
    private func saveResult() {
        guard let weightValue = Double(weight),
              let repsValue = Int(reps) else {
            return
        }
        
        let result = ActiveWorkoutView.ExerciseResult(
            exerciseName: exerciseName,
            sets: setNumber,
            reps: repsValue,
            weight: weightValue,
            feeling: feeling,
            fatigue: fatigue,
            comments: comments
        )
        
        onSave(result)
    }
}

#Preview {
    WorkoutView()
} 