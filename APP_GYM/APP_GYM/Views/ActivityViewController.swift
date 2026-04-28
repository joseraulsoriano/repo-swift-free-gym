//
//  ActivityViewController.swift
//  APP_GYM
//
//  Wrapper para compartir contenido
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
// Fallback para plataformas que no soportan UIKit
struct ActivityViewController: View {
    let activityItems: [Any]
    
    var body: some View {
        Text("Compartir no disponible en esta plataforma")
    }
}
#endif

