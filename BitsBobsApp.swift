//___FILEHEADER___

import SwiftUI
import Foundation
import UIKit
import CoreData

@main
struct BitsBobsApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    @StateObject private var premium: Premium = Premium()
    
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            VStack {
                BobList()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(premium)
            .onAppear {
                updateExistingData()
            }
            .task {
                await premium.update()
            }
        }
    }

    // Update existing data to new formats
    private func updateExistingData() {
        let currentVersion = 2
        
        // Get the stored version
        let modelVersion = (UserDefaults.standard.value(forKey: "modelVersion") as? Int) ?? currentVersion
        
        // Get the context
        let context = persistenceController.container.viewContext
        
        // Get all the bobs
        let fetchRequest: NSFetchRequest<Bob> = Bob.fetchRequest()
        let bobs = (try? context.fetch(fetchRequest)) ?? []
        
        // 1.4.0
        if modelVersion < 1 {
            for bob in bobs {
                // Compress all bit images to icons
                for bit in bob.bitArray {
                    if let image = bit.image, bit.icon == nil {
                        bit.icon = image.compressed()
                    }
                }
            }
            try? context.save()
        }
        
        // 1.4.3
        if modelVersion < 2 {
            
            // Give Premium Version for free
            UserDefaults.standard.setValue(true, forKey: "premiumActivated")
        }
        
        // Save the current version
        UserDefaults.standard.set(currentVersion, forKey: "modelVersion")
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

