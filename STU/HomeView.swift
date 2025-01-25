import SwiftUI
import CoreLocation
import MapKit

struct HomeView: View {
    @State private var isLoggedOut = false
    @State private var showLogoutAlert = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.0045, longitude: -98.2036), // Coordenadas de "Computación"
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Coordenada de la parada (Computación)
    let stopCoordinate = CLLocationCoordinate2D(latitude: 19.0045, longitude: -98.2036)
    
    // Simulación de una parada
    var stop = Stop(name: "Computación", coordinate: CLLocationCoordinate2D(latitude: 19.0045, longitude: -98.2036))

    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido a LoboBus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 22/255, green: 58/255, blue: 89/255))
                
                Text("Localización Activada")
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 22/255, green: 58/255, blue: 89/255))
                
                HStack {
                    Image("logo_escudo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding()
                    VStack(alignment: .leading) {
                        Text("José Raúl Soriano Cazabal")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Matrícula: 202357155")
                            .font(.body)
                            .foregroundColor(.gray)
                        Text("Facultad: Ciencias de la Computación")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    NavigationLink(destination: CaminoCortoView()) {
                        Text("Camino más corto")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color(red: 22/255, green: 58/255, blue: 89/255))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }

                    NavigationLink(destination: BusTimeView()) {
                        Text("Tiempo estimado del autobús")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color(red: 22/255, green: 58/255, blue: 89/255))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    
                    Text("Parada más cercana: Computación")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    // Mapa con la parada y un pin personalizado usando MapAnnotation
                    NavigationLink(destination: MapView()) {
                        Map(coordinateRegion: $region, annotationItems: [stop]) { stop in
                            MapAnnotation(coordinate: stop.coordinate) {
                                VStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 15, height: 15)
                                    Text("7")  // Número de la parada
                                        .foregroundColor(.black)
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Cerrar sesión")
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Confirmación"),
                            message: Text("¿Estás seguro de que deseas cerrar sesión?"),
                            primaryButton: .destructive(Text("Cerrar sesión")) {
                                isLoggedOut = true
                            },
                            secondaryButton: .cancel(Text("Cancelar"))
                        )
                    }
                }

                Spacer()

                NavigationLink(destination: LoginView(), isActive: $isLoggedOut) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarHidden(true) // Hides the back button on this view
            .navigationBarBackButtonHidden(true) // Ensure back button is hidden
        }
    }
}

