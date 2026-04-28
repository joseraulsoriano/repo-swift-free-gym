//
//  QuickWorkoutView.swift
//  APP_GYM
//
//  Vista de registro rápido de entrenamiento (30 segundos)
//

import SwiftUI

struct QuickWorkoutView: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @StateObject private var routineRepo = RoutineRepository.shared
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var currentSession: WorkoutSession?
    @State private var showingExerciseEntry = false
    @State private var selectedExercise: PerformedExercise?
    @State private var isNewSession = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let session = currentSession {
                    // Vista de sesión en progreso
                    SessionView(
                        session: session,
                        onExerciseTap: { exercise in
                            selectedExercise = exercise
                            showingExerciseEntry = true
                        },
                        onAddExercise: {
                            addNewExercise()
                        },
                        onSave: {
                            saveSession(session)
                        },
                        onCopyLast: {
                            copyLastSession()
                        }
                    )
                } else {
                    // Pantalla inicial - opciones rápidas
                    QuickStartView(
                        onStartNew: {
                            startNewSession()
                        },
                        onCopyLast: {
                            copyLastSession()
                        },
                        onStartFromRoutine: {
                            startFromRoutine()
                        }
                    )
                }
            }
            .navigationTitle(currentSession == nil ? "Entrenar" : "En Progreso")
            .sheet(isPresented: $showingExerciseEntry) {
                if let exercise = selectedExercise {
                    QuickExerciseEntryView(
                        exercise: exercise,
                        onSave: { updatedExercise in
                            updateExercise(updatedExercise)
                            showingExerciseEntry = false
                            notificationManager.info("Ejercicio actualizado")
                        },
                        onCancel: {
                            showingExerciseEntry = false
                        }
                    )
                }
            }
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
    
    private func startNewSession() {
        currentSession = WorkoutSession()
        isNewSession = true
    }
    
    private func copyLastSession() {
        if let lastSession = sessionRepo.getRecentSessions(limit: 1).first {
            var newSession = WorkoutSession()
            newSession.performedExercises = lastSession.performedExercises.map { exercise in
                var newExercise = PerformedExercise(
                    sessionId: newSession.id,
                    exerciseName: exercise.exerciseName,
                    sets: [],
                    order: exercise.order
                )
                // Copiar última serie de cada ejercicio como base
                if let lastSet = exercise.sets.last {
                    newExercise.sets = [Set(
                        performedExerciseId: newExercise.id,
                        weight: lastSet.weight,
                        repetitions: lastSet.repetitions,
                        order: 0
                    )]
                }
                return newExercise
            }
            currentSession = newSession
            isNewSession = true
        }
    }
    
    private func startFromRoutine() {
        if let routine = routineRepo.getActiveRoutine() {
            var newSession = WorkoutSession(routineId: routine.id)
            newSession.performedExercises = routine.exercises.map { routineExercise in
                PerformedExercise(
                    sessionId: newSession.id,
                    exerciseName: routineExercise.exerciseName,
                    sets: [],
                    order: routineExercise.order
                )
            }
            currentSession = newSession
            isNewSession = true
        }
    }
    
    private func addNewExercise() {
        guard var session = currentSession else { return }
        let newExercise = PerformedExercise(
            sessionId: session.id,
            exerciseName: "",
            order: session.performedExercises.count
        )
        session.performedExercises.append(newExercise)
        currentSession = session
        selectedExercise = newExercise
        showingExerciseEntry = true
    }
    
    private func updateExercise(_ updated: PerformedExercise) {
        guard var session = currentSession else { return }
        if let index = session.performedExercises.firstIndex(where: { $0.id == updated.id }) {
            session.performedExercises[index] = updated
        } else {
            session.performedExercises.append(updated)
        }
        currentSession = session
    }
    
    private func saveSession(_ session: WorkoutSession) {
        do {
            sessionRepo.save(session)
            currentSession = nil
            notificationManager.success("Entrenamiento guardado", message: "¡Buen trabajo!")
        } catch {
            errorHandler.handle(error)
        }
    }
}

// MARK: - Vista de Inicio Rápido
struct QuickStartView: View {
    let onStartNew: () -> Void
    let onCopyLast: () -> Void
    let onStartFromRoutine: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("¿Cómo quieres empezar?")
                .font(.title)
                .bold()
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            VStack(spacing: 15) {
                Button(action: onStartNew) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Nuevo Entrenamiento")
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
                
                Button(action: onCopyLast) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copiar Última Sesión")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.8, blue: 0.5),
                                Color(red: 0.2, green: 0.7, blue: 0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: onStartFromRoutine) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Desde Rutina")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.4, green: 0.6, blue: 1.0),
                                Color(red: 0.3, green: 0.5, blue: 0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding()
            
            Spacer()
        }
    }
}


// MARK: - Vista de Sesión
struct SessionView: View {
    let session: WorkoutSession
    let onExerciseTap: (PerformedExercise) -> Void
    let onAddExercise: () -> Void
    let onSave: () -> Void
    let onCopyLast: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Lista de ejercicios
            List {
                ForEach(session.performedExercises.sorted(by: { $0.order < $1.order })) { exercise in
                    ExerciseQuickCard(exercise: exercise)
                        .onTapGesture {
                            onExerciseTap(exercise)
                        }
                }
                
                Button(action: onAddExercise) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Agregar Ejercicio")
                    }
                    .font(.headline)
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            
            // Botón de guardar
            Button(action: onSave) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Guardar Entrenamiento")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.8, blue: 0.5),
                            Color(red: 0.2, green: 0.7, blue: 0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding()
        }
    }
}

struct ExerciseQuickCard: View {
    let exercise: PerformedExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.exerciseName)
                    .font(.headline)
                Spacer()
                if !exercise.sets.isEmpty {
                    BadgeView("\(exercise.sets.count) series", color: Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
            
            if exercise.sets.isEmpty {
                Text("Toca para agregar series")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(exercise.sets.sorted(by: { $0.order < $1.order })) { set in
                            BadgeView("\(Int(set.weight))kg × \(set.repetitions)", color: Color(red: 1.0, green: 0.55, blue: 0.25))
                        }
                    }
                }
                
                HStack {
                    StatCard(
                        title: "Máximo",
                        value: String(format: "%.1f kg", exercise.maxWeight),
                        icon: "arrow.up.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Volumen",
                        value: String(format: "%.0f kg", exercise.totalVolume),
                        icon: "chart.bar.fill",
                        color: .orange
                    )
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Vista de Registro Rápido de Ejercicio
struct QuickExerciseEntryView: View {
    @State var exercise: PerformedExercise
    let onSave: (PerformedExercise) -> Void
    let onCancel: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    @State private var exerciseName: String = ""
    @State private var sets: [SetEntry] = []
    
    struct SetEntry: Identifiable {
        let id = UUID()
        var weight: String = ""
        var reps: String = ""
    }
    
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
                        // Nombre del Ejercicio
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
                        
                        // Series
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Series")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                                
                                Spacer()
                                
                                Button(action: {
                                    sets.append(SetEntry())
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Agregar")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                                }
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(sets.indices, id: \.self) { index in
                                    SetInputRow(
                                        setNumber: index + 1,
                                        weight: Binding(
                                            get: { sets[index].weight },
                                            set: { sets[index].weight = $0 }
                                        ),
                                        reps: Binding(
                                            get: { sets[index].reps },
                                            set: { sets[index].reps = $0 }
                                        ),
                                        onDelete: {
                                            sets.remove(at: index)
                                        }
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
                        
                        // Botón Guardar
                        Button(action: {
                            saveExercise()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Guardar Ejercicio")
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
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Registrar Ejercicio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        onCancel()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
            .onAppear {
                exerciseName = exercise.exerciseName
                if exercise.sets.isEmpty {
                    sets = [SetEntry()]
                } else {
                    sets = exercise.sets.map { set in
                        SetEntry(weight: String(format: "%.0f", set.weight), reps: String(set.repetitions))
                    }
                }
            }
        }
    }
    
    private func saveExercise() {
        exercise.exerciseName = exerciseName
        exercise.sets = sets.enumerated().compactMap { index, setEntry in
            guard let weight = Double(setEntry.weight),
                  let reps = Int(setEntry.reps) else {
                return nil
            }
            return Set(
                performedExerciseId: exercise.id,
                weight: weight,
                repetitions: reps,
                order: index
            )
        }
        onSave(exercise)
    }
}

struct SetInputRow: View {
    let setNumber: Int
    @Binding var weight: String
    @Binding var reps: String
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Número de serie
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
                    .frame(width: 36, height: 36)
                
                Text("\(setNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Peso
            VStack(alignment: .leading, spacing: 4) {
                Text("Peso")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("0", text: $weight)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    
                    Text("kg")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
            )
            
            // Repeticiones
            VStack(alignment: .leading, spacing: 4) {
                Text("Reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $reps)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
            }
            .frame(width: 80)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
            )
            
            // Botón eliminar
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
            }
            .padding(.leading, 8)
        }
    }
}

#Preview {
    QuickWorkoutView()
}

