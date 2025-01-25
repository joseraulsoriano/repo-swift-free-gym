import SwiftUI

struct LoginView: View {
    @State private var matricula = "" // Variable para almacenar la matrícula
    @State private var isLoginSuccessful = false // Estado para saber si el login fue exitoso

    let correctMatricula = "202357155" // La matrícula correcta

    var body: some View {
        NavigationView {
            VStack {
                // Logo o imagen
                Image("logo_escudo 1") // Reemplazar con el nombre de la imagen
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)

                // Título
                Text("Ingreso")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 22/255, green: 58/255, blue: 89/255)) // Usando el color azul #163A59 para la letra

                // Campo para ingresar la matrícula
                TextField("Ingresa tu matrícula", text: $matricula)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .keyboardType(.numberPad)
                    .padding(.top, 30)

                // Botón para hacer login
                Button(action: {
                    // Acción de login
                    if matricula == correctMatricula {
                        // Si la matrícula es correcta, redirige a la pantalla principal
                        isLoginSuccessful = true
                    } else {
                        // Si la matrícula no es correcta, muestra un mensaje (puedes agregar más lógica aquí)
                        print("Matrícula incorrecta")
                    }
                }) {
                    Text("Iniciar sesión")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color(red: 22/255, green: 58/255, blue: 89/255)) // Usando el color azul #163A59
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)

                Spacer()

                // Redirigir a HomeView si login exitoso
                NavigationLink(destination: LocationView(), isActive: $isLoginSuccessful) {
                    EmptyView() // Aquí no mostramos nada en el enlace
                }

            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

