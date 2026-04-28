//
//  CoreDataRepositories.swift
//  APP_GYM
//
//  Repositorios usando Core Data + CloudKit
//

import Foundation
import CoreData
import Combine

// MARK: - Repositorio Base con Core Data
class CoreDataRepository<T: NSManagedObject>: ObservableObject {
    let context: NSManagedObjectContext
    @Published var items: [T] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        load()
        
        // Observar cambios en Core Data
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.load()
        }
    }
    
    func load() {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.sortDescriptors = []
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error cargando datos: \(error)")
            items = []
        }
    }
    
    func save() {
        do {
            try context.save()
            load()
        } catch {
            print("Error guardando: \(error)")
        }
    }
}

// MARK: - Repositorio de Sesiones de Entrenamiento
class CloudWorkoutSessionRepository: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var items: [WorkoutSession] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        load()
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.load()
        }
    }
    
    static let shared = CloudWorkoutSessionRepository()
    
    func load() {
        let request = NSFetchRequest<CDWorkoutSession>(entityName: "CDWorkoutSession")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let cdSessions = try context.fetch(request)
            items = cdSessions.map { $0.toWorkoutSession() }
        } catch {
            print("Error cargando sesiones: \(error)")
            items = []
        }
    }
    
    func save(_ session: WorkoutSession) {
        let request = NSFetchRequest<CDWorkoutSession>(entityName: "CDWorkoutSession")
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            let existing = try context.fetch(request).first
            
            let cdSession: CDWorkoutSession
            if let existing = existing {
                cdSession = existing
            } else {
                cdSession = CDWorkoutSession(context: context)
                cdSession.id = session.id
            }
            
            cdSession.update(from: session)
            
            try context.save()
            load()
        } catch {
            print("Error guardando sesión: \(error)")
        }
    }
    
    func delete(_ session: WorkoutSession) {
        let request = NSFetchRequest<CDWorkoutSession>(entityName: "CDWorkoutSession")
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        do {
            if let cdSession = try context.fetch(request).first {
                context.delete(cdSession)
                try context.save()
                load()
            }
        } catch {
            print("Error eliminando sesión: \(error)")
        }
    }
    
    func getSessionsForExercise(_ exerciseName: String) -> [WorkoutSession] {
        items.filter { session in
            session.performedExercises.contains { $0.exerciseName == exerciseName }
        }
    }
    
    func getRecentSessions(limit: Int = 10) -> [WorkoutSession] {
        Array(items.prefix(limit))
    }
    
    func getSessionsInDateRange(from: Date, to: Date) -> [WorkoutSession] {
        items.filter { session in
            session.date >= from && session.date <= to
        }
    }
}

// MARK: - Repositorio de Objetivos
class CloudGoalRepository: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var items: [FitnessGoal] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        load()
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.load()
        }
    }
    
    static let shared = CloudGoalRepository()
    
    func load() {
        let request = NSFetchRequest<CDFitnessGoal>(entityName: "CDFitnessGoal")
        request.sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: true)]
        
        do {
            let cdGoals = try context.fetch(request)
            items = cdGoals.map { $0.toFitnessGoal() }
        } catch {
            print("Error cargando objetivos: \(error)")
            items = []
        }
    }
    
    func save(_ goal: FitnessGoal) {
        let request = NSFetchRequest<CDFitnessGoal>(entityName: "CDFitnessGoal")
        request.predicate = NSPredicate(format: "id == %@", goal.id as CVarArg)
        
        do {
            let existing = try context.fetch(request).first
            
            let cdGoal: CDFitnessGoal
            if let existing = existing {
                cdGoal = existing
            } else {
                cdGoal = CDFitnessGoal(context: context)
                cdGoal.id = goal.id
            }
            
            cdGoal.update(from: goal)
            
            try context.save()
            load()
        } catch {
            print("Error guardando objetivo: \(error)")
        }
    }
    
    func delete(_ goal: FitnessGoal) {
        let request = NSFetchRequest<CDFitnessGoal>(entityName: "CDFitnessGoal")
        request.predicate = NSPredicate(format: "id == %@", goal.id as CVarArg)
        
        do {
            if let cdGoal = try context.fetch(request).first {
                context.delete(cdGoal)
                try context.save()
                load()
            }
        } catch {
            print("Error eliminando objetivo: \(error)")
        }
    }
    
    func getActiveGoals() -> [FitnessGoal] {
        items.filter { $0.isActive }
    }
    
    func getGoalsForExercise(_ exerciseName: String) -> [FitnessGoal] {
        items.filter { goal in
            goal.isActive && goal.exerciseName == exerciseName
        }
    }
}

// MARK: - Repositorio de Rutinas
class CloudRoutineRepository: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var items: [Routine] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        load()
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.load()
        }
    }
    
    static let shared = CloudRoutineRepository()
    
    func load() {
        let request = NSFetchRequest<CDRoutine>(entityName: "CDRoutine")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let cdRoutines = try context.fetch(request)
            items = cdRoutines.map { $0.toRoutine() }
        } catch {
            print("Error cargando rutinas: \(error)")
            items = []
        }
    }
    
    func save(_ routine: Routine) {
        let request = NSFetchRequest<CDRoutine>(entityName: "CDRoutine")
        request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)
        
        do {
            let existing = try context.fetch(request).first
            
            let cdRoutine: CDRoutine
            if let existing = existing {
                cdRoutine = existing
            } else {
                cdRoutine = CDRoutine(context: context)
                cdRoutine.id = routine.id
            }
            
            cdRoutine.update(from: routine)
            
            try context.save()
            load()
        } catch {
            print("Error guardando rutina: \(error)")
        }
    }
    
    func delete(_ routine: Routine) {
        let request = NSFetchRequest<CDRoutine>(entityName: "CDRoutine")
        request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)
        
        do {
            if let cdRoutine = try context.fetch(request).first {
                context.delete(cdRoutine)
                try context.save()
                load()
            }
        } catch {
            print("Error eliminando rutina: \(error)")
        }
    }
    
    func getActiveRoutine() -> Routine? {
        items.first
    }
}

// MARK: - Repositorio de Métricas Corporales
class CloudBodyMetricRepository: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var items: [BodyMetric] = []
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        load()
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.load()
        }
    }
    
    static let shared = CloudBodyMetricRepository()
    
    func load() {
        let request = NSFetchRequest<CDBodyMetric>(entityName: "CDBodyMetric")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let cdMetrics = try context.fetch(request)
            items = cdMetrics.map { $0.toBodyMetric() }
        } catch {
            print("Error cargando métricas: \(error)")
            items = []
        }
    }
    
    func save(_ metric: BodyMetric) {
        let request = NSFetchRequest<CDBodyMetric>(entityName: "CDBodyMetric")
        request.predicate = NSPredicate(format: "id == %@", metric.id as CVarArg)
        
        do {
            let existing = try context.fetch(request).first
            
            let cdMetric: CDBodyMetric
            if let existing = existing {
                cdMetric = existing
            } else {
                cdMetric = CDBodyMetric(context: context)
                cdMetric.id = metric.id
            }
            
            cdMetric.update(from: metric)
            
            try context.save()
            load()
        } catch {
            print("Error guardando métrica: \(error)")
        }
    }
    
    func delete(_ metric: BodyMetric) {
        let request = NSFetchRequest<CDBodyMetric>(entityName: "CDBodyMetric")
        request.predicate = NSPredicate(format: "id == %@", metric.id as CVarArg)
        
        do {
            if let cdMetric = try context.fetch(request).first {
                context.delete(cdMetric)
                try context.save()
                load()
            }
        } catch {
            print("Error eliminando métrica: \(error)")
        }
    }
    
    func getMetricsByType(_ type: BodyMetricType) -> [BodyMetric] {
        items.filter { $0.type == type }.sorted { $0.date > $1.date }
    }
    
    func getLatestMetric(_ type: BodyMetricType) -> BodyMetric? {
        getMetricsByType(type).first
    }
}



