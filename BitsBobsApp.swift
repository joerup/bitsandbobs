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
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
}

