//
//  SettingsView.swift
//  APP_GYM
//
//  Created by José Raúl Soriano Cazabal on 12/11/24.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

// Clase para manejar el color scheme de la app
class ColorSchemeManager: ObservableObject {
    @AppStorage("appColorScheme") var appColorScheme: Int = 0 // 0: automático, 1: claro, 2: oscuro
    
    var colorScheme: ColorScheme? {
        switch appColorScheme {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil // nil = automático (sigue el sistema)
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var notificationManager: NotificationManager
    @StateObject private var colorSchemeManager = ColorSchemeManager()
    @State private var notificationsEnabled = true
    @State private var metricSystem = true
    @State private var showingEditProfile = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingDeleteAccount = false
    
    // Computed property para el toggle del modo oscuro
    private var darkModeBinding: Binding<Bool> {
        Binding(
            get: { colorSchemeManager.appColorScheme == 2 },
            set: { newValue in
                colorSchemeManager.appColorScheme = newValue ? 2 : 0
            }
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Perfil")) {
                    Button(action: { showingEditProfile = true }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Editar Perfil")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("Notificaciones")) {
                    Button(action: {
                        Task {
                            let granted = await notificationManager.requestAuthorization()
                            if granted {
                                notificationsEnabled = true
                                notificationManager.success("Notificaciones habilitadas", message: "Recibirás recordatorios de entrenamiento")
                            } else {
                                notificationsEnabled = false
                                errorHandler.show(.repositoryError("Se requieren permisos para enviar notificaciones. Actívalas en Configuración del sistema."))
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Permisos de Notificaciones")
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                        }
                    }
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Recordatorios de Entrenamiento")
                        }
                    }
                }
                
                Section(header: Text("Apariencia")) {
                    // Selector de modo oscuro con opciones
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Modo Oscuro")
                            Spacer()
                        }
                        
                        Picker("", selection: $colorSchemeManager.appColorScheme) {
                            Text("Automático").tag(0)
                            Text("Claro").tag(1)
                            Text("Oscuro").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Preferencias")) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "ruler.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Sistema Métrico")
                            Spacer()
                            Toggle("", isOn: $metricSystem)
                        }
                    }
                }
                
                Section(header: Text("Objetivos")) {
                    NavigationLink(destination: GoalsSettingsView()) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Objetivos de Entrenamiento")
                        }
                    }
                    
                    NavigationLink(destination: NutritionGoalsView()) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Objetivos de Nutrición")
                        }
                    }
                }
                
                Section(header: Text("Datos")) {
                    NavigationLink(destination: ExportDataView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Exportar Datos")
                        }
                    }
                    
                    NavigationLink(destination: ImportDataView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Importar Datos")
                        }
                    }
                }
                
                Section(header: Text("Acerca de")) {
                    Button(action: { showingPrivacyPolicy = true }) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Política de Privacidad")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showingTermsOfService = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                            Text("Términos de Servicio")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: { showingDeleteAccount = true }) {
                        HStack {
                            Spacer()
                            Text("Eliminar Cuenta")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Configuración")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .alert("¿Eliminar cuenta?", isPresented: $showingDeleteAccount) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    // Aquí iría la lógica para eliminar la cuenta
                    notificationManager.warning("Cuenta eliminada", message: "Todos los datos han sido eliminados")
                }
            } message: {
                Text("Esta acción no se puede deshacer. Todos tus datos serán eliminados permanentemente.")
            }
            .errorHandling(errorHandler)
            .notifications(notificationManager)
        }
    }
}

struct GoalsSettingsView: View {
    @State private var weightGoal = 75.0
    @State private var bodyFatGoal = 15.0
    @State private var muscleGoal = 40.0
    @State private var weeklyWorkouts = 4
    
    var body: some View {
        Form {
            Section(header: Text("Objetivos de Peso")) {
                HStack {
                    Text("Peso Objetivo")
                    Spacer()
                    Text("\(Int(weightGoal)) kg")
                }
                Slider(value: $weightGoal, in: 40...150, step: 1)
                
                HStack {
                    Text("Grasa Corporal")
                    Spacer()
                    Text("\(Int(bodyFatGoal))%")
                }
                Slider(value: $bodyFatGoal, in: 5...40, step: 1)
                
                HStack {
                    Text("Masa Muscular")
                    Spacer()
                    Text("\(Int(muscleGoal))%")
                }
                Slider(value: $muscleGoal, in: 20...60, step: 1)
            }
            
            Section(header: Text("Frecuencia de Entrenamiento")) {
                Stepper("Entrenamientos por semana: \(weeklyWorkouts)", value: $weeklyWorkouts, in: 1...7)
            }
        }
        .navigationTitle("Objetivos de Entrenamiento")
    }
}

struct NutritionGoalsView: View {
    @State private var dailyCalories = 2300
    @State private var proteinGoal = 180
    @State private var carbsGoal = 250
    @State private var fatGoal = 65
    
    var body: some View {
        Form {
            Section(header: Text("Calorías Diarias")) {
                HStack {
                    Text("Calorías")
                    Spacer()
                    Text("\(dailyCalories) kcal")
                }
                Slider(value: .init(get: { Double(dailyCalories) },
                                  set: { dailyCalories = Int($0) }),
                       in: 1200...4000,
                       step: 50)
            }
            
            Section(header: Text("Macronutrientes")) {
                HStack {
                    Text("Proteínas")
                    Spacer()
                    Text("\(proteinGoal)g")
                }
                Slider(value: .init(get: { Double(proteinGoal) },
                                  set: { proteinGoal = Int($0) }),
                       in: 50...300,
                       step: 5)
                
                HStack {
                    Text("Carbohidratos")
                    Spacer()
                    Text("\(carbsGoal)g")
                }
                Slider(value: .init(get: { Double(carbsGoal) },
                                  set: { carbsGoal = Int($0) }),
                       in: 50...500,
                       step: 5)
                
                HStack {
                    Text("Grasas")
                    Spacer()
                    Text("\(fatGoal)g")
                }
                Slider(value: .init(get: { Double(fatGoal) },
                                  set: { fatGoal = Int($0) }),
                       in: 20...150,
                       step: 5)
            }
        }
        .navigationTitle("Objetivos de Nutrición")
    }
}

struct ExportDataView: View {
    @StateObject private var progressManager = ProgressManager()
    @State private var selectedFormat = "CSV"
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingShareProgress = false
    
    let formats = ["CSV", "JSON"]
    
    var body: some View {
        Form {
            Section(header: Text("Compartir en Redes Sociales")) {
                Button(action: {
                    showingShareProgress = true
                }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.blue)
                        Text("Crear Imagen para Redes Sociales")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Exportar Datos")) {
                Picker("Formato", selection: $selectedFormat) {
                    ForEach(formats, id: \.self) { format in
                        Text(format)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                HStack {
                    Text("Total de registros")
                    Spacer()
                    Text("\(progressManager.progress.count)")
                        .foregroundColor(.gray)
                }
            }
            
                Section {
                    GradientButton(
                        "Exportar Datos",
                        icon: "square.and.arrow.up.fill",
                        gradient: LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing),
                        action: exportData
                    )
                }
        }
        .navigationTitle("Exportar y Compartir")
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingShareProgress) {
            ShareProgressView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func exportData() {
        do {
            let url: URL
            if selectedFormat == "CSV" {
                url = try exportToCSV()
            } else {
                url = try exportToJSON()
            }
            
            exportURL = url
            showingShareSheet = true
        } catch {
            errorMessage = "Error al exportar: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func exportToCSV() throws -> URL {
        let fileName = "workout_progress_\(dateString()).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var csvContent = "Fecha,Ejercicio,Series,Repeticiones,Peso (kg),Sensación,Fatiga,Comentarios\n"
        
        for progress in progressManager.progress {
            let row = """
            \(progress.date),\(progress.exerciseName),\(progress.sets),\(progress.reps),\(progress.weight),\(progress.feeling),\(progress.fatigue),"\(progress.comments.replacingOccurrences(of: "\"", with: "\"\""))"
            """
            csvContent += row + "\n"
        }
        
        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    private func exportToJSON() throws -> URL {
        let fileName = "workout_progress_\(dateString()).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(progressManager.progress)
        try data.write(to: fileURL)
        
        return fileURL
    }
    
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ImportDataView: View {
    @State private var selectedFormat = "CSV"
    let formats = ["CSV", "JSON"]
    
    var body: some View {
        Form {
            Section(header: Text("Formato de Importación")) {
                Picker("Formato", selection: $selectedFormat) {
                    ForEach(formats, id: \.self) { format in
                        Text(format)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section {
                Button("Seleccionar Archivo") {
                    // Aquí iría la lógica para seleccionar archivo
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Importar Datos")
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = "Usuario Demo"
    @State private var email = "usuario@demo.com"
    @State private var age = "28"
    @State private var height = "175"
    @State private var weight = "75.5"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Medidas")) {
                    TextField("Edad", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Altura (cm)", text: $height)
                        .keyboardType(.numberPad)
                    TextField("Peso (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button("Guardar Cambios") {
                        // Aquí iría la lógica para guardar los cambios
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarItems(trailing: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Política de Privacidad")
                        .font(.title)
                        .bold()
                    
                    Text("Última actualización: 1 de Marzo, 2024")
                        .foregroundColor(.gray)
                    
                    Group {
                        Text("1. Información que Recopilamos")
                            .font(.headline)
                        Text("Recopilamos información que usted nos proporciona directamente, incluyendo su nombre, dirección de correo electrónico y datos de actividad física.")
                        
                        Text("2. Uso de la Información")
                            .font(.headline)
                        Text("Utilizamos su información para proporcionar, mantener y mejorar nuestros servicios, desarrollar nuevos servicios y proteger a APP_GYM y a nuestros usuarios.")
                        
                        Text("3. Compartir Información")
                            .font(.headline)
                        Text("No compartimos su información personal con terceros excepto en las circunstancias limitadas descritas en esta política de privacidad.")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Términos de Servicio")
                        .font(.title)
                        .bold()
                    
                    Text("Última actualización: 1 de Marzo, 2024")
                        .foregroundColor(.gray)
                    
                    Group {
                        Text("1. Aceptación de los Términos")
                            .font(.headline)
                        Text("Al acceder y utilizar APP_GYM, usted acepta estar sujeto a estos Términos de Servicio y a todas las leyes y regulaciones aplicables.")
                        
                        Text("2. Uso del Servicio")
                            .font(.headline)
                        Text("APP_GYM está diseñado para ayudar a los usuarios a realizar un seguimiento de su actividad física y nutrición. Usted es responsable de mantener la confidencialidad de su cuenta.")
                        
                        Text("3. Limitaciones de Responsabilidad")
                            .font(.headline)
                        Text("APP_GYM no se hace responsable de ningún daño indirecto, incidental, especial, consecuente o punitivo que resulte de su uso o incapacidad para usar el servicio.")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    SettingsView()
}
