import SwiftUI
#if os(macOS)
import AppKit
#endif

struct NutritionView: View {
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var showingWaterIntake = false
    @State private var waterIntake: Double = 1.8 // en litros
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Resumen de calorías
                    CaloriesSummaryCard()
                    
                    // Macronutrientes
                    MacronutrientsCard()
                    
                    // Registro de comidas
                    MealsCard()
                    
                    // Agua
                    WaterIntakeCard(waterIntake: $waterIntake)
                }
                .padding()
            }
            .navigationTitle("Nutrición")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMeal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingAddMeal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView()
            }
        }
    }
}

struct CaloriesSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Resumen de Calorías")
                .font(.headline)
            
            HStack(spacing: 20) {
                CalorieItem(
                    title: "Consumidas",
                    value: "1,450",
                    color: .blue,
                    icon: "fork.knife"
                )
                
                CalorieItem(
                    title: "Objetivo",
                    value: "2,300",
                    color: .green,
                    icon: "target"
                )
                
                CalorieItem(
                    title: "Restantes",
                    value: "850",
                    color: .orange,
                    icon: "flame.fill"
                )
            }
            
            ProgressView(value: 1450, total: 2300)
                .tint(.blue)
        }
        .padding()
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.controlBackgroundColor))
        #endif
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct MacronutrientsCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Macronutrientes")
                .font(.headline)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            VStack(spacing: 12) {
                MacronutrientBar(
                    name: "Proteínas",
                    value: 120,
                    total: 180,
                    color: Color(red: 0.4, green: 0.6, blue: 1.0),
                    unit: "g"
                )
                
                MacronutrientBar(
                    name: "Carbohidratos",
                    value: 180,
                    total: 250,
                    color: Color(red: 0.3, green: 0.8, blue: 0.5),
                    unit: "g"
                )
                
                MacronutrientBar(
                    name: "Grasas",
                    value: 45,
                    total: 65,
                    color: Color(red: 1.0, green: 0.55, blue: 0.25),
                    unit: "g"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

struct MealsCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Comidas del Día")
                .font(.headline)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            VStack(spacing: 12) {
                ForEach(Meal.sampleMeals) { meal in
                    MealRow(meal: meal)
                }
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Agregar Comida")
                }
                .font(.headline)
                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

struct WaterIntakeCard: View {
    @Binding var waterIntake: Double
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Consumo de Agua")
                .font(.headline)
                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
            
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                    Color(red: 0.3, green: 0.5, blue: 0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(String(format: "%.1f", waterIntake))L")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    
                    Text("de 2.5L objetivo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    waterIntake = min(waterIntake + 0.25, 2.5)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                }
            }
            
            ProgressView(value: waterIntake, total: 2.5)
                .tint(Color(red: 0.4, green: 0.6, blue: 1.0))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

struct CalorieItem: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacronutrientBar: View {
    let name: String
    let value: Int
    let total: Int
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(value)/\(total)\(unit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            ProgressView(value: Double(value), total: Double(total))
                .tint(color)
        }
    }
}

struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    let calories: Int
    let macros: (protein: Int, carbs: Int, fat: Int)
    
    static let sampleMeals: [Meal] = [
        Meal(name: "Desayuno", time: "08:00", calories: 450, macros: (30, 45, 15)),
        Meal(name: "Almuerzo", time: "13:00", calories: 650, macros: (40, 60, 25)),
        Meal(name: "Cena", time: "20:00", calories: 350, macros: (25, 30, 15))
    ]
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.subheadline)
                    .bold()
                Text(meal.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(meal.calories) kcal")
                    .font(.subheadline)
                Text("P: \(meal.macros.protein)g C: \(meal.macros.carbs)g G: \(meal.macros.fat)g")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

struct AddMealView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var mealName = ""
    @State private var selectedTime = Date()
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo degradado naranja tenue
                Group {
                    if colorScheme == .dark {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.12),
                                Color(red: 0.08, green: 0.08, blue: 0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.95, blue: 0.9),
                                Color(red: 1.0, green: 0.9, blue: 0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Información de la Comida
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Información de la Comida")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nombre de la Comida")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Ej: Pollo con arroz", text: $mealName)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hora")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Calorías")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0", text: $calories)
                                        #if os(iOS)
                                        .keyboardType(.numberPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
                                        )
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Macronutrientes
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Macronutrientes")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.1))
                            
                            VStack(spacing: 12) {
                                MacroInputRow(icon: "dumbbell.fill", title: "Proteínas", value: $protein, color: .blue, unit: "g")
                                MacroInputRow(icon: "leaf.fill", title: "Carbohidratos", value: $carbs, color: .green, unit: "g")
                                MacroInputRow(icon: "drop.fill", title: "Grasas", value: $fat, color: .orange, unit: "g")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Botón Guardar
                        Button(action: {
                            // Aquí iría la lógica para guardar la comida
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Guardar Comida")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.35),
                                        Color(red: 1.0, green: 0.55, blue: 0.25)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(mealName.isEmpty || calories.isEmpty)
                        .opacity((mealName.isEmpty || calories.isEmpty) ? 0.6 : 1.0)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nueva Comida")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.25))
                }
            }
        }
    }
}

struct MacroInputRow: View {
    let icon: String
    let title: String
    @Binding var value: String
    let color: Color
    let unit: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("0", text: $value)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    
                    Text(unit)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98))
        )
    }
}

#Preview {
    NutritionView()
} 