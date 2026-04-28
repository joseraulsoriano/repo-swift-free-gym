//
//  WidgetDataManager.swift
//  APP_GYM
//
//  Manager para compartir datos entre la app y los widgets
//

import Foundation
#if os(iOS)
import WidgetKit
#endif

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let sharedDefaults = UserDefaults(suiteName: "group.com.appgym.shared")
    
    private init() {}
    
    // MARK: - Streak Data
    func saveStreakData(currentStreak: Int, longestStreak: Int, weeklyProgress: [Bool]) {
        sharedDefaults?.set(currentStreak, forKey: "currentStreak")
        sharedDefaults?.set(longestStreak, forKey: "longestStreak")
        sharedDefaults?.set(weeklyProgress, forKey: "weeklyProgress")
        sharedDefaults?.synchronize()
        
        // Notificar a los widgets que actualicen
        #if os(iOS)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
    
    func getCurrentStreak() -> Int {
        return sharedDefaults?.integer(forKey: "currentStreak") ?? 0
    }
    
    func getLongestStreak() -> Int {
        return sharedDefaults?.integer(forKey: "longestStreak") ?? 0
    }
    
    func getWeeklyProgress() -> [Bool] {
        return sharedDefaults?.array(forKey: "weeklyProgress") as? [Bool] ?? Array(repeating: false, count: 7)
    }
    
    // MARK: - Workout Data
    func saveNextWorkout(name: String?, exerciseCount: Int, hasWorkout: Bool) {
        sharedDefaults?.set(name, forKey: "nextWorkoutName")
        sharedDefaults?.set(exerciseCount, forKey: "nextWorkoutExercises")
        sharedDefaults?.set(hasWorkout, forKey: "hasNextWorkout")
        sharedDefaults?.synchronize()
        
        #if os(iOS)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
}

