//
//  Models.swift
//  APP_GYM
//
//  Domain Models - Conceptos del dominio del gimnasio
//

import Foundation

// MARK: - Usuario
struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Objetivo
enum GoalType: String, Codable {
    case strength = "fuerza"      // Aumentar peso en ejercicio
    case mass = "masa"            // Ganar masa muscular
    case weight = "peso"          // Bajar/subir peso corporal
    case habit = "hábito"         // Consistencia (sesiones/semana)
}

enum GoalMetric: String, Codable {
    case kilograms = "kg"
    case repetitions = "reps"
    case percentage = "%"
    case sessions = "sesiones"
}

struct FitnessGoal: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var type: GoalType
    var metric: GoalMetric
    var exerciseName: String?      // Para objetivos de fuerza
    var startValue: Double
    var targetValue: Double
    var startDate: Date
    var targetDate: Date
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: GoalType,
        metric: GoalMetric,
        exerciseName: String? = nil,
        startValue: Double,
        targetValue: Double,
        startDate: Date = Date(),
        targetDate: Date,
        isActive: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.metric = metric
        self.exerciseName = exerciseName
        self.startValue = startValue
        self.targetValue = targetValue
        self.startDate = startDate
        self.targetDate = targetDate
        self.isActive = isActive
    }
    
    var progress: Double {
        guard targetValue != startValue else { return 0 }
        return (targetValue - startValue) / abs(targetValue - startValue) * 100
    }
}

// MARK: - Rutina
struct Routine: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var name: String
    var daysPerWeek: Int
    var exercises: [RoutineExercise]  // Ejercicios base de la rutina
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        name: String,
        daysPerWeek: Int = 3,
        exercises: [RoutineExercise] = []
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.daysPerWeek = daysPerWeek
        self.exercises = exercises
    }
}

struct RoutineExercise: Identifiable, Codable {
    let id: UUID
    var exerciseName: String
    var targetSets: Int
    var targetReps: String  // "8-10" o "12"
    var order: Int          // Orden en la rutina
    
    init(
        id: UUID = UUID(),
        exerciseName: String,
        targetSets: Int = 3,
        targetReps: String = "10",
        order: Int = 0
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.order = order
    }
}

// MARK: - Sesión de Entrenamiento
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let routineId: UUID?
    var date: Date
    var duration: TimeInterval?  // en segundos
    var performedExercises: [PerformedExercise]
    
    init(
        id: UUID = UUID(),
        routineId: UUID? = nil,
        date: Date = Date(),
        duration: TimeInterval? = nil,
        performedExercises: [PerformedExercise] = []
    ) {
        self.id = id
        self.routineId = routineId
        self.date = date
        self.duration = duration
        self.performedExercises = performedExercises
    }
    
    var totalVolume: Double {
        performedExercises.reduce(0) { total, exercise in
            total + exercise.totalVolume
        }
    }
}

// MARK: - Ejercicio Realizado (en una sesión)
struct PerformedExercise: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    var exerciseName: String
    var sets: [Set]
    var order: Int
    
    init(
        id: UUID = UUID(),
        sessionId: UUID,
        exerciseName: String,
        sets: [Set] = [],
        order: Int = 0
    ) {
        self.id = id
        self.sessionId = sessionId
        self.exerciseName = exerciseName
        self.sets = sets
        self.order = order
    }
    
    var totalVolume: Double {
        sets.reduce(0) { total, set in
            total + (set.weight * Double(set.repetitions))
        }
    }
    
    var maxWeight: Double {
        sets.map { $0.weight }.max() ?? 0
    }
    
    var totalReps: Int {
        sets.reduce(0) { $0 + $1.repetitions }
    }
}

// MARK: - Serie
struct Set: Identifiable, Codable {
    let id: UUID
    let performedExerciseId: UUID
    var weight: Double      // en kg
    var repetitions: Int
    var restTime: Int?      // en segundos (opcional)
    var order: Int          // orden de la serie
    
    init(
        id: UUID = UUID(),
        performedExerciseId: UUID,
        weight: Double,
        repetitions: Int,
        restTime: Int? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.performedExerciseId = performedExerciseId
        self.weight = weight
        self.repetitions = repetitions
        self.restTime = restTime
        self.order = order
    }
    
    var volume: Double {
        weight * Double(repetitions)
    }
}

// MARK: - Métrica Corporal
enum BodyMetricType: String, Codable {
    case weight = "peso"
    case waist = "cintura"
    case chest = "pecho"
    case arm = "brazo"
    case photo = "foto"
}

struct BodyMetric: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var type: BodyMetricType
    var value: Double?       // Para medidas numéricas
    var photoPath: String?   // Para fotos
    var date: Date
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        type: BodyMetricType,
        value: Double? = nil,
        photoPath: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.value = value
        self.photoPath = photoPath
        self.date = date
    }
}

// MARK: - Personal Record (PR)
struct PersonalRecord: Identifiable, Codable {
    let id: UUID
    let exerciseName: String
    let recordType: PRType
    let value: Double
    let date: Date
    let sessionId: UUID
    
    enum PRType: String, Codable {
        case maxWeight      // Mayor peso levantado
        case maxReps        // Mayor repeticiones
        case maxVolume      // Mayor volumen total
    }
}

// MARK: - Análisis de Progreso
struct ProgressAnalysis: Codable {
    let exerciseName: String
    let isStagnant: Bool
    let weeksStagnant: Int?
    let trend: ProgressTrend
    let lastPR: PersonalRecord?
    let recommendation: String?
    
    enum ProgressTrend: String, Codable {
        case improving      // Subiendo
        case stable        // Se mantiene
        case declining     // Bajando
    }
}

