//
//  NextWorkoutWidget.swift
//  APP_GYM
//
//  Widget para mostrar el próximo entrenamiento
//

import WidgetKit
import SwiftUI

struct NextWorkoutWidget: Widget {
    let kind: String = "NextWorkoutWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextWorkoutProvider()) { entry in
            NextWorkoutWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Próximo Entrenamiento")
        .description("Muestra tu próximo entrenamiento programado.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NextWorkoutEntry: TimelineEntry {
    let date: Date
    let workoutName: String?
    let exerciseCount: Int
    let hasWorkout: Bool
}

struct NextWorkoutProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextWorkoutEntry {
        NextWorkoutEntry(
            date: Date(),
            workoutName: "Rutina de Fuerza",
            exerciseCount: 5,
            hasWorkout: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextWorkoutEntry) -> ()) {
        let entry = NextWorkoutEntry(
            date: Date(),
            workoutName: getWorkoutName(),
            exerciseCount: getExerciseCount(),
            hasWorkout: hasWorkout()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextWorkoutEntry>) -> ()) {
        let entry = NextWorkoutEntry(
            date: Date(),
            workoutName: getWorkoutName(),
            exerciseCount: getExerciseCount(),
            hasWorkout: hasWorkout()
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getWorkoutName() -> String? {
        return UserDefaults(suiteName: "group.com.appgym.shared")?.string(forKey: "nextWorkoutName")
    }
    
    private func getExerciseCount() -> Int {
        return UserDefaults(suiteName: "group.com.appgym.shared")?.integer(forKey: "nextWorkoutExercises") ?? 0
    }
    
    private func hasWorkout() -> Bool {
        return UserDefaults(suiteName: "group.com.appgym.shared")?.bool(forKey: "hasNextWorkout") ?? false
    }
}

struct NextWorkoutWidgetEntryView: View {
    var entry: NextWorkoutProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallNextWorkoutView(entry: entry)
        case .systemMedium:
            MediumNextWorkoutView(entry: entry)
        default:
            SmallNextWorkoutView(entry: entry)
        }
    }
}

struct SmallNextWorkoutView: View {
    let entry: NextWorkoutEntry
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: entry.hasWorkout ? "figure.strengthtraining.traditional" : "plus.circle")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
            
            if entry.hasWorkout, let name = entry.workoutName {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(entry.exerciseCount) ejercicios")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Nuevo Entrenamiento")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct MediumNextWorkoutView: View {
    let entry: NextWorkoutEntry
    
    var body: some View {
        HStack(spacing: 16) {
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
                
                Image(systemName: entry.hasWorkout ? "figure.strengthtraining.traditional" : "plus.circle")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Próximo Entrenamiento")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if entry.hasWorkout, let name = entry.workoutName {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(entry.exerciseCount) ejercicios")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Nuevo Entrenamiento")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Toca para comenzar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview(as: .systemSmall) {
    NextWorkoutWidget()
} timeline: {
    NextWorkoutEntry(
        date: Date(),
        workoutName: "Rutina de Fuerza",
        exerciseCount: 5,
        hasWorkout: true
    )
}

#Preview(as: .systemMedium) {
    NextWorkoutWidget()
} timeline: {
    NextWorkoutEntry(
        date: Date(),
        workoutName: "Rutina de Fuerza",
        exerciseCount: 5,
        hasWorkout: true
    )
}



