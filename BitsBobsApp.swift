//___FILEHEADER___

import SwiftUI
import Foundation
import UIKit
import CoreData

@main
struct BitsBobsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            VStack {
                BobList()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onAppear {
                updateExistingData()
            }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }

    // Update existing data to new formats
    private func updateExistingData() {
        
        // Get the stored version
        let modelVersion = UserDefaults.standard.integer(forKey: "modelVersion")
        
        // Get the context
        let context = persistenceController.container.viewContext
        
        // 1.4.0
        if modelVersion < 1 {
            
            // Get all the bobs
            let fetchRequest: NSFetchRequest<Bob> = Bob.fetchRequest()
            do {
                let bobs = try context.fetch(fetchRequest)
                for bob in bobs {
                    // Compress all bit images to icons
                    for bit in bob.bitArray {
                        if let image = bit.image, bit.icon == nil {
                            bit.icon = image.compressed()
                        }
                    }
                }
                try context.save()
            } catch {
                print(error)
            }
        }
        
        // Save the current version
        UserDefaults.standard.set(1, forKey: "modelVersion")
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

