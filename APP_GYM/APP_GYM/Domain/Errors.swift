//
//  Errors.swift
//  APP_GYM
//
//  Tipos de error personalizados - Siguiendo mejores prácticas Swift
//  Referencia: https://developer.apple.com/swift/
//

import Foundation

// MARK: - Errores del Dominio
enum GymAppError: LocalizedError {
    case repositoryError(String)
    case invalidData(String)
    case notFound(String)
    case persistenceError(String)
    
    var errorDescription: String? {
        switch self {
        case .repositoryError(let message):
            return "Error en repositorio: \(message)"
        case .invalidData(let message):
            return "Datos inválidos: \(message)"
        case .notFound(let message):
            return "No encontrado: \(message)"
        case .persistenceError(let message):
            return "Error de persistencia: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .repositoryError:
            return "No se pudo realizar la operación en el repositorio"
        case .invalidData:
            return "Los datos proporcionados no son válidos"
        case .notFound:
            return "El recurso solicitado no existe"
        case .persistenceError:
            return "No se pudo guardar o cargar los datos"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .repositoryError:
            return "Verifica la conexión y vuelve a intentar"
        case .invalidData:
            return "Revisa los datos ingresados y corrígelos"
        case .notFound:
            return "El elemento puede haber sido eliminado o no existe"
        case .persistenceError:
            return "Verifica el espacio de almacenamiento disponible"
        }
    }
}

// MARK: - Result Type Helper
typealias RepositoryResult<T> = Result<T, GymAppError>



