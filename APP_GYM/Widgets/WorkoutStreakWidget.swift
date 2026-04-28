//
//  WorkoutStreakWidget.swift
//  APP_GYM
//
//  Widget para mostrar la racha de entrenamientos
//

import WidgetKit
import SwiftUI

struct WorkoutStreakWidget: Widget {
    let kind: String = "WorkoutStreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Racha de Entrenamientos")
        .description("Muestra tu racha actual de días consecutivos entrenando.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let longestStreak: Int
    let weeklyProgress: [Bool]
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(
            date: Date(),
            currentStreak: 7,
            longestStreak: 15,
            weeklyProgress: [true, true, true, true, false, true, true]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let entry = StreakEntry(
            date: Date(),
            currentStreak: calculateStreak(),
            longestStreak: calculateLongestStreak(),
            weeklyProgress: getWeeklyProgress()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> ()) {
        let entry = StreakEntry(
            date: Date(),
            currentStreak: calculateStreak(),
            longestStreak: calculateLongestStreak(),
            weeklyProgress: getWeeklyProgress()
        )
        
        // Actualizar cada hora
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func calculateStreak() -> Int {
        // Aquí iría la lógica para calcular la racha desde UserDefaults o CoreData
        // Por ahora retornamos un valor de ejemplo
        if let streak = UserDefaults(suiteName: "group.com.appgym.shared")?.integer(forKey: "currentStreak") {
            return streak
        }
        return 0
    }
    
    private func calculateLongestStreak() -> Int {
        if let longest = UserDefaults(suiteName: "group.com.appgym.shared")?.integer(forKey: "longestStreak") {
            return longest
        }
        return 0
    }
    
    private func getWeeklyProgress() -> [Bool] {
        if let data = UserDefaults(suiteName: "group.com.appgym.shared")?.array(forKey: "weeklyProgress") as? [Bool] {
            return data
        }
        return Array(repeating: false, count: 7)
    }
}

struct StreakWidgetEntryView: View {
    var entry: StreakProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallStreakView(entry: entry)
        case .systemMedium:
            MediumStreakView(entry: entry)
        default:
            SmallStreakView(entry: entry)
        }
    }
}

struct SmallStreakView: View {
    let entry: StreakEntry
    
    var body: some View {
        VStack(spacing: 12) {
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
                    .frame(width: 50, height: 50)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("\(entry.currentStreak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                Text("Días")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct MediumStreakView: View {
    let entry: StreakEntry
    
    var body: some View {
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
                    .frame(width: 60, height: 60)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(entry.currentStreak)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                
                Text("Días consecutivos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if entry.longestStreak > entry.currentStreak {
                    Text("Récord: \(entry.longestStreak) días")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Calendario semanal
            VStack(spacing: 4) {
                ForEach(0..<7) { index in
                    Circle()
                        .fill(entry.weeklyProgress[index] ?
                              Color(red: 1.0, green: 0.55, blue: 0.25) :
                              Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    WorkoutStreakWidget()
} timeline: {
    StreakEntry(
        date: Date(),
        currentStreak: 7,
        longestStreak: 15,
        weeklyProgress: [true, true, true, true, false, true, true]
    )
}

#Preview(as: .systemMedium) {
    WorkoutStreakWidget()
} timeline: {
    StreakEntry(
        date: Date(),
        currentStreak: 7,
        longestStreak: 15,
        weeklyProgress: [true, true, true, true, false, true, true]
    )
}

