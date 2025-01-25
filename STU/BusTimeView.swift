import SwiftUI

struct BusTimeView: View {
    // Lista de paradas
    let stops = [
        "DAE", "Cultura Física", "DRH", "Derecho - Administración",
        "Rectoría", "Cs. Físico Matemáticas", "Ingeniería", "Arquitectura",
        "Biblioteca Central", "DGTIC", "Estadio", "Unidad de Seminarios",
        "Arena BUAP", "Hospital", "Jardín Botánico", "Terminal STU"
    ]
    
    @State private var currentBusStopIndex = 0 // Parada actual del autobús
    @State private var userStopIndex: Int? // Índice de la parada del usuario (será determinado por el input)
    @State private var estimatedTime: Int = 0 // Tiempo estimado en minutos
    @State private var timer: Timer? // Controlador del temporizador
    @State private var visitedStopsQueue: [Int] = [] // Cola para almacenar las paradas visitadas
    @State private var showAlert: Bool = false // Controla cuándo mostrar el alert
    
    var body: some View {
        VStack {
            // Encabezado
            VStack(spacing: 20) {
                Text("🐺 Seguimiento del LoboBus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 22/255, green: 58/255, blue: 89/255)) // Usando el color azul #163A59 para la letra

            }
            .padding(.bottom, 20)

            // Mostrar la selección de parada del usuario si no está definida
            if userStopIndex == nil {
                VStack(spacing: 15) {
                    Text("¿En qué parada te encuentras?")
                        .font(.title2)
                        .foregroundColor(.primary)

                    Picker("Selecciona tu parada", selection: $userStopIndex) {
                        ForEach(stops.indices, id: \.self) { index in
                            Text(stops[index]).tag(index as Int?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 150)
                    .padding()
                }
            } else {
                // Información del bus y usuario
                VStack(spacing: 10) {
                    infoCard(title: "Parada actual del Lobo Bus", value: stops[currentBusStopIndex], color: .red)
                    infoCard(title: "Parada donde te encuentras", value: stops[userStopIndex ?? 0], color: .green)
                    infoCard(title: "Tiempo estimado de llegada", value: "\(estimatedTime) minutos", color: .blue)
                }
                .padding(.bottom, 10)

                // Mostrar el mapa simulado
                mapView

                Spacer()
            }
        }
        .padding()
        .onAppear {
            startSimulation()
        }
        .onDisappear {
            timer?.invalidate()
        }
        // Alerta cuando el autobús esté cerca o llegue
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notificación del Lobo Bus"),
                message: Text(currentBusStopIndex == userStopIndex ? "¡El Lobo Bus ha llegado a tu parada! ¡listo para  puedas abordar!" : "¡Ya casi llega el Lobo Bus!"),
                dismissButton: .default(Text("Cerrar"))
            )
        }
    }

    // Vista para mostrar tarjetas de información
    func infoCard(title: String, value: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 1)
        )
    }

    // Vista del mapa simulado
    var mapView: some View {
        VStack {
            Text("Mapa del Recorrido")
                .font(.headline)
                .padding(.bottom, 5)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(stops.indices, id: \.self) { index in
                        HStack {
                            Text(stops[index])
                                .foregroundColor(index == currentBusStopIndex ? .red : (index == userStopIndex ?? 0 ? .green : .primary))
                                .fontWeight(index == currentBusStopIndex || index == userStopIndex ?? 0 ? .bold : .regular)

                            Spacer()

                            if index == currentBusStopIndex {
                                Text("🐺")
                            } else if index == userStopIndex {
                                Text("👤")
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(index == currentBusStopIndex ? Color.red.opacity(0.1) : (index == userStopIndex ?? 0 ? Color.green.opacity(0.1) : Color.clear))
                        .cornerRadius(10)
                    }
                }
            }
            .frame(height: 300)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
            .padding()
        }
    }

    // Iniciar la simulación del autobús
    func startSimulation() {
        updateEstimatedTime()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in // Cambia a 300 segundos (5 minutos reales)
            moveBusToNextStop()
        }
    }

    // Mover el autobús a la siguiente parada
    func moveBusToNextStop() {
        // Agregar la parada actual a la cola de paradas visitadas
        visitedStopsQueue.append(currentBusStopIndex)

        // Si la cola contiene más de una parada, eliminamos la más antigua
        if visitedStopsQueue.count > 5 { // Limitar a las últimas 5 paradas visitadas
            visitedStopsQueue.removeFirst()
        }

        if currentBusStopIndex < stops.count - 1 {
            currentBusStopIndex += 1
        } else {
            currentBusStopIndex = 0 // Reinicia al inicio del recorrido
        }
        
        updateEstimatedTime()
        sendNotifications()
    }

    // Actualizar el tiempo estimado
    func updateEstimatedTime() {
        if let userStopIndex = userStopIndex {
            if currentBusStopIndex == userStopIndex {
                estimatedTime = 0 // El autobús ya está en la parada del usuario
            } else if currentBusStopIndex < userStopIndex {
                estimatedTime = (userStopIndex - currentBusStopIndex) * 5 // Tiempo basado en la diferencia de paradas
            } else {
                let remainingStops = (stops.count - currentBusStopIndex) + userStopIndex
                estimatedTime = remainingStops * 5
            }
        }
    }

    // Enviar notificaciones simuladas
    func sendNotifications() {
        guard let userStopIndex = userStopIndex else { return }
        
        // Si el autobús está justo antes de la parada del usuario
        if currentBusStopIndex == userStopIndex - 1 {
            showAlert = true // Muestra la alerta para que el Lobo Bus está cerca
        }
        
        // Si el autobús llega a la parada del usuario
        if currentBusStopIndex == userStopIndex {
            showAlert = true // Muestra la alerta para que el Lobo Bus llegó
        }
    }
}

struct BusTimeView_Previews: PreviewProvider {
    static var previews: some View {
        BusTimeView()
    }
}
