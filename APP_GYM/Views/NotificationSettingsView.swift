//
//  NotificationSettingsView.swift
//  APP_GYM
//
//  Configuración detallada de notificaciones
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var errorHandler: ErrorHandler
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    @State private var weeklyReminderEnabled = true
    @State private var streakReminderEnabled = true
    @State private var achievementEnabled = true
    
    var body: some View {
        Form {
            Section(header: Text("Recordatorios Diarios")) {
                Toggle("Recordatorio diario", isOn: $reminderEnabled)
                
                if reminderEnabled {
                    DatePicker("Hora", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    
                    Button("Guardar Recordatorio") {
                        saveDailyReminder()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
            
            Section(header: Text("Recordatorios Especiales")) {
                Toggle("Recordatorio semanal", isOn: $weeklyReminderEnabled)
                    .onChange(of: weeklyReminderEnabled) { newValue in
                        if newValue {
                            scheduleWeeklyReminder()
                        } else {
                            notificationManager.cancelLocalNotification(identifier: "weekly_reminder")
                        }
                    }
                
                Toggle("Recordatorio de racha", isOn: $streakReminderEnabled)
                    .onChange(of: streakReminderEnabled) { newValue in
                        if newValue {
                            scheduleStreakReminder()
                        } else {
                            notificationManager.cancelLocalNotification(identifier: "streak_reminder")
                        }
                    }
                
                Toggle("Logros y objetivos", isOn: $achievementEnabled)
            }
            
            Section(header: Text("Información")) {
                HStack {
                    Text("Estado")
                    Spacer()
                    Text(notificationStatus)
                        .foregroundColor(.secondary)
                }
                
                Button("Probar Notificación") {
                    testNotification()
                }
                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
            }
        }
        .navigationTitle("Notificaciones")
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private var notificationStatus: String {
        // Verificar estado de autorización
        var status = "No configurado"
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    status = "Habilitado"
                case .denied:
                    status = "Denegado"
                case .notDetermined:
                    status = "No configurado"
                case .provisional:
                    status = "Provisional"
                case .ephemeral:
                    status = "Temporal"
                @unknown default:
                    status = "Desconocido"
                }
            }
        }
        return status
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                reminderEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func saveDailyReminder() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Programar recordatorio diario
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let content = UNMutableNotificationContent()
        content.title = "¡Hora de entrenar! 🔥"
        content.body = "No olvides mantener tu racha activa"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DispatchQueue.main.async {
                    errorHandler.show(.repositoryError("Error al programar recordatorio: \(error.localizedDescription)"))
                }
            } else {
                DispatchQueue.main.async {
                    notificationManager.success("Recordatorio guardado", message: "Recibirás notificaciones diarias a las \(formatTime(reminderTime))")
                }
            }
        }
    }
    
    private func scheduleWeeklyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Resumen Semanal 📊"
        content.body = "Revisa tu progreso de esta semana"
        content.sound = .default
        
        // Cada domingo a las 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Domingo
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "¡No rompas tu racha! 🔥"
        content.body = "Aún tienes tiempo de entrenar hoy"
        content.sound = .default
        
        // Todos los días a las 8 PM si no has entrenado
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Notificación de Prueba"
        content.body = "Si ves esto, las notificaciones están funcionando correctamente"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        notificationManager.info("Notificación de prueba enviada", message: "Deberías recibirla en 2 segundos")
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
            .environmentObject(NotificationManager())
            .environmentObject(ErrorHandler())
    }
}



