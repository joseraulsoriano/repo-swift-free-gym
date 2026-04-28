//
//  WorkoutStreakView.swift
//  APP_GYM
//
//  Vista de racha de entrenamientos estilo Duolingo
//

import SwiftUI

struct WorkoutStreakView: View {
    @StateObject private var sessionRepo = WorkoutSessionRepository.shared
    @Environment(\.colorScheme) var colorScheme
    
    var currentStreak: Int {
        calculateStreak()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    var weeklyProgress: [Bool] {
        getWeeklyProgress()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header con racha actual
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Ícono de fuego
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.35),
                                        Color(red: 1.0, green: 0.55, blue: 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(currentStreak)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                        
                        Text("Días consecutivos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if longestStreak > currentStreak {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.35))
                        Text("Racha más larga: \(longestStreak) días")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Calendario semanal
            VStack(alignment: .leading, spacing: 15) {
                Text("Esta Semana")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                HStack(spacing: 8) {
                    ForEach(0..<7) { index in
                        DayCell(
                            dayIndex: index,
                            isCompleted: index < weeklyProgress.count ? weeklyProgress[index] : false,
                            isToday: index == getTodayIndex()
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Estadísticas adicionales
            HStack(spacing: 12) {
                StreakStatBox(
                    title: "Este mes",
                    value: "\(getMonthlySessions())",
                    subtitle: "sesiones",
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                )
                
                StreakStatBox(
                    title: "Total",
                    value: "\(sessionRepo.items.count)",
                    subtitle: "sesiones",
                    color: Color(red: 0.3, green: 0.8, blue: 0.5)
                )
            }
        }
        .padding()
        .onAppear {
            updateWidgetData()
        }
        .onChange(of: currentStreak) { _ in
            updateWidgetData()
        }
    }
    
    private func updateWidgetData() {
        WidgetDataManager.shared.saveStreakData(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            weeklyProgress: weeklyProgress
        )
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let hasSession = sessionRepo.items.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            if hasSession {
                streak += 1
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                    currentDate = calendar.startOfDay(for: previousDay)
                } else {
                    break
                }
            } else {
                // Si hoy no tiene sesión pero ayer sí, no rompe la racha
                if streak == 0 && calendar.isDateInToday(currentDate) {
                    // Verificar si ayer tuvo sesión
                    if let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                        let hadSessionYesterday = sessionRepo.items.contains { session in
                            calendar.isDate(session.date, inSameDayAs: yesterday)
                        }
                        if hadSessionYesterday {
                            // Hoy aún no ha entrenado, pero la racha sigue activa
                            break
                        }
                    }
                }
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sortedSessions = sessionRepo.items.sorted { $0.date > $1.date }
        
        guard !sortedSessions.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        var lastDate: Date? = nil
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.date)
            
            if let last = lastDate {
                let daysDifference = calendar.dateComponents([.day], from: sessionDate, to: last).day ?? 0
                
                if daysDifference == 1 {
                    // Día consecutivo
                    currentStreak += 1
                    longestStreak = max(longestStreak, currentStreak)
                } else if daysDifference > 1 {
                    // Racha rota
                    currentStreak = 1
                }
            }
            
            lastDate = sessionDate
        }
        
        return longestStreak
    }
    
    private func getWeeklyProgress() -> [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var progress: [Bool] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let hasSession = sessionRepo.items.contains { session in
                    calendar.isDate(session.date, inSameDayAs: date)
                }
                progress.insert(hasSession, at: 0)
            }
        }
        
        return progress
    }
    
    private func getTodayIndex() -> Int {
        // Hoy es el último día (índice 6)
        return 6
    }
    
    private func getMonthlySessions() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return sessionRepo.items.filter { session in
            session.date >= startOfMonth
        }.count
    }
}

struct DayCell: View {
    let dayIndex: Int
    let isCompleted: Bool
    let isToday: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var dayName: String {
        let calendar = Calendar.current
        let today = Date()
        if let date = calendar.date(byAdding: .day, value: dayIndex - 6, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date).prefix(1).uppercased()
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(dayName)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .fill(
                        isCompleted ?
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.35),
                                Color(red: 1.0, green: 0.55, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.95, green: 0.95, blue: 0.95),
                                colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(red: 0.9, green: 0.9, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else if isToday {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.55, blue: 0.25), lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct StreakStatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    WorkoutStreakView()
        .environmentObject(ErrorHandler())
        .environmentObject(NotificationManager())
}

