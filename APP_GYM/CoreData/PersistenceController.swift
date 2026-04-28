//
//  PersistenceController.swift
//  APP_GYM
//
//  Controlador de persistencia con Core Data + CloudKit
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        // Agregar datos de ejemplo para previews
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "GymDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configurar CloudKit
            let storeDescription = container.persistentStoreDescriptions.first
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            
            // Configurar CloudKit container
            storeDescription?.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.appgym.shared"
            )
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Evita tumbar la interfaz por fallas de CloudKit/Core Data en primer arranque
                // (por ejemplo, container no configurado o simulador inestable).
                NSLog("Error cargando Core Data (%@): %@", description.url?.absoluteString ?? "sin-url", error.localizedDescription)
            }
        }
        
        // Configurar para recibir cambios de CloudKit
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                NSLog("Error guardando Core Data: %@ %@", nsError.localizedDescription, nsError.userInfo.description)
            }
        }
    }
}



