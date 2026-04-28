//
//  Repositories.swift
//  APP_GYM
//
//  Repositorios para gestión de datos del dominio
//

import Foundation
import Combine
import os.log

// MARK: - Protocolo Base para Repositorios
protocol Repository {
    associatedtype Entity: Codable & Identifiable
    func save(_ entity: Entity) throws
    func loadAll() throws -> [Entity]
    func delete(_ entity: Entity) throws
}

// MARK: - Repositorio Genérico con Persistencia JSON
class JSONRepository<T: Codable & Identifiable>: ObservableObject {
    private let fileName: String
    @Published var items: [T] = []
    
    init(fileName: String) {
        self.fileName = fileName
        load()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    func save(_ item: T) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        persist()
    }
    
    func delete(_ item: T) {
        items.removeAll { $0.id == item.id }
        persist()
    }
    
    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([T].self, from: data)
        } catch {
            // Si el archivo no existe, es la primera vez - inicializar vacío
            if (error as NSError).domain == NSCocoaErrorDomain && 
               (error as NSError).code == NSFileReadNoSuchFileError {
                items = []
            } else {
                // Log del error pero no crashear
                #if DEBUG
                print("⚠️ No se pudo cargar \(fileName): \(error.localizedDescription)")
                #endif
                items = []
            }
        }
    }
    
    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            #if DEBUG
            print("❌ Error al guardar \(fileName): \(error.localizedDescription)")
            #endif
            // En producción, podrías notificar al usuario o usar un sistema de logging
        }
    }
}

// MARK: - Repositorio de Sesiones
// Usa CloudKit si está disponible, sino usa JSON local
class WorkoutSessionRepository: ObservableObject {
    private let cloudRepo = CloudWorkoutSessionRepository.shared
    private let jsonRepo = JSONWorkoutSessionRepository()
    
    static let shared = WorkoutSessionRepository()
    
    @Published var items: [WorkoutSession] = []
    
    init() {
        // Intentar usar CloudKit primero
        items = cloudRepo.items
        if items.isEmpty {
            // Si no hay datos en CloudKit, cargar de JSON local
            items = jsonRepo.items
        }
        
        // Observar cambios en CloudKit
        cloudRepo.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }
    
    func save(_ item: WorkoutSession) {
        cloudRepo.save(item)
        jsonRepo.save(item) // Backup local
    }
    
    func delete(_ item: WorkoutSession) {
        cloudRepo.delete(item)
        jsonRepo.delete(item)
    }
    
    func load() {
        cloudRepo.load()
        jsonRepo.load()
        items = cloudRepo.items.isEmpty ? jsonRepo.items : cloudRepo.items
    }
    
    func getSessionsForExercise(_ exerciseName: String) -> [WorkoutSession] {
        cloudRepo.getSessionsForExercise(exerciseName)
    }
    
    func getRecentSessions(limit: Int = 10) -> [WorkoutSession] {
        cloudRepo.getRecentSessions(limit: limit)
    }
    
    func getSessionsInDateRange(from: Date, to: Date) -> [WorkoutSession] {
        cloudRepo.getSessionsInDateRange(from: from, to: to)
    }
}

// Repositorio JSON de respaldo
class JSONWorkoutSessionRepository: JSONRepository<WorkoutSession> {
    init() {
        super.init(fileName: "workout_sessions.json")
    }
}

// MARK: - Repositorio de Rutinas
class RoutineRepository: ObservableObject {
    private let cloudRepo = CloudRoutineRepository.shared
    private let jsonRepo = JSONRoutineRepository()
    
    static let shared = RoutineRepository()
    
    @Published var items: [Routine] = []
    
    init() {
        items = cloudRepo.items
        if items.isEmpty {
            items = jsonRepo.items
        }
        
        cloudRepo.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }
    
    func save(_ item: Routine) {
        cloudRepo.save(item)
        jsonRepo.save(item)
    }
    
    func delete(_ item: Routine) {
        cloudRepo.delete(item)
        jsonRepo.delete(item)
    }
    
    func load() {
        cloudRepo.load()
        jsonRepo.load()
        items = cloudRepo.items.isEmpty ? jsonRepo.items : cloudRepo.items
    }
    
    func getActiveRoutine() -> Routine? {
        cloudRepo.getActiveRoutine() ?? jsonRepo.items.first
    }
}

class JSONRoutineRepository: JSONRepository<Routine> {
    init() {
        super.init(fileName: "routines.json")
    }
}

// MARK: - Repositorio de Objetivos
class GoalRepository: ObservableObject {
    private let cloudRepo = CloudGoalRepository.shared
    private let jsonRepo = JSONGoalRepository()
    
    static let shared = GoalRepository()
    
    @Published var items: [FitnessGoal] = []
    
    init() {
        items = cloudRepo.items
        if items.isEmpty {
            items = jsonRepo.items
        }
        
        cloudRepo.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }
    
    func save(_ item: FitnessGoal) {
        cloudRepo.save(item)
        jsonRepo.save(item)
    }
    
    func delete(_ item: FitnessGoal) {
        cloudRepo.delete(item)
        jsonRepo.delete(item)
    }
    
    func load() {
        cloudRepo.load()
        jsonRepo.load()
        items = cloudRepo.items.isEmpty ? jsonRepo.items : cloudRepo.items
    }
    
    func getActiveGoals() -> [FitnessGoal] {
        cloudRepo.getActiveGoals()
    }
    
    func getGoalsForExercise(_ exerciseName: String) -> [FitnessGoal] {
        cloudRepo.getGoalsForExercise(exerciseName)
    }
}

class JSONGoalRepository: JSONRepository<FitnessGoal> {
    init() {
        super.init(fileName: "goals.json")
    }
}

// MARK: - Repositorio de Métricas Corporales
class BodyMetricRepository: ObservableObject {
    private let cloudRepo = CloudBodyMetricRepository.shared
    private let jsonRepo = JSONBodyMetricRepository()
    
    static let shared = BodyMetricRepository()
    
    @Published var items: [BodyMetric] = []
    
    init() {
        items = cloudRepo.items
        if items.isEmpty {
            items = jsonRepo.items
        }
        
        cloudRepo.$items
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }
    
    func save(_ item: BodyMetric) {
        cloudRepo.save(item)
        jsonRepo.save(item)
    }
    
    func delete(_ item: BodyMetric) {
        cloudRepo.delete(item)
        jsonRepo.delete(item)
    }
    
    func load() {
        cloudRepo.load()
        jsonRepo.load()
        items = cloudRepo.items.isEmpty ? jsonRepo.items : cloudRepo.items
    }
    
    func getMetricsByType(_ type: BodyMetricType) -> [BodyMetric] {
        cloudRepo.getMetricsByType(type)
    }
    
    func getLatestMetric(_ type: BodyMetricType) -> BodyMetric? {
        cloudRepo.getLatestMetric(type)
    }
}

class JSONBodyMetricRepository: JSONRepository<BodyMetric> {
    init() {
        super.init(fileName: "body_metrics.json")
    }
}

// MARK: - Servicio de Análisis de Progreso
class ProgressAnalysisService {
    private let sessionRepository = WorkoutSessionRepository.shared
    
    func analyzeProgress(for exerciseName: String) -> ProgressAnalysis {
        let sessions = sessionRepository.getSessionsForExercise(exerciseName)
        let recentSessions = Array(sessions.sorted { $0.date > $1.date }.prefix(8))
        
        guard !recentSessions.isEmpty else {
            return ProgressAnalysis(
                exerciseName: exerciseName,
                isStagnant: false,
                weeksStagnant: nil,
                trend: .stable,
                lastPR: nil,
                recommendation: "Comienza a registrar este ejercicio"
            )
        }
        
        // Calcular PRs
        let allExercises = recentSessions.flatMap { $0.performedExercises }
            .filter { $0.exerciseName == exerciseName }
        
        let maxWeight = allExercises.map { $0.maxWeight }.max() ?? 0
        let maxVolume = allExercises.map { $0.totalVolume }.max() ?? 0
        
        let lastPR = PersonalRecord(
            id: UUID(),
            exerciseName: exerciseName,
            recordType: .maxWeight,
            value: maxWeight,
            date: recentSessions.first?.date ?? Date(),
            sessionId: recentSessions.first?.id ?? UUID()
        )
        
        // Detectar estancamiento (últimas 3 semanas sin mejora)
        let calendar = Calendar.current
        let threeWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -3, to: Date()) ?? Date()
        let recentSessionsFiltered = recentSessions.filter { $0.date >= threeWeeksAgo }
        
        let isStagnant = recentSessionsFiltered.count >= 3 && 
                        recentSessionsFiltered.allSatisfy { session in
                            let exercise = session.performedExercises.first { $0.exerciseName == exerciseName }
                            return (exercise?.maxWeight ?? 0) <= maxWeight
                        }
        
        // Determinar tendencia
        let trend: ProgressAnalysis.ProgressTrend
        if recentSessions.count >= 2 {
            let oldest = recentSessions.last!
            let newest = recentSessions.first!
            
            let oldMax = oldest.performedExercises.first { $0.exerciseName == exerciseName }?.maxWeight ?? 0
            let newMax = newest.performedExercises.first { $0.exerciseName == exerciseName }?.maxWeight ?? 0
            
            if newMax > oldMax {
                trend = .improving
            } else if newMax < oldMax {
                trend = .declining
            } else {
                trend = .stable
            }
        } else {
            trend = .stable
        }
        
        // Recomendación
        let recommendation: String?
        if isStagnant {
            recommendation = "Estancado 3+ semanas. Considera cambiar estímulo o aumentar intensidad."
        } else if trend == .declining {
            recommendation = "Tendencia a la baja. Revisa técnica, descanso o nutrición."
        } else if trend == .improving {
            recommendation = "¡Buen progreso! Mantén la consistencia."
        } else {
            recommendation = nil
        }
        
        return ProgressAnalysis(
            exerciseName: exerciseName,
            isStagnant: isStagnant,
            weeksStagnant: isStagnant ? 3 : nil,
            trend: trend,
            lastPR: lastPR,
            recommendation: recommendation
        )
    }
    
    func getPersonalRecords(for exerciseName: String) -> [PersonalRecord] {
        let sessions = sessionRepository.getSessionsForExercise(exerciseName)
        let allExercises = sessions.flatMap { $0.performedExercises }
            .filter { $0.exerciseName == exerciseName }
        
        var records: [PersonalRecord] = []
        
        // PR de peso máximo
        if let maxWeightExercise = allExercises.max(by: { $0.maxWeight < $1.maxWeight }) {
            let session = sessions.first { session in
                session.performedExercises.contains { $0.id == maxWeightExercise.id }
            }
            records.append(PersonalRecord(
                id: UUID(),
                exerciseName: exerciseName,
                recordType: .maxWeight,
                value: maxWeightExercise.maxWeight,
                date: session?.date ?? Date(),
                sessionId: session?.id ?? UUID()
            ))
        }
        
        // PR de volumen
        if let maxVolumeExercise = allExercises.max(by: { $0.totalVolume < $1.totalVolume }) {
            let session = sessions.first { session in
                session.performedExercises.contains { $0.id == maxVolumeExercise.id }
            }
            records.append(PersonalRecord(
                id: UUID(),
                exerciseName: exerciseName,
                recordType: .maxVolume,
                value: maxVolumeExercise.totalVolume,
                date: session?.date ?? Date(),
                sessionId: session?.id ?? UUID()
            ))
        }
        
        return records
    }
}

