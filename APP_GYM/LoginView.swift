import SwiftUI
import AuthenticationServices
#if os(macOS)
import AppKit
#endif

struct LoginView: View {
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            // Fondo degradado naranja tenue
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.85, blue: 0.7),  // Naranja muy claro
                    Color(red: 1.0, green: 0.75, blue: 0.5)   // Naranja claro
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Logo/Ícono
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.4),
                                        Color(red: 1.0, green: 0.6, blue: 0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "figure.strengthtraining.traditional")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    
                    // Título y subtítulo
                    VStack(spacing: 8) {
                        Text("APP_GYM")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                        
                        Text("Tu compañero de entrenamiento")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.1))
                    }
                    .padding(.bottom, 40)
                    
                    // Botón Sign in with Apple
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleSignInWithApple(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 40)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.5, blue: 0.3).opacity(0.3))
                            .frame(height: 1)
                        
                        Text("o")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.1))
                            .padding(.horizontal, 12)
                        
                        Rectangle()
                            .fill(Color(red: 0.8, green: 0.5, blue: 0.3).opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    
                    // Botón de acceso rápido (demo)
                    Button(action: {
                        quickLogin()
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16))
                            Text("Acceso Rápido")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
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
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .disabled(isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.8, green: 0.4, blue: 0.1)))
                            .scaleEffect(1.2)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .errorHandling(errorHandler)
        .notifications(notificationManager)
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // Obtener información del usuario
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // Guardar información del usuario (aquí podrías guardar en UserDefaults o Keychain)
                if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
                    let displayName = "\(givenName) \(familyName)"
                    UserDefaults.standard.set(displayName, forKey: "userDisplayName")
                }
                
                if let email = email {
                    UserDefaults.standard.set(email, forKey: "userEmail")
                }
                
                UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
                
                // Iniciar sesión
                DispatchQueue.main.async {
                    isUserLoggedIn = true
                    notificationManager.success("¡Bienvenido!", message: "Sesión iniciada con Apple")
                }
            }
            
        case .failure(let error):
            DispatchQueue.main.async {
                isLoading = false
                
                if let authError = error as? ASAuthorizationError {
                    switch authError.code {
                    case .canceled:
                        // Usuario canceló, no mostrar error
                        break
                    case .failed:
                        errorHandler.show(.repositoryError("Error al iniciar sesión. Por favor, intenta nuevamente."))
                    case .invalidResponse:
                        errorHandler.show(.repositoryError("Respuesta inválida del servidor. Verifica tu conexión."))
                    case .notHandled:
                        // Este es el error más común - falta configuración
                        let errorMsg = """
                        Sign in with Apple no está configurado correctamente.
                        
                        Pasos para solucionarlo:
                        1. En Xcode, ve a "Signing & Capabilities"
                        2. Haz clic en "+ Capability"
                        3. Agrega "Sign in with Apple"
                        4. Limpia el build (Product → Clean Build Folder)
                        5. Reconstruye el proyecto
                        """
                        errorHandler.show(.repositoryError(errorMsg))
                    case .unknown:
                        // Error desconocido - puede ser por configuración
                        let errorMsg = """
                        Error de configuración detectado.
                        
                        Verifica en Xcode:
                        • Bundle ID configurado (General → Bundle Identifier)
                        • Capability "Sign in with Apple" agregada
                        • Archivo .entitlements en el target
                        
                        Luego limpia y reconstruye el proyecto.
                        """
                        errorHandler.show(.repositoryError(errorMsg))
                    @unknown default:
                        errorHandler.show(.repositoryError("Error al iniciar sesión: \(authError.localizedDescription)"))
                    }
                } else {
                    let errorMessage = error.localizedDescription.lowercased()
                    if errorMessage.contains("entitlements") || 
                       errorMessage.contains("capability") || 
                       errorMessage.contains("bundle") ||
                       errorMessage.contains("provisioning") {
                        let errorMsg = """
                        Configuración faltante detectada.
                        
                        En Xcode:
                        1. Target "APP_GYM" → "Signing & Capabilities"
                        2. Agrega capability "Sign in with Apple"
                        3. Verifica que el Bundle ID sea válido
                        4. Limpia y reconstruye (⌘+Shift+K, luego ⌘+B)
                        """
                        errorHandler.show(.repositoryError(errorMsg))
                    } else {
                        errorHandler.show(.repositoryError("Error al iniciar sesión: \(error.localizedDescription)"))
                    }
                }
            }
        }
    }
    
    private func quickLogin() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isUserLoggedIn = true
            notificationManager.success("¡Bienvenido!", message: "Modo de demostración activado")
            isLoading = false
        }
    }
}

// RegistrationView ya no es necesaria con Sign in with Apple
// Se mantiene por si se necesita en el futuro
struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.35))
                
                Text("Registro")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                Text("Usa 'Iniciar sesión con Apple' para crear tu cuenta de forma rápida y segura")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Registro")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
}

#Preview {
    LoginView(isUserLoggedIn: .constant(false))
}
