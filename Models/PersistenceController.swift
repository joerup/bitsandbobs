//
//  PersistenceController.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/11/21.
//
//

import Foundation
import CoreData
import SwiftUI

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentCloudKitContainer
    
    // Color
    static let themeColor = Color.init(red: 255/255, green: 164/255, blue: 27/255)
    
    // Next Bob ID
    static var nextBobID: Int16 {
        let context = shared.container.viewContext
        let fetchRequest: NSFetchRequest<Bob> = Bob.fetchRequest()
        guard let bobs = try? context.fetch(fetchRequest) else { return -1 }
        let uniqueOrders = Set(bobs.map(\.order))
        var order: Int16 = 0
        while uniqueOrders.contains(order) {
            order += 1
        }
        return order
    }

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Create 10 example programming languages.
        for _ in 0..<10 {
            let bob = Bob(context: controller.container.viewContext)
            bob.name = "Test Bob"
            print(bob.name ?? "")
        }

        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        
        container = NSPersistentCloudKitContainer(name: "Model")
        container.viewContext.automaticallyMergesChangesFromParent = true

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func discard() {
        let context = container.viewContext
        
        if context.hasChanges {
            context.rollback()
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("No changes")
            }
        }
        
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
}
