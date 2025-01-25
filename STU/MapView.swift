import SwiftUI
import MapKit

struct Stop: Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D

    static func == (lhs: Stop, rhs: Stop) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

struct Edge {
    var source: Stop
    var destination: Stop
    var weight: Int
}

struct MapView: View {
    let stops: [Stop] = [
        Stop(name: "DAE", coordinate: CLLocationCoordinate2D(latitude: 18.9983, longitude: -98.1953)),
        Stop(name: "Cultura Física", coordinate: CLLocationCoordinate2D(latitude: 19.0004, longitude: -98.1953)),
        Stop(name: "DRH", coordinate: CLLocationCoordinate2D(latitude: 19.0019, longitude: -98.2003)),
        Stop(name: "Derecho - Administración", coordinate: CLLocationCoordinate2D(latitude: 19.0014, longitude: -98.1994)),
        Stop(name: "Rectoría", coordinate: CLLocationCoordinate2D(latitude: 19.0024, longitude: -98.2014)),
        Stop(name: "Electrónica", coordinate: CLLocationCoordinate2D(latitude: 19.0032, longitude: -98.2028)),
        Stop(name: "Computación", coordinate: CLLocationCoordinate2D(latitude: 19.0045, longitude: -98.2036)),
        Stop(name: "Puerta Av. 18 Sur", coordinate: CLLocationCoordinate2D(latitude: 19.0046, longitude: -98.2023)),
        Stop(name: "Puerta Av. 22 Sur", coordinate: CLLocationCoordinate2D(latitude: 19.0034, longitude: -98.1995)),
        Stop(name: "Puerta Calle", coordinate: CLLocationCoordinate2D(latitude: 19.0019, longitude: -98.1963)),
        Stop(name: "Puerta Cultura", coordinate: CLLocationCoordinate2D(latitude: 19.0011, longitude: -98.1946)),
        Stop(name: "Av. Central", coordinate: CLLocationCoordinate2D(latitude: 18.9981, longitude: -98.1955)),
        Stop(name: "Estadio", coordinate: CLLocationCoordinate2D(latitude: 18.9971, longitude: -98.1960)),
        Stop(name: "DASU", coordinate: CLLocationCoordinate2D(latitude: 18.9960, longitude: -98.1993)),
        Stop(name: "DCYTIC", coordinate: CLLocationCoordinate2D(latitude: 18.9951, longitude: -98.2007)),
        Stop(name: "Biblioteca Central", coordinate: CLLocationCoordinate2D(latitude: 18.9959, longitude: -98.2015)),
        Stop(name: "Hospital Multiaulas", coordinate: CLLocationCoordinate2D(latitude: 18.9974, longitude: -98.2034)),
        Stop(name: "Arena BUAP", coordinate: CLLocationCoordinate2D(latitude: 18.9996, longitude: -98.2042)),
        Stop(name: "Ingeniería/Arquitectura", coordinate: CLLocationCoordinate2D(latitude: 19.0008, longitude: -98.2028)),
        Stop(name: "Biología", coordinate: CLLocationCoordinate2D(latitude: 19.0004, longitude: -98.2008)),
        Stop(name: "Jardín Botánico", coordinate: CLLocationCoordinate2D(latitude: 18.9983, longitude: -98.1961)),
        Stop(name: "Terminal STU", coordinate: CLLocationCoordinate2D(latitude: 18.9969, longitude: -98.1960))
    ]

    let edges: [Edge] = [
        Edge(source: Stop(name: "DAE", coordinate: CLLocationCoordinate2D(latitude: 18.9983, longitude: -98.1953)),
             destination: Stop(name: "Cultura Física", coordinate: CLLocationCoordinate2D(latitude: 19.0004, longitude: -98.1953)),
             weight: 370),
        Edge(source: Stop(name: "Cultura Física", coordinate: CLLocationCoordinate2D(latitude: 19.0004, longitude: -98.1953)),
             destination: Stop(name: "DRH", coordinate: CLLocationCoordinate2D(latitude: 19.0019, longitude: -98.2003)),
             weight: 220),
        // Añadir más conexiones aquí
    ]

    @State private var selectedStop: Stop?
    @State private var region: MKCoordinateRegion
    @State private var showStopList = false

    init() {
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 18.9983, longitude: -98.1953),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: stops) { stop in
                MapAnnotation(coordinate: stop.coordinate) {
                    VStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("\(stops.firstIndex(of: stop)! + 1)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .onTapGesture {
                                selectedStop = stop
                                region = MKCoordinateRegion(
                                    center: stop.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                            }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Mapa de Paradas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)


                Spacer()

                Button(action: {
                    showStopList.toggle()
                }) {
                    Text("Seleccionar Parada")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showStopList) {
            VStack {
                Text("Selecciona una parada")
                    .font(.headline)
                    .padding()

                List(stops) { stop in
                    Button(action: {
                        selectedStop = stop
                        region = MKCoordinateRegion(
                            center: stop.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Zoom automático
                        )
                        showStopList = false
                    }) {
                        HStack {
                            Text("\(stops.firstIndex(of: stop)! + 1).")
                                .bold()
                            Text(stop.name)
                        }
                    }
                }
            }
        }
        .overlay(
            VStack {
                if let selectedStop = selectedStop {
                    Text("Parada seleccionada: \(selectedStop.name)")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding()
                }
            },
            alignment: .top
        )
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
