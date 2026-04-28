//
//  Models+Extensions.swift
//  APP_GYM
//
//  Extensions para modelos del dominio - Siguiendo mejores prácticas Swift
//  Referencia: https://developer.apple.com/swift/
//
//  NOTA: Este archivo extiende los tipos definidos en Models.swift
//  Asegúrate de que Models.swift esté compilado antes que este archivo

import Foundation

// MARK: - FitnessGoal Extensions
extension FitnessGoal {
    /// Calcula el progreso porcentual hacia el objetivo
    /// - Returns: Porcentaje de progreso (0-100)
    var progressPercentage: Double {
        guard targetValue != startValue else { return 0 }
        let difference = targetValue - startValue
        let currentProgress = abs(difference)
        return min(max((currentProgress / abs(difference)) * 100, 0), 100)
    }
    
    /// Verifica si el objetivo está cerca de completarse
    var isNearCompletion: Bool {
        progressPercentage >= 75
    }
    
    /// Días restantes hasta la fecha objetivo
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(components.day ?? 0, 0)
    }
}

// MARK: - WorkoutSession Extensions
extension WorkoutSession {
    /// Duración formateada como string legible
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Número total de ejercicios realizados
    var exerciseCount: Int {
        performedExercises.count
    }
    
    /// Número total de series realizadas
    var totalSets: Int {
        performedExercises.reduce(0) { $0 + $1.sets.count }
    }
}

// MARK: - PerformedExercise Extensions
extension PerformedExercise {
    /// Promedio de peso levantado en todas las series
    var averageWeight: Double {
        guard !sets.isEmpty else { return 0 }
        return sets.map { $0.weight }.reduce(0, +) / Double(sets.count)
    }
    
    /// Promedio de repeticiones por serie
    var averageReps: Double {
        guard !sets.isEmpty else { return 0 }
        return Double(totalReps) / Double(sets.count)
    }
    
    /// Intensidad relativa (promedio / máximo)
    var intensity: Double {
        guard maxWeight > 0 else { return 0 }
        return averageWeight / maxWeight
    }
}

// MARK: - Set Extensions
extension Set {
    /// Intensidad relativa (1RM estimado usando fórmula de Epley)
    var estimatedOneRM: Double {
        weight * (1 + Double(repetitions) / 30.0)
    }
    
    /// RPE estimado basado en repeticiones en reserva
    var estimatedRPE: Double {
        // Simplificación: más reps = menor RPE
        let maxReps = 12.0
        return max(10.0 - (Double(repetitions) / maxReps * 2), 6.0)
    }
}

// MARK: - PersonalRecord Extensions
extension PersonalRecord {
    /// Descripción legible del tipo de récord
    var typeDescription: String {
        switch recordType {
        case .maxWeight: return "Peso Máximo"
        case .maxReps: return "Repeticiones Máximas"
        case .maxVolume: return "Volumen Máximo"
        }
    }
    
    /// Valor formateado con unidad
    var formattedValue: String {
        switch recordType {
        case .maxWeight, .maxVolume:
            return String(format: "%.1f kg", value)
        case .maxReps:
            return String(format: "%.0f reps", value)
        }
    }
}

// MARK: - ProgressAnalysis Extensions
extension ProgressAnalysis {
    /// Mensaje de recomendación formateado
    var formattedRecommendation: String? {
        guard let recommendation = recommendation else { return nil }
        return recommendation
    }
    
    /// Icono para la tendencia
    var trendIcon: String {
        switch trend {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }
    
    /// Color para la tendencia
    var trendColor: String {
        switch trend {
        case .improving: return "green"
        case .stable: return "gray"
        case .declining: return "red"
        }
    }
}

// Las extensiones Codable ya no son necesarias ya que PersonalRecord y ProgressAnalysis
// ahora son Codable directamente en Models.swift

