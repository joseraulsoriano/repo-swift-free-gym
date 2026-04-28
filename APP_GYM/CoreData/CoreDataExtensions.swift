//
//  CoreDataExtensions.swift
//  APP_GYM
//
//  Extensiones para convertir entre Core Data y modelos de dominio
//

import Foundation
import CoreData

// MARK: - CDWorkoutSession Extensions
extension CDWorkoutSession {
    func toWorkoutSession() -> WorkoutSession {
        var performedExercises: [PerformedExercise] = []
        if let exercises = self.performedExercises as? Swift.Set<CDPerformedExercise> {
            performedExercises = exercises.compactMap { $0.toPerformedExercise() }
                .sorted { $0.order < $1.order }
        }
        
        return WorkoutSession(
            id: self.id ?? UUID(),
            routineId: self.routineId,
            date: self.date ?? Date(),
            duration: self.duration > 0 ? self.duration : nil,
            performedExercises: performedExercises
        )
    }
    
    func update(from session: WorkoutSession) {
        self.id = session.id
        self.routineId = session.routineId
        self.date = session.date
        self.duration = session.duration ?? 0
        
        // Eliminar ejercicios existentes
        if let exercises = self.performedExercises as? Swift.Set<CDPerformedExercise> {
            exercises.forEach { managedObjectContext?.delete($0) }
        }
        
        // Agregar nuevos ejercicios
        for (index, exercise) in session.performedExercises.enumerated() {
            let cdExercise = CDPerformedExercise(context: self.managedObjectContext!)
            cdExercise.update(from: exercise)
            cdExercise.order = Int32(index)
            self.addToPerformedExercises(cdExercise)
        }
    }
}

// MARK: - CDPerformedExercise Extensions
extension CDPerformedExercise {
    func toPerformedExercise() -> PerformedExercise {
        var sets: [Set] = []
        if let cdSets = self.sets as? Swift.Set<CDSet> {
            sets = cdSets.compactMap { $0.toSet() }
                .sorted { $0.order < $1.order }
        }
        
        return PerformedExercise(
            id: self.id ?? UUID(),
            sessionId: self.sessionId ?? UUID(),
            exerciseName: self.exerciseName ?? "",
            sets: sets,
            order: Int(self.order)
        )
    }
    
    func update(from exercise: PerformedExercise) {
        self.id = exercise.id
        self.sessionId = exercise.sessionId
        self.exerciseName = exercise.exerciseName
        self.order = Int32(exercise.order)
        
        // Eliminar series existentes
        if let sets = self.sets as? Swift.Set<CDSet> {
            sets.forEach { managedObjectContext?.delete($0) }
        }
        
        // Agregar nuevas series
        for (index, set) in exercise.sets.enumerated() {
            let cdSet = CDSet(context: self.managedObjectContext!)
            cdSet.update(from: set)
            cdSet.order = Int32(index)
            self.addToSets(cdSet)
        }
    }
}

// MARK: - CDSet Extensions
extension CDSet {
    func toSet() -> Set {
        return Set(
            id: self.id ?? UUID(),
            performedExerciseId: self.performedExerciseId ?? UUID(),
            weight: self.weight,
            repetitions: Int(self.repetitions),
            restTime: self.restTime > 0 ? Int(self.restTime) : nil,
            order: Int(self.order)
        )
    }
    
    func update(from set: Set) {
        self.id = set.id
        self.performedExerciseId = set.performedExerciseId
        self.weight = set.weight
        self.repetitions = Int32(set.repetitions)
        self.restTime = set.restTime != nil ? Int32(set.restTime!) : 0
        self.order = Int32(set.order)
    }
}

// MARK: - CDFitnessGoal Extensions
extension CDFitnessGoal {
    func toFitnessGoal() -> FitnessGoal {
        return FitnessGoal(
            id: self.id ?? UUID(),
            userId: self.userId ?? UUID(),
            type: GoalType(rawValue: self.type ?? "fuerza") ?? .strength,
            metric: GoalMetric(rawValue: self.metric ?? "kg") ?? .kilograms,
            exerciseName: self.exerciseName,
            startValue: self.startValue,
            targetValue: self.targetValue,
            startDate: self.startDate ?? Date(),
            targetDate: self.targetDate ?? Date(),
            isActive: self.isActive
        )
    }
    
    func update(from goal: FitnessGoal) {
        self.id = goal.id
        self.userId = goal.userId
        self.type = goal.type.rawValue
        self.metric = goal.metric.rawValue
        self.exerciseName = goal.exerciseName
        self.startValue = goal.startValue
        self.targetValue = goal.targetValue
        self.startDate = goal.startDate
        self.targetDate = goal.targetDate
        self.isActive = goal.isActive
    }
}

// MARK: - CDRoutine Extensions
extension CDRoutine {
    func toRoutine() -> Routine {
        var exercises: [RoutineExercise] = []
        if let cdExercises = self.exercises as? Swift.Set<CDRoutineExercise> {
            exercises = cdExercises.compactMap { $0.toRoutineExercise() }
                .sorted { $0.order < $1.order }
        }
        
        return Routine(
            id: self.id ?? UUID(),
            userId: self.userId ?? UUID(),
            name: self.name ?? "",
            daysPerWeek: Int(self.daysPerWeek),
            exercises: exercises
        )
    }
    
    func update(from routine: Routine) {
        self.id = routine.id
        self.userId = routine.userId
        self.name = routine.name
        self.daysPerWeek = Int32(routine.daysPerWeek)
        
        // Eliminar ejercicios existentes
        if let exercises = self.exercises as? Swift.Set<CDRoutineExercise> {
            exercises.forEach { managedObjectContext?.delete($0) }
        }
        
        // Agregar nuevos ejercicios
        for (index, exercise) in routine.exercises.enumerated() {
            let cdExercise = CDRoutineExercise(context: self.managedObjectContext!)
            cdExercise.update(from: exercise)
            cdExercise.order = Int32(index)
            self.addToExercises(cdExercise)
        }
    }
}

// MARK: - CDRoutineExercise Extensions
extension CDRoutineExercise {
    func toRoutineExercise() -> RoutineExercise {
        return RoutineExercise(
            id: self.id ?? UUID(),
            exerciseName: self.exerciseName ?? "",
            targetSets: Int(self.targetSets),
            targetReps: self.targetReps ?? "10",
            order: Int(self.order)
        )
    }
    
    func update(from exercise: RoutineExercise) {
        self.id = exercise.id
        self.exerciseName = exercise.exerciseName
        self.targetSets = Int32(exercise.targetSets)
        self.targetReps = exercise.targetReps
        self.order = Int32(exercise.order)
    }
}

// MARK: - CDBodyMetric Extensions
extension CDBodyMetric {
    func toBodyMetric() -> BodyMetric {
        return BodyMetric(
            id: self.id ?? UUID(),
            userId: self.userId ?? UUID(),
            type: BodyMetricType(rawValue: self.type ?? "peso") ?? .weight,
            value: self.value > 0 ? self.value : nil,
            photoPath: self.photoPath,
            date: self.date ?? Date()
        )
    }
    
    func update(from metric: BodyMetric) {
        self.id = metric.id
        self.userId = metric.userId
        self.type = metric.type.rawValue
        self.value = metric.value ?? 0
        self.photoPath = metric.photoPath
        self.date = metric.date
    }
}



