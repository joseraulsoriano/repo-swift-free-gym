//
//  ErrorHandler.swift
//  APP_GYM
//
//  Componente para manejo centralizado de errores
//

import SwiftUI
import Combine

// MARK: - Error Handler Observable
class ErrorHandler: ObservableObject {
    @Published var currentError: GymAppError?
    @Published var showError: Bool = false
    
    /// Muestra un error al usuario
    func handle(_ error: Error) {
        if let gymError = error as? GymAppError {
            currentError = gymError
        } else {
            currentError = .repositoryError(error.localizedDescription)
        }
        showError = true
    }
    
    /// Muestra un error personalizado
    func show(_ error: GymAppError) {
        currentError = error
        showError = true
    }
    
    /// Limpia el error actual
    func clear() {
        currentError = nil
        showError = false
    }
}

// MARK: - Error Alert Modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: $errorHandler.showError,
                presenting: errorHandler.currentError
            ) { error in
                Button("OK") {
                    errorHandler.clear()
                }
                Button("Más información") {
                    // Mostrar información adicional si es necesario
                    errorHandler.clear()
                }
            } message: { error in
                Text(error.errorDescription ?? "Ha ocurrido un error")
            }
    }
}

// MARK: - Error Banner View
struct ErrorBannerView: View {
    let error: GymAppError
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(error.errorDescription ?? "Ha ocurrido un error")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Error Toast View
struct ErrorToastView: View {
    let error: GymAppError
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(error.errorDescription ?? "Error")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .bold()
                    
                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.red.opacity(0.95))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding()
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - View Extension para Error Handling
extension View {
    /// Agrega manejo de errores a la vista
    func errorHandling(_ errorHandler: ErrorHandler) -> some View {
        self.modifier(ErrorAlertModifier(errorHandler: errorHandler))
    }
    
    /// Muestra un banner de error
    func errorBanner(error: GymAppError?, onDismiss: @escaping () -> Void) -> some View {
        ZStack(alignment: .top) {
            self
            
            if let error = error {
                ErrorBannerView(error: error, onDismiss: onDismiss)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
    }
    
    /// Muestra un toast de error
    func errorToast(error: Binding<GymAppError?>) -> some View {
        ZStack {
            self
            
            if let currentError = error.wrappedValue {
                ErrorToastView(error: currentError, isPresented: Binding(
                    get: { error.wrappedValue != nil },
                    set: { if !$0 { error.wrappedValue = nil } }
                ))
                .zIndex(1000)
            }
        }
    }
}

