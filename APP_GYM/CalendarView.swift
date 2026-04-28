import SwiftUI
import UserNotifications

// Modelo de datos para el día del calendario
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
}

class CalendarViewModel: ObservableObject {
    @Published var days: [CalendarDay] = []
    @Published var selectedDay: CalendarDay?
    @Published var currentMonth: Date = Date() {
        didSet {
            loadCurrentMonth()
        }
    }
    
    init() {
        loadCurrentMonth()
    }
    
    func loadCurrentMonth() {
        days.removeAll()
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let month = calendar.component(.month, from: currentMonth)
        let year = calendar.component(.year, from: currentMonth)
        
        days = range.compactMap { day -> CalendarDay? in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return CalendarDay(date: calendar.date(from: components)!)
        }
    }
}

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Calendar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                HStack {
                    Button(action: {
                        viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.currentMonth) ?? Date()
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text(monthYearFormatted(viewModel.currentMonth))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.currentMonth) ?? Date()
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.days) { day in
                        Text(dayFormatted(day.date))
                            .frame(width: 40, height: 40)
                            .background(dayBackground(day))
                            .cornerRadius(8)
                            .onTapGesture {
                                viewModel.selectedDay = day
                            }
                    }
                }
                .padding()
                
                if let selectedDay = viewModel.selectedDay {
                    Text("Selected Date: \(detailedDateFormatted(selectedDay.date))")
                        .padding()
                }
            }
            .padding()
        }
    }
    
    private func dayFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func detailedDateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func monthYearFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayBackground(_ day: CalendarDay) -> Color {
        let today = Calendar.current.startOfDay(for: Date())
        let dayDate = Calendar.current.startOfDay(for: day.date)
        
        if dayDate == today {
            return Color.orange
        } else if let selectedDay = viewModel.selectedDay, selectedDay.id == day.id {
            return Color.blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
