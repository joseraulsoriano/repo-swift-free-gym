//
//  NotificationManager.swift
//  APP_GYM
//
//  Componente para manejo de notificaciones y alertas
//

import SwiftUI
import UserNotifications
import Combine

// MARK: - Tipo de Notificación
enum NotificationType {
    case success
    case info
    case warning
    case error
    
    var color: Color {
        switch self {
        case .success: return .green
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

// MARK: - Modelo de Notificación
struct AppNotification: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?
    let type: NotificationType
    let duration: TimeInterval
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String? = nil,
        type: NotificationType = .info,
        duration: TimeInterval = 3.0,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.duration = duration
        self.action = action
    }
    
    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    @Published var notifications: [AppNotification] = []
    
    /// Muestra una notificación
    func show(
        _ title: String,
        message: String? = nil,
        type: NotificationType = .info,
        duration: TimeInterval = 3.0,
        action: (() -> Void)? = nil
    ) {
        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            duration: duration,
            action: action
        )
        
        DispatchQueue.main.async {
            self.notifications.append(notification)
            
            // Auto-dismiss después de la duración
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismiss(notification)
            }
        }
    }
    
    /// Muestra notificación de éxito
    func success(_ title: String, message: String? = nil) {
        show(title, message: message, type: .success)
    }
    
    /// Muestra notificación de información
    func info(_ title: String, message: String? = nil) {
        show(title, message: message, type: .info)
    }
    
    /// Muestra notificación de advertencia
    func warning(_ title: String, message: String? = nil) {
        show(title, message: message, type: .warning)
    }
    
    /// Muestra notificación de error
    func error(_ title: String, message: String? = nil) {
        show(title, message: message, type: .error, duration: 5.0)
    }
    
    /// Elimina una notificación
    func dismiss(_ notification: AppNotification) {
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
    }
    
    /// Elimina todas las notificaciones
    func dismissAll() {
        withAnimation {
            notifications.removeAll()
        }
    }
}

// MARK: - Notification Toast View
struct NotificationToastView: View {
    let notification: AppNotification
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .foregroundColor(.white)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if let message = notification.message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if notification.action != nil {
                Button("Ver") {
                    notification.action?()
                    onDismiss()
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.title3)
            }
        }
        .padding()
        .background(notification.type.color)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}

// MARK: - Notification Container View
struct NotificationContainerView: View {
    @ObservedObject var manager: NotificationManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(manager.notifications) { notification in
                NotificationToastView(notification: notification) {
                    manager.dismiss(notification)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: manager.notifications.count)
    }
}

// MARK: - View Extension para Notificaciones
extension View {
    /// Agrega soporte de notificaciones a la vista
    func notifications(_ manager: NotificationManager) -> some View {
        ZStack(alignment: .top) {
            self
            
            if !manager.notifications.isEmpty {
                NotificationContainerView(manager: manager)
                    .padding(.top, 8)
                    .zIndex(1000)
            }
        }
    }
}

// MARK: - Local Notifications (Sistema)
extension NotificationManager {
    /// Solicita permiso para notificaciones locales
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    /// Programa una notificación local
    func scheduleLocalNotification(
        title: String,
        body: String,
        date: Date,
        identifier: String = UUID().uuidString
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Cancela una notificación local
    func cancelLocalNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}



