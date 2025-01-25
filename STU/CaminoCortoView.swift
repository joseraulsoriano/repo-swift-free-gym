import SwiftUI

struct CaminoCortoView: View {
    // Lista de paradas de autobús
    let stops = [
        "DAE", "Cultura Física", "DRH", "Derecho - Administración",
        "Rectoría", "Cs. Físico Matemáticas", "Ingeniería", "Arquitectura",
        "Biblioteca Central", "DGTIC", "Estadio", "Unidad de Seminarios",
        "Arena BUAP", "Hospital", "Jardín Botánico", "Terminal STU"
    ]
    
    // Grafo representado por un diccionario de adyacencia
    let graph: [Int: [Int]] = [
        0: [1], 1: [0, 2], 2: [1, 3], 3: [2, 4], 4: [3, 5],
        5: [4, 6], 6: [5, 7], 7: [6, 8], 8: [7, 9], 9: [8, 10],
        10: [9, 11], 11: [10, 12], 12: [11, 13], 13: [12, 14],
        14: [13]
    ]
    
    @State private var startStopIndex: Int?
    @State private var endStopIndex: Int?
    @State private var shortestRoute: [String] = []
    
    @State private var selectedStartStop = "DAE"
    @State private var selectedEndStop = "Terminal STU"
    
    var body: some View {
        NavigationView {
            VStack {
                // Título
                VStack(spacing: 10) {
                    Text("👣 Camino Más Corto")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Selecciona la parada de inicio y la parada de destino para calcular la ruta más corta.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Entrada de la parada de inicio
                VStack(spacing: 15) {
                    Text("¿Desde qué parada quieres iniciar?")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Picker("Selecciona la parada de inicio", selection: $selectedStartStop) {
                        ForEach(stops, id: \.self) { stop in
                            Text(stop)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder())
                    .padding(.horizontal)
                }
                
                // Entrada de la parada de destino
                VStack(spacing: 15) {
                    Text("¿A qué parada deseas llegar?")
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Picker("Selecciona la parada de destino", selection: $selectedEndStop) {
                        ForEach(stops, id: \.self) { stop in
                            Text(stop)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder())
                    .padding(.horizontal)
                }
                
                // Botón para calcular la ruta más corta
                Button(action: {
                    calculateShortestRoute()
                }) {
                    Text("Calcular Ruta Más Corta")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                // Mostrar la ruta más corta
                if !shortestRoute.isEmpty {
                    VStack(spacing: 10) {
                        Text("Ruta más corta:")
                            .font(.title2)
                            .foregroundColor(.primary)
                        
                        ForEach(shortestRoute, id: \.self) { stop in
                            Text(stop)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Botón para ir al MapView
                if !shortestRoute.isEmpty {
                    NavigationLink(destination: MapView()) {
                        Text("Ver Mapa")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // Función para calcular la ruta más corta usando el algoritmo de Dijkstra
    func calculateShortestRoute() {
        guard let startIndex = stops.firstIndex(of: selectedStartStop),
              let endIndex = stops.firstIndex(of: selectedEndStop) else {
            return
        }
        
        startStopIndex = startIndex
        endStopIndex = endIndex
        
        // Llamar al algoritmo de Dijkstra para calcular la ruta más corta
        let route = dijkstra(start: startIndex, end: endIndex)
        shortestRoute = route.map { stops[$0] } // Convertir los índices a nombres de paradas
    }
    
    // Algoritmo de Dijkstra para encontrar el camino más corto
    func dijkstra(start: Int, end: Int) -> [Int] {
        var distances = [Int: Int]()
        var previousStops = [Int: Int]()
        var unvisitedStops = Set(stops.indices)
        
        for stop in stops.indices {
            distances[stop] = Int.max
        }
        distances[start] = 0
        
        while !unvisitedStops.isEmpty {
            let currentStop = unvisitedStops.min { distances[$0]! < distances[$1]! }!
            unvisitedStops.remove(currentStop)
            
            if currentStop == end {
                var path = [currentStop]
                var previousStop = previousStops[currentStop]
                
                while let prev = previousStop {
                    path.insert(prev, at: 0)
                    previousStop = previousStops[prev]
                }
                return path
            }
            
            for neighbor in graph[currentStop] ?? [] {
                let newDistance = distances[currentStop]! + 1
                if newDistance < distances[neighbor]! {
                    distances[neighbor] = newDistance
                    previousStops[neighbor] = currentStop
                }
            }
        }
        
        return []
    }
}

