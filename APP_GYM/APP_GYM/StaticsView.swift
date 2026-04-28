import UIKit
import SwiftUI
import Charts

class StaticsViewController: UIViewController {
    
    var segmentedControl: UISegmentedControl!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var seriesChartView: UIView!
    var trainingDaysChartView: UIView!
    var frequencyChartView: UIView!
    var fatigueChartView: UIView!
    var emotionChartView: UIView!
    var weightChartView: UIView!
    var tableView: UITableView!
    
    var data: [String: [String: [CGFloat]]] = [:]
    var comments: [String] = []
    var recommendations: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupSegmentedControl()
        setupScrollView()
        setupChartViews()
        setupTableView()
        
        // Simulación de datos preguardados
        updateData(for: 0) // Datos del día
    }
    
    func setupSegmentedControl() {
        let items = ["Day", "Week", "Month", "Year"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.frame = CGRect(x: 20, y: 60, width: view.bounds.width - 40, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1800)
        view.addSubview(scrollView)
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1800))
        scrollView.addSubview(contentView)
    }
    
    func setupChartViews() {
        seriesChartView = createBarChartView(y: 100, label: "Series")
        trainingDaysChartView = createBarChartView(y: 300, label: "Training Days")
        frequencyChartView = createBarChartView(y: 500, label: "Frequency")
        fatigueChartView = createBarChartView(y: 700, label: "Fatigue")
        emotionChartView = createBarChartView(y: 900, label: "Emotion")
        weightChartView = createBarChartView(y: 1100, label: "Weight")
        
        contentView.addSubview(seriesChartView)
        contentView.addSubview(trainingDaysChartView)
        contentView.addSubview(frequencyChartView)
        contentView.addSubview(fatigueChartView)
        contentView.addSubview(emotionChartView)
        contentView.addSubview(weightChartView)
    }
    
    func createBarChartView(y: CGFloat, label: String) -> UIView {
        let chartWidth: CGFloat = view.bounds.width - 40
        let chartHeight: CGFloat = 150
        let chartFrame = CGRect(x: 20, y: y, width: chartWidth, height: chartHeight)
        let chartView = UIView(frame: chartFrame)
        chartView.backgroundColor = .lightGray
        
        let labelView = UILabel(frame: CGRect(x: 0, y: chartHeight - 20, width: chartWidth, height: 20))
        labelView.text = label
        labelView.textAlignment = .center
        labelView.font = UIFont.systemFont(ofSize: 12)
        chartView.addSubview(labelView)
        
        return chartView
    }
    
    func setupTableView() {
        let tableFrame = CGRect(x: 20, y: 1300, width: view.bounds.width - 40, height: 400)
        tableView = UITableView(frame: tableFrame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        contentView.addSubview(tableView)
    }
    
    @objc func segmentedControlChanged() {
        let selectedSegment = segmentedControl.selectedSegmentIndex
        updateData(for: selectedSegment)
    }
    
    func updateData(for segment: Int) {
        switch segment {
        case 0:
            // Datos del día
            data = [
                "Series": [
                    "Day": [10, 20, 15, 30, 25],
                    "Week": [100, 200, 150, 300, 250],
                    "Month": [1000, 2000, 1500, 3000, 2500],
                    "Year": [10000, 20000, 15000, 30000, 25000]
                ],
                "Training Days": [
                    "Day": [1, 1, 1, 1, 1],
                    "Week": [5, 6, 4, 7, 5],
                    "Month": [20, 25, 18, 28, 22],
                    "Year": [240, 250, 220, 280, 260]
                ],
                "Fatigue": [
                    "Day": [3, 4, 2, 5, 3],
                    "Week": [3, 2, 4, 5, 3],
                    "Month": [3, 4, 3, 5, 4],
                    "Year": [3, 4, 4, 5, 4]
                ],
                "Emotion": [
                    "Day": [4, 5, 5, 4, 5],
                    "Week": [4, 4, 5, 3, 4],
                    "Month": [4, 5, 4, 3, 4],
                    "Year": [4, 4, 5, 3, 4]
                ],
                "Weight": [
                    "Day": [70, 72, 71, 73, 72],
                    "Week": [70, 71, 70, 72, 71],
                    "Month": [69, 70, 69, 71, 70],
                    "Year": [68, 69, 68, 70, 69]
                ]
            ]
            comments = ["Good", "Tired", "Great", "Exhausted", "Motivated"]
            recommendations = ["Rest", "Hydrate", "Keep going", "Rest", "Keep up"]
        case 1:
            // Datos de la semana
            data = [
                "Series": [
                    "Day": [10, 20, 15, 30, 25],
                    "Week": [100, 200, 150, 300, 250],
                    "Month": [1000, 2000, 1500, 3000, 2500],
                    "Year": [10000, 20000, 15000, 30000, 25000]
                ],
                "Training Days": [
                    "Day": [1, 1, 1, 1, 1],
                    "Week": [5, 6, 4, 7, 5],
                    "Month": [20, 25, 18, 28, 22],
                    "Year": [240, 250, 220, 280, 260]
                ],
                "Fatigue": [
                    "Day": [3, 4, 2, 5, 3],
                    "Week": [3, 2, 4, 5, 3],
                    "Month": [3, 4, 3, 5, 4],
                    "Year": [3, 4, 4, 5, 4]
                ],
                "Emotion": [
                    "Day": [4, 5, 5, 4, 5],
                    "Week": [4, 4, 5, 3, 4],
                    "Month": [4, 5, 4, 3, 4],
                    "Year": [4, 4, 5, 3, 4]
                ],
                "Weight": [
                    "Day": [70, 72, 71, 73, 72],
                    "Week": [70, 71, 70, 72, 71],
                    "Month": [69, 70, 69, 71, 70],
                    "Year": [68, 69, 68, 70, 69]
                ]
            ]
            comments = ["Good", "Tired", "Great", "Exhausted", "Motivated"]
            recommendations = ["Rest", "Hydrate", "Keep going", "Rest", "Keep up"]
        case 2:
            // Datos del mes
            data = [
                "Series": [
                    "Day": [10, 20, 15, 30, 25],
                    "Week": [100, 200, 150, 300, 250],
                    "Month": [1000, 2000, 1500, 3000, 2500],
                    "Year": [10000, 20000, 15000, 30000, 25000]
                ],
                "Training Days": [
                    "Day": [1, 1, 1, 1, 1],
                    "Week": [5, 6, 4, 7, 5],
                    "Month": [20, 25, 18, 28, 22],
                    "Year": [240, 250, 220, 280, 260]
                ],
                "Fatigue": [
                    "Day": [3, 4, 2, 5, 3],
                    "Week": [3, 2, 4, 5, 3],
                    "Month": [3, 4, 3, 5, 4],
                    "Year": [3, 4, 4, 5, 4]
                ],
                "Emotion": [
                    "Day": [4, 5, 5, 4, 5],
                    "Week": [4, 4, 5, 3, 4],
                    "Month": [4, 5, 4, 3, 4],
                    "Year": [4, 4, 5, 3, 4]
                ],
                "Weight": [
                    "Day": [70, 72, 71, 73, 72],
                    "Week": [70, 71, 70, 72, 71],
                    "Month": [69, 70, 69, 71, 70],
                    "Year": [68, 69, 68, 70, 69]
                ]
            ]
            comments = ["Good", "Tired", "Great", "Exhausted", "Motivated"]
            recommendations = ["Rest", "Hydrate", "Keep going", "Rest", "Keep up"]
        case 3:
            // Datos del año
            data = [
                "Series": [
                    "Day": [10, 20, 15, 30, 25],
                    "Week": [100, 200, 150, 300, 250],
                    "Month": [1000, 2000, 1500, 3000, 2500],
                    "Year": [10000, 20000, 15000, 30000, 25000]
                ],
                "Training Days": [
                    "Day": [1, 1, 1, 1, 1],
                    "Week": [5, 6, 4, 7, 5],
                    "Month": [20, 25, 18, 28, 22],
                    "Year": [240, 250, 220, 280, 260]
                ],
                "Fatigue": [
                    "Day": [3, 4, 2, 5, 3],
                    "Week": [3, 2, 4, 5, 3],
                    "Month": [3, 4, 3, 5, 4],
                    "Year": [3, 4, 4, 5, 4]
                ],
                "Emotion": [
                    "Day": [4, 5, 5, 4, 5],
                    "Week": [4, 4, 5, 3, 4],
                    "Month": [4, 5, 4, 3, 4],
                    "Year": [4, 4, 5, 3, 4]
                ],
                "Weight": [
                    "Day": [70, 72, 71, 73, 72],
                    "Week": [70, 71, 70, 72, 71],
                    "Month": [69, 70, 69, 71, 70],
                    "Year": [68, 69, 68, 70, 69]
                ]
            ]
            comments = ["Good", "Tired", "Great", "Exhausted", "Motivated"]
            recommendations = ["Rest", "Hydrate", "Keep going", "Rest", "Keep up"]
        default:
            break
        }
        
        updateChartData()
        tableView.reloadData()
    }
    
    func updateChartData() {
        guard let seriesData = data["Series"]?[selectedSegmentString()],
              let trainingDaysData = data["Training Days"]?[selectedSegmentString()],
              let frequencyData = data["Frequency"]?[selectedSegmentString()],
              let fatigueData = data["Fatigue"]?[selectedSegmentString()],
              let emotionData = data["Emotion"]?[selectedSegmentString()],
              let weightData = data["Weight"]?[selectedSegmentString()] else {
            return
        }
        
        updateBarChart(chartView: seriesChartView, data: seriesData)
        updateBarChart(chartView: trainingDaysChartView, data: trainingDaysData)
        updateBarChart(chartView: frequencyChartView, data: frequencyData)
        updateBarChart(chartView: fatigueChartView, data: fatigueData)
        updateBarChart(chartView: emotionChartView, data: emotionData)
        updateBarChart(chartView: weightChartView, data: weightData)
    }
    
    func selectedSegmentString() -> String {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return "Day"
        case 1:
            return "Week"
        case 2:
            return "Month"
        case 3:
            return "Year"
        default:
            return "Day"
        }
    }
    
    func updateBarChart(chartView: UIView, data: [CGFloat]) {
        chartView.subviews.forEach { $0.removeFromSuperview() }
        
        let barWidth: CGFloat = 20
        let space: CGFloat = 10
        let maxValue = data.max() ?? 1
        
        for (index, value) in data.enumerated() {
            let barHeight = (value / maxValue) * (chartView.bounds.height - 40)
            let barX = CGFloat(index) * (barWidth + space) + space
            let barY = chartView.bounds.height - barHeight - 40
            
            let barView = UIView(frame: CGRect(x: barX, y: barY, width: barWidth, height: barHeight))
            barView.backgroundColor = .blue
            chartView.addSubview(barView)
        }
        
        let labelView = UILabel(frame: CGRect(x: 0, y: chartView.bounds.height - 20, width: chartView.bounds.width, height: 20))
        labelView.textAlignment = .center
        labelView.font = UIFont.systemFont(ofSize: 12)
        chartView.addSubview(labelView)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension StaticsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(data.keys)[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(data.keys)[section]
        return data[key]?.keys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = Array(data.keys)[indexPath.section]
        let period = Array(data[key]!.keys)[indexPath.row]
        let value = data[key]![period]!
        cell.textLabel?.text = "\(period): \(value)"
        return cell
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct StaticsViewController_Preview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            StaticsViewController()
        }
        .previewDevice("iPhone 12")
    }
}

struct ViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController
    
    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}
#endif

struct StaticsView: View {
    @StateObject private var progressManager = ProgressManager()
    @State private var selectedTimeFrame: TimeFrame = .day
    @State private var showingDetail = false
    @State private var selectedMetric: Metric?
    
    enum TimeFrame: String, CaseIterable {
        case day = "Día"
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
    }
    
    enum Metric: String, CaseIterable {
        case series = "Series"
        case trainingDays = "Días de Entrenamiento"
        case fatigue = "Fatiga"
        case emotion = "Emoción"
        case weight = "Peso"
        
        var icon: String {
            switch self {
            case .series: return "figure.walk"
            case .trainingDays: return "calendar"
            case .fatigue: return "bed.double"
            case .emotion: return "face.smiling"
            case .weight: return "scalemass"
            }
        }
        
        var color: Color {
            switch self {
            case .series: return .blue
            case .trainingDays: return .green
            case .fatigue: return .orange
            case .emotion: return .purple
            case .weight: return .red
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Selector de período
                    Picker("Período", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.rawValue).tag(timeFrame)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Gráficos
                    ForEach(Metric.allCases, id: \.self) { metric in
                        MetricCard(metric: metric, timeFrame: selectedTimeFrame, progressManager: progressManager)
                            .onTapGesture {
                                selectedMetric = metric
                                showingDetail = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
            .sheet(isPresented: $showingDetail) {
                if let metric = selectedMetric {
                    MetricDetailView(metric: metric, timeFrame: selectedTimeFrame, progressManager: progressManager)
                }
            }
        }
    }
}

struct MetricCard: View {
    let metric: StaticsView.Metric
    let timeFrame: StaticsView.TimeFrame
    @ObservedObject var progressManager: ProgressManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: metric.icon)
                    .foregroundColor(metric.color)
                Text(metric.rawValue)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            Chart {
                ForEach(getData(), id: \.date) { dataPoint in
                    LineMark(
                        x: .value("Fecha", dataPoint.date),
                        y: .value("Valor", dataPoint.value)
                    )
                    .foregroundStyle(metric.color)
                    
                    PointMark(
                        x: .value("Fecha", dataPoint.date),
                        y: .value("Valor", dataPoint.value)
                    )
                    .foregroundStyle(metric.color)
                }
            }
            .frame(height: 150)
            
            HStack {
                Text("Promedio: \(String(format: "%.1f", getAverage()))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("Tendencia: \(getTrend())")
                    .font(.caption)
                    .foregroundColor(getTrendColor())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func getData() -> [DataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var data: [DataPoint] = []
        
        // Convertir datos de ProgressManager a DataPoints
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Agrupar datos por período según timeFrame
        var groupedData: [Date: [WorkoutProgress]] = [:]
        
        for progress in progressManager.progress {
            guard let date = dateFormatter.date(from: progress.date) else { continue }
            
            let keyDate: Date
            switch timeFrame {
            case .day:
                keyDate = calendar.startOfDay(for: date)
            case .week:
                keyDate = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            case .month:
                keyDate = calendar.dateInterval(of: .month, for: date)?.start ?? date
            case .year:
                keyDate = calendar.dateInterval(of: .year, for: date)?.start ?? date
            }
            
            if groupedData[keyDate] == nil {
                groupedData[keyDate] = []
            }
            groupedData[keyDate]?.append(progress)
        }
        
        // Calcular valores según la métrica
        for (date, progresses) in groupedData.sorted(by: { $0.key < $1.key }) {
            let value: Double
            switch metric {
            case .series:
                value = Double(progresses.reduce(0) { $0 + $1.sets })
            case .trainingDays:
                value = 1.0 // Un día de entrenamiento
            case .fatigue:
                let fatigueValues: [String: Double] = ["Muy Baja": 1, "Baja": 2, "Normal": 3, "Alta": 4, "Muy Alta": 5]
                let avgFatigue = progresses.compactMap { fatigueValues[$0.fatigue] }.reduce(0.0, +) / Double(progresses.count)
                value = avgFatigue
            case .emotion:
                value = Double(progresses.reduce(0) { $0 + $1.feeling }) / Double(progresses.count)
            case .weight:
                value = progresses.map { $0.weight }.reduce(0, +) / Double(progresses.count)
            }
            
            data.append(DataPoint(date: date, value: value))
        }
        
        // Si no hay datos, retornar array vacío
        if data.isEmpty {
            return []
        }
        
        return data
    }
    
    private func getAverage() -> Double {
        let data = getData()
        return data.map { $0.value }.reduce(0, +) / Double(data.count)
    }
    
    private func getTrend() -> String {
        let data = getData()
        guard data.count >= 2 else { return "Estable" }
        
        let firstValue = data.first?.value ?? 0
        let lastValue = data.last?.value ?? 0
        let difference = lastValue - firstValue
        
        if abs(difference) < 5 {
            return "Estable"
        } else if difference > 0 {
            return "↑ Ascendente"
        } else {
            return "↓ Descendente"
        }
    }
    
    private func getTrendColor() -> Color {
        let trend = getTrend()
        switch trend {
        case "↑ Ascendente": return .green
        case "↓ Descendente": return .red
        default: return .gray
        }
    }
}

struct DataPoint {
    let date: Date
    let value: Double
}

struct MetricDetailView: View {
    let metric: StaticsView.Metric
    let timeFrame: StaticsView.TimeFrame
    @ObservedObject var progressManager: ProgressManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Gráfico detallado
                    Chart {
                        ForEach(getDetailedData(), id: \.date) { dataPoint in
                            LineMark(
                                x: .value("Fecha", dataPoint.date),
                                y: .value("Valor", dataPoint.value)
                            )
                            .foregroundStyle(metric.color)
                            
                            PointMark(
                                x: .value("Fecha", dataPoint.date),
                                y: .value("Valor", dataPoint.value)
                            )
                            .foregroundStyle(metric.color)
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    
                    // Estadísticas
                    VStack(spacing: 15) {
                        StatRow(title: "Promedio", value: String(format: "%.1f", getAverage()))
                        StatRow(title: "Máximo", value: String(format: "%.1f", getMax()))
                        StatRow(title: "Mínimo", value: String(format: "%.1f", getMin()))
                        StatRow(title: "Tendencia", value: getTrend())
                    }
                    .padding()
                    
                    // Recomendaciones
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recomendaciones")
                            .font(.headline)
                        
                        ForEach(getRecommendations(), id: \.self) { recommendation in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(recommendation)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(metric.rawValue)
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func getDetailedData() -> [DataPoint] {
        // Usar los mismos datos reales pero con más detalle
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var data: [DataPoint] = []
        var groupedData: [Date: [WorkoutProgress]] = [:]
        
        for progress in progressManager.progress {
            guard let date = dateFormatter.date(from: progress.date) else { continue }
            
            let keyDate: Date
            switch timeFrame {
            case .day:
                keyDate = calendar.startOfDay(for: date)
            case .week:
                keyDate = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            case .month:
                keyDate = calendar.dateInterval(of: .month, for: date)?.start ?? date
            case .year:
                keyDate = calendar.dateInterval(of: .year, for: date)?.start ?? date
            }
            
            if groupedData[keyDate] == nil {
                groupedData[keyDate] = []
            }
            groupedData[keyDate]?.append(progress)
        }
        
        for (date, progresses) in groupedData.sorted(by: { $0.key < $1.key }) {
            let value: Double
            switch metric {
            case .series:
                value = Double(progresses.reduce(0) { $0 + $1.sets })
            case .trainingDays:
                value = 1.0
            case .fatigue:
                let fatigueValues: [String: Double] = ["Muy Baja": 1, "Baja": 2, "Normal": 3, "Alta": 4, "Muy Alta": 5]
                let avgFatigue = progresses.compactMap { fatigueValues[$0.fatigue] }.reduce(0.0, +) / Double(progresses.count)
                value = avgFatigue
            case .emotion:
                value = Double(progresses.reduce(0) { $0 + $1.feeling }) / Double(progresses.count)
            case .weight:
                value = progresses.map { $0.weight }.reduce(0, +) / Double(progresses.count)
            }
            
            data.append(DataPoint(date: date, value: value))
        }
        
        return data
    }
    
    private func getAverage() -> Double {
        let data = getDetailedData()
        return data.map { $0.value }.reduce(0, +) / Double(data.count)
    }
    
    private func getMax() -> Double {
        return getDetailedData().map { $0.value }.max() ?? 0
    }
    
    private func getMin() -> Double {
        return getDetailedData().map { $0.value }.min() ?? 0
    }
    
    private func getTrend() -> String {
        let data = getDetailedData()
        guard data.count >= 2 else { return "Estable" }
        
        let firstValue = data.first?.value ?? 0
        let lastValue = data.last?.value ?? 0
        let difference = lastValue - firstValue
        
        if abs(difference) < 5 {
            return "Estable"
        } else if difference > 0 {
            return "↑ Ascendente"
        } else {
            return "↓ Descendente"
        }
    }
    
    private func getRecommendations() -> [String] {
        switch metric {
        case .series:
            return [
                "Aumenta gradualmente el número de series",
                "Mantén un descanso adecuado entre series",
                "Varía los ejercicios para evitar el estancamiento"
            ]
        case .trainingDays:
            return [
                "Mantén una rutina consistente",
                "Incluye días de descanso activo",
                "Planifica tus entrenamientos con anticipación"
            ]
        case .fatigue:
            return [
                "Prioriza el descanso y la recuperación",
                "Ajusta la intensidad según tu nivel de fatiga",
                "Mantén una buena hidratación"
            ]
        case .emotion:
            return [
                "Establece metas realistas y alcanzables",
                "Celebra tus logros, por pequeños que sean",
                "Mantén un diario de entrenamiento"
            ]
        case .weight:
            return [
                "Mantén un registro consistente de tu peso",
                "Considera las fluctuaciones normales",
                "Enfócate en tendencias a largo plazo"
            ]
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    StaticsView()
}
