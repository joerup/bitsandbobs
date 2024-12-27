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
    @State private var progress: Double = 0.2
    
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
    
    private let currentVersion = 3
    private var modelVersion: Int {
        2//(UserDefaults.standard.value(forKey: "modelVersion") as? Int) ?? currentVersion
    }

    // Update existing data to new formats
    private func updateExistingData() async {
        
        // 1.4.3
        if modelVersion < 2 {
            // Give Premium Version for free
            UserDefaults.standard.setValue(true, forKey: "premiumActivated")
        }
        
        // 1.7.0
        if modelVersion < 3 {
            // Reset all icons to new cropped format
            await resetAllIcons()
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
            if modelVersion < currentVersion {
                Group {
                    Text("Your collections are being updated. This may take a minute. Please do not close the app.")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .frame(maxWidth: 300)
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // 1.7.0 - Reset all icons to new cropped format
    private func resetAllIcons() async {
        let context = persistenceController.container.viewContext
        
        guard let bobs = try? context.fetch(Bob.fetchRequest()) else { return }
        guard let bits = try? context.fetch(Bit.fetchRequest()) else { return }
        
        for bob in bobs {
            if bob.imageScale < 1 {
                bob.imageScale = 1.0
            }
        }
        
        await MainActor.run {
            progress = 0.2
        }
        
        for bit in bits {
            if bit.imageScale < 1 {
                bit.imageScale = 1.0
            }
        }
        try? context.save()
        
        await MainActor.run {
            progress = 0.3
        }

        let batchSize = 10
        for startIndex in stride(from: 0, to: bits.count, by: batchSize) {
            await MainActor.run {
                progress = 0.3 + 0.7 * Double(startIndex) / Double(bits.count)
            }
            autoreleasepool {
                let endIndex = min(startIndex + batchSize, bits.count)
                let chunk = bits[startIndex..<endIndex]
                
                for bit in chunk {
                    if let image = bit.image {
                        bit.icon = image.compressToIcon(offset: bit.imageOffset, scale: bit.imageScale)
                    } else {
                        bit.icon = nil
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    print("Error saving batch: \(error)")
                }
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

