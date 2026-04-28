//
//  APP_GYMApp.swift
//  APP_GYM
//
//  Created by José Raúl Soriano Cazabal on 29/10/24.
//
import SwiftUI

@main
struct APP_GYMApp: App {
    @State private var isUserLoggedIn = false
    @StateObject private var errorHandler = ErrorHandler()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var colorSchemeManager = ColorSchemeManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(errorHandler)
                    .environmentObject(notificationManager)
                    .preferredColorScheme(colorSchemeManager.colorScheme)
            } else {
                LoginView(isUserLoggedIn: $isUserLoggedIn)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(errorHandler)
                    .environmentObject(notificationManager)
                    .preferredColorScheme(colorSchemeManager.colorScheme)
            }
        }
    }
}
