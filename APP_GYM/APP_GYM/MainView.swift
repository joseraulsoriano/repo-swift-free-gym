//
//  APP_GYMApp.swift
//  APP_GYM
//
//  Created by José Raúl Soriano Cazabal on 29/10/24.
//
import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Bienvenido a la aplicación de gimnasio")
                .font(.title)
                .padding()
            
            Text("Aquí irá el calendario de actividades")
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
