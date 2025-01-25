import SwiftUI

struct LocationView: View {
    @State private var isLocationActivated = false // Simula la activación de localización
    @State private var showLocationMessage = false // Controla el mensaje de activación
    @State private var isLoginSuccessful = false   // Controla la navegación

    var body: some View {
        NavigationStack { // Reemplaza NavigationView con NavigationStack
            VStack(spacing: 30) {
                // Encabezado
                VStack(spacing: 10) {
                    Image("logo_escudo 1") // Reemplazar con el nombre de la imagen
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)

                    Text("Bienvenido a la APP LOBO BUS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 22/255, green: 58/255, blue: 89/255)) // Usando el color azul #163A59 para la letra
                        .multilineTextAlignment(.center)
                }

                // Opciones de permisos
                VStack(spacing: 20) {
                    Text("Selecciona tu preferencia de localización:")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        isLocationActivated = true
                        showLocationMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showLocationMessage = false
                            isLoginSuccessful = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.white)
                            Text("Permitir siempre")
                                .font(.title3)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 22/255, green: 58/255, blue: 89/255)) // Usando el color azul #163A59
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    Button(action: {
                        isLocationActivated = true
                        showLocationMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showLocationMessage = false
                            isLoginSuccessful = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill.viewfinder")
                                .foregroundColor(.white)
                            Text("Solo con el uso de la app")
                                .font(.title3)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    Button(action: {
                        isLocationActivated = false
                        showLocationMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showLocationMessage = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                            Text("No permitir")
                                .font(.title3)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                }

                // Mensaje de activación
                if showLocationMessage {
                    Text(isLocationActivated ? "¡La localización se ha activado correctamente!" : "Has rechazado la localización.")
                        .foregroundColor(isLocationActivated ? .green : .red)
                        .padding()
                        .transition(.opacity)
                }

                // Navegación a HomeView
                NavigationLink(destination: HomeView().navigationBarBackButtonHidden(true), isActive: $isLoginSuccessful) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}


