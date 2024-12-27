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
    
    @State private var isLoaded: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoaded {
                    BobList()
                } else {
                    loadingView
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(premium)
            .task {
                await premium.update()
            }
            .task {
                await updateExistingData()
                isLoaded = true
            }
        }
    }

    // Update existing data to new formats
    private func updateExistingData() async {
        let currentVersion = 3
        
        // Get the stored version
        let modelVersion = (UserDefaults.standard.value(forKey: "modelVersion") as? Int) ?? currentVersion
        
        // 1.4.3
        if modelVersion < 2 {
            // Give Premium Version for free
            UserDefaults.standard.setValue(true, forKey: "premiumActivated")
        }
        
        // 1.7.0
        if modelVersion < 3 {
            // Reset all icons to new format
            resetAllIcons()
        }
        
        // Save the current version
        UserDefaults.standard.set(currentVersion, forKey: "modelVersion")
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Text("Loading Collections")
                .font(.headline)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func resetAllIcons() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Bob> = Bob.fetchRequest()
        let bobs = (try? context.fetch(fetchRequest)) ?? []
    
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
                else {
                    bit.imageOffsetX = 0
                    bit.imageOffsetY = 0
                    bit.imageScale = 1.0
                    bit.icon = nil
                }
            }
        }
        try? context.save()
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

