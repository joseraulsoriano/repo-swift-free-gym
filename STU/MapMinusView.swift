//
//  MapMinusView.swift
//  STU
//
//  Created by José Raúl Soriano Cazabal on 01/12/24.
//

import SwiftUI

struct MapMinusView: View {
    let route: [String]
    
    var body: some View {
        VStack {
            Text("Ruta en el Mapa")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            if route.isEmpty {
                Text("No hay ruta disponible.")
                    .foregroundColor(.red)
            } else {
                List(route, id: \.self) { stop in
                    Text(stop)
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MapMinusView_Previews: PreviewProvider {
    static var previews: some View {
        MapMinusView(route: ["DAE", "Cultura Física", "DRH"])
    }
}
