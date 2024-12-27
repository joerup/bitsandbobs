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
        let currentVersion = 3
        
        // Get the stored version
        let modelVersion = (UserDefaults.standard.value(forKey: "modelVersion") as? Int) ?? currentVersion
        
        // Get the context
        let context = persistenceController.container.viewContext
        
        // Get all the bobs
        let fetchRequest: NSFetchRequest<Bob> = Bob.fetchRequest()
        let bobs = (try? context.fetch(fetchRequest)) ?? []
        
        // 1.4.3
        if modelVersion < 2 {
            
            // Give Premium Version for free
            UserDefaults.standard.setValue(true, forKey: "premiumActivated")
        }
        
        // 1.7.0
        if modelVersion < 3 {
        
            for bob in bobs {
                bob.imageOffsetX = 0
                bob.imageOffsetY = 0
                bob.imageScale = 1.0
                
                // Compress all bit images to icons
                for bit in bob.bitArray {
                    if let image = bit.image {
                        bit.imageOffsetX = 0
                        bit.imageOffsetY = 0
                        bit.imageScale = 1.0
                        bit.icon = image.compressToIcon(offset: bit.imageOffset, scale: bit.imageScale)
                    }
                }
            }
            try? context.save()
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

