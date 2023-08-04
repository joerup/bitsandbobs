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
    let container: NSPersistentContainer
    
    // Color 
    static let themeColor = Color.init(red: 0.8, green: 0.6, blue: 0.3)
    
    // Next Bob ID
    static var nextBobID: Int16 = Int16(UserDefaults.standard.integer(forKey: "nextBobID")) {
        didSet {
            UserDefaults.standard.set(self.nextBobID, forKey: "nextBobID")
        }
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
        
        container = NSPersistentContainer(name: "Model")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print("No changes")
            }
        }
        
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
}
