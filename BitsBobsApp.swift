//___FILEHEADER___

import SwiftUI
import Foundation
import UIKit
import CoreData

@main
struct BitsBobsApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @StateObject private var premium: Premium = Premium()
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            BobList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(premium)
                .task {
                    await premium.update()
                }
        }
    }
}
