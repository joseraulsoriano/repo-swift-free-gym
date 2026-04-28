import SwiftUI
import Foundation
import Charts

// Modelo de datos para el progreso del usuario
struct WorkoutProgress: Codable, Identifiable {
    var id = UUID()
    var date: String // Fecha en formato YYYY-MM-DD
    var exerciseName: String
    var sets: Int
    var reps: Int
    var weight: Double // en kilogramos
    var feeling: Int // Nueva propiedad para registrar la sensación del ejercicio
    var fatigue: String // Nueva propiedad para registrar la fatiga
    var comments: String // Nueva propiedad para registrar comentarios adicionales
}

class ProgressManager: ObservableObject {
    private let fileName = "workoutProgress.json"
    @Published var progress: [WorkoutProgress] = []
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    init() {
        loadProgress()
    }
    
    func saveProgress() {
        do {
            let data = try JSONEncoder().encode(progress)
            try data.write(to: fileURL)
        } catch {
            print("Error al guardar el progreso: \(error.localizedDescription)")
        }
    }
    
    func loadProgress() {
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedProgress = try JSONDecoder().decode([WorkoutProgress].self, from: data)
            self.progress = loadedProgress
        } catch {
            print("No se pudo cargar el progreso: \(error.localizedDescription)")
        }
    }
    
    func addProgress(date: String, exerciseName: String, sets: Int, reps: Int, weight: Double, feeling: Int, fatigue: String, comments: String) {
        let newProgress = WorkoutProgress(date: date, exerciseName: exerciseName, sets: sets, reps: reps, weight: weight, feeling: feeling, fatigue: fatigue, comments: comments)
        progress.append(newProgress)
        saveProgress()
    }
}

struct Progreso: View {
    @StateObject private var progressManager = ProgressManager()
    @State private var selectedTab = 0
    @State private var showingAddProgress = false
    @State private var showingResultsHistory = false
    
    var progressEntries: [ProgressEntry] {
        progressManager.progress.map { workoutProgress in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: workoutProgress.date) ?? Date()
            
            return ProgressEntry(
                date: date,
                weight: workoutProgress.weight,
                bodyFat: nil,
                notes: workoutProgress.comments.isEmpty ? nil : workoutProgress.comments
            )
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Selector de pestañas
                Picker("Vista", selection: $selectedTab) {
                    Text("Gráfico").tag(0)
                    Text("Historial").tag(1)
                    Text("Resultados").tag(2)
                    Text("Objetivos").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    // Vista de Gráfico
                    ProgressChartView(entries: progressEntries, progressManager: progressManager)
                        .tag(0)
                    
                    // Vista de Historial de Peso
                    ProgressHistoryView(entries: progressEntries)
                        .tag(1)
                    
                    // Vista de Resultados de Ejercicios
                    WorkoutResultsHistoryView(progressManager: progressManager)
                        .tag(2)
                    
                    // Vista de Objetivos
                    LegacyGoalsView()
                        .tag(3)
                }
                #if os(iOS)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                #endif
            }
            .navigationTitle("Progreso")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddProgress = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingAddProgress = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingAddProgress) {
                AddProgressView { newEntry in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateString = dateFormatter.string(from: newEntry.date)
                    
                    progressManager.addProgress(
                        date: dateString,
                        exerciseName: "Peso Corporal",
                        sets: 1,
                        reps: 1,
                        weight: newEntry.weight,
                        feeling: 3,
                        fatigue: "Normal",
                        comments: newEntry.notes ?? ""
                    )
                    showingAddProgress = false
                }
            }
        }
    }
}

struct ProgressEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let bodyFat: Double?
    let notes: String?
}

struct ProgressChartView: View {
    let entries: [ProgressEntry]
    @ObservedObject var progressManager: ProgressManager
    @State private var selectedExercise: String? = nil
    
    var uniqueExercises: [String] {
        var seen = [String: Bool]()
        let exercises = progressManager.progress.map { $0.exerciseName }
        return exercises.filter { seen.updateValue(true, forKey: $0) == nil }.sorted()
    }
    
    var exerciseProgress: [String: [WorkoutProgress]] {
        Dictionary(grouping: progressManager.progress) { $0.exerciseName }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Gráfico de peso corporal
                VStack(alignment: .leading) {
                    Text("Evolución del Peso Corporal")
                        .font(.headline)
                    
                    Chart {
                        ForEach(entries) { entry in
                            LineMark(
                                x: .value("Fecha", entry.date),
                                y: .value("Peso", entry.weight)
                            )
                            .foregroundStyle(.blue)
                            
                            PointMark(
                                x: .value("Fecha", entry.date),
                                y: .value("Peso", entry.weight)
                            )
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                }
                .padding()
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(NSColor.controlBackgroundColor))
                #endif
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Selector de ejercicio para gráficos
                if !uniqueExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progreso por Ejercicio")
                            .font(.headline)
                        
                        Picker("Ejercicio", selection: $selectedExercise) {
                            Text("Todos").tag(nil as String?)
                            ForEach(uniqueExercises, id: \.self) { exercise in
                                Text(exercise).tag(exercise as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        if let exercise = selectedExercise, let progress = exerciseProgress[exercise] {
                            ExerciseProgressChart(exercise: exercise, progress: progress)
                        } else if selectedExercise == nil {
                            AllExercisesProgressChart(exerciseProgress: exerciseProgress)
                        }
                    }
                    .padding()
                    #if os(iOS)
                    .background(Color(.systemBackground))
                    #else
                    .background(Color(NSColor.controlBackgroundColor))
                    #endif
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                // Resumen de progreso
                VStack(spacing: 15) {
                    Text("Resumen de Progreso")
                        .font(.headline)
                    
                    if let firstEntry = entries.first,
                       let lastEntry = entries.last {
                        let weightChange = lastEntry.weight - firstEntry.weight
                        let daysBetween = Calendar.current.dateComponents([.day], from: firstEntry.date, to: lastEntry.date).day ?? 0
                        
                        HStack {
                            LegacyStatBox(title: "Cambio de Peso", value: String(format: "%.1f kg", weightChange))
                            LegacyStatBox(title: "Período", value: "\(daysBetween) días")
                        }
                        
                        if daysBetween > 0 {
                            let dailyChange = weightChange / Double(daysBetween)
                            LegacyStatBox(title: "Cambio Diario", value: String(format: "%.2f kg/día", dailyChange))
                        }
                    }
                }
                .padding()
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(NSColor.controlBackgroundColor))
                #endif
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}

struct ProgressHistoryView: View {
    let entries: [ProgressEntry]
    
    var body: some View {
        List {
            ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.date, style: .date)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f kg", entry.weight))
                            .font(.title3)
                            .bold()
                    }
                    
                    if let bodyFat = entry.bodyFat {
                        Text("Grasa corporal: \(String(format: "%.1f%%", bodyFat))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    if let notes = entry.notes {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct LegacyGoalsView: View {
    @State private var goals: [LegacyGoal] = [
        LegacyGoal(title: "Peso Objetivo", target: 75.0, current: 78.0, unit: "kg"),
        LegacyGoal(title: "Grasa Corporal", target: 15.0, current: 18.0, unit: "%"),
        LegacyGoal(title: "Entrenamientos por Semana", target: 4.0, current: 3.0, unit: "sesiones")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(goals) { goal in
                    LegacyGoalCard(goal: goal)
                }
            }
            .padding()
        }
    }
}

struct LegacyGoal: Identifiable {
    let id = UUID()
    let title: String
    let target: Double
    let current: Double
    let unit: String
}

struct LegacyGoalCard: View {
    let goal: LegacyGoal
    
    var progress: Double {
        (goal.current / goal.target) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(goal.title)
                .font(.headline)
            
            ProgressView(value: progress, total: 100)
                .tint(progressColor)
            
            HStack {
                Text("Actual: \(String(format: "%.1f", goal.current)) \(goal.unit)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Objetivo: \(String(format: "%.1f", goal.target)) \(goal.unit)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    var progressColor: Color {
        if progress >= 100 {
            return .green
        } else if progress >= 75 {
            return .blue
        } else if progress >= 50 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct AddProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var weight: String = ""
    @State private var bodyFat: String = ""
    @State private var notes: String = ""
    let onSave: (ProgressEntry) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mediciones")) {
                    #if os(iOS)
                    TextField("Peso (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    TextField("Grasa Corporal (%)", text: $bodyFat)
                        .keyboardType(.decimalPad)
                    #else
                    TextField("Peso (kg)", text: $weight)
                    TextField("Grasa Corporal (%)", text: $bodyFat)
                    #endif
                }
                
                Section(header: Text("Notas")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nuevo Registro")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveEntry()
                    }
                    .disabled(weight.isEmpty)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveEntry()
                    }
                    .disabled(weight.isEmpty)
                }
                #endif
            }
        }
    }
    
    private func saveEntry() {
        guard let weightValue = Double(weight) else { return }
        let bodyFatValue = Double(bodyFat)
        
        let entry = ProgressEntry(
            date: Date(),
            weight: weightValue,
            bodyFat: bodyFatValue,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave(entry)
    }
}

struct LegacyStatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(8)
    }
}

struct WorkoutResultsHistoryView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var selectedExercise: String? = nil
    @State private var searchText = ""
    
    var uniqueExercises: [String] {
        var seen = [String: Bool]()
        let exercises = progressManager.progress.map { $0.exerciseName }
        return exercises.filter { seen.updateValue(true, forKey: $0) == nil }.sorted()
    }
    
    var filteredResults: [WorkoutProgress] {
        var results = progressManager.progress
        
        if let exercise = selectedExercise {
            results = results.filter { $0.exerciseName == exercise }
        }
        
        if !searchText.isEmpty {
            results = results.filter {
                $0.exerciseName.localizedCaseInsensitiveContains(searchText) ||
                $0.comments.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return results.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filtros
            VStack(spacing: 10) {
                // Buscador
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar ejercicio...", text: $searchText)
                }
                .padding()
                #if os(iOS)
                .background(Color(.systemGray6))
                #else
                .background(Color(NSColor.controlBackgroundColor))
                #endif
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Selector de ejercicio
                if !uniqueExercises.isEmpty {
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
            .padding(.vertical)
            
            // Lista de resultados
            if filteredResults.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No hay resultados registrados")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Comienza un entrenamiento y registra tus resultados")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(groupedResults) { group in
                        Section(header: Text(group.date)) {
                            ForEach(group.results) { result in
                                WorkoutResultRow(result: result)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Resultados de Ejercicios")
    }
    
    var groupedResults: [ResultGroup] {
        let grouped = Dictionary(grouping: filteredResults) { result in
            result.date
        }
        
        return grouped.map { date, results in
            ResultGroup(date: formatDate(date), results: results)
        }.sorted { $0.date > $1.date }
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct ResultGroup: Identifiable {
    let id = UUID()
    let date: String
    let results: [WorkoutProgress]
}

struct WorkoutResultRow: View {
    let result: WorkoutProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.exerciseName)
                    .font(.headline)
                Spacer()
                Text("\(result.sets) series")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Label("\(result.reps) reps", systemImage: "repeat")
                Spacer()
                Label("\(String(format: "%.1f", result.weight)) kg", systemImage: "scalemass")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            HStack {
                // Sensación
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { value in
                        Image(systemName: result.feeling >= value ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(result.feeling >= value ? .yellow : .gray)
                    }
                }
                
                Spacer()
                
                // Fatiga
                Text("Fatiga: \(result.fatigue)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !result.comments.isEmpty {
                Text(result.comments)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseProgressChart: View {
    let exercise: String
    let progress: [WorkoutProgress]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(exercise)
                .font(.subheadline)
                .bold()
            
            Chart {
                ForEach(sortedProgress) { item in
                    LineMark(
                        x: .value("Fecha", item.date),
                        y: .value("Peso", item.weight)
                    )
                    .foregroundStyle(.green)
                    
                    PointMark(
                        x: .value("Fecha", item.date),
                        y: .value("Peso", item.weight)
                    )
                    .foregroundStyle(.green)
                }
            }
            .frame(height: 150)
            
            HStack {
                Text("Series: \(progress.reduce(0) { $0 + $1.sets })")
                Spacer()
                Text("Reps promedio: \(String(format: "%.0f", Double(progress.reduce(0) { $0 + $1.reps }) / Double(progress.count))))")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
    
    var sortedProgress: [WorkoutProgress] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return progress.sorted { progress1, progress2 in
            let date1 = dateFormatter.date(from: progress1.date) ?? Date()
            let date2 = dateFormatter.date(from: progress2.date) ?? Date()
            return date1 < date2
        }
    }
}

struct AllExercisesProgressChart: View {
    let exerciseProgress: [String: [WorkoutProgress]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Comparación de Peso por Ejercicio")
                .font(.subheadline)
                .bold()
            
            Chart {
                ForEach(Array(exerciseProgress.keys.sorted()), id: \.self) { exercise in
                    if let progress = exerciseProgress[exercise] {
                        let sorted = sortedProgress(progress)
                        ForEach(sorted) { item in
                            LineMark(
                                x: .value("Fecha", item.date),
                                y: .value("Peso", item.weight)
                            )
                            .foregroundStyle(by: .value("Ejercicio", exercise))
                            
                            PointMark(
                                x: .value("Fecha", item.date),
                                y: .value("Peso", item.weight)
                            )
                            .foregroundStyle(by: .value("Ejercicio", exercise))
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom)
        }
    }
    
    func sortedProgress(_ progress: [WorkoutProgress]) -> [WorkoutProgress] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return progress.sorted { progress1, progress2 in
            let date1 = dateFormatter.date(from: progress1.date) ?? Date()
            let date2 = dateFormatter.date(from: progress2.date) ?? Date()
            return date1 < date2
        }
    }
}

#Preview {
    Progreso()
}
