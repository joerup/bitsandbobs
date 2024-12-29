//___FILEHEADER___

import SwiftUI
import Foundation
import UIKit
import CoreData

@main
struct BitsBobsApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @StateObject private var premium: Premium = Premium()
    
    @State private var showPremium: Bool = false
    @Environment(\.requestReview) private var requestReview
    @AppStorage("reviewOpens") private var reviewOpens: Int = 0
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            BobList()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(premium)
                .task {
                    await onStart()
                }
                .sheet(isPresented: $showPremium) {
                    PremiumView()
                        .environmentObject(premium)
                }
        }
    }
    
    private func onStart() async {
        await premium.updateOnStart()
        if !premium.isActive, Int.random(in: 1...5) == 5, reviewOpens > 0 {
            showPremium.toggle()
        } else {
            reviewOpens += 1
            if reviewOpens >= 7 {
                requestReview()
                reviewOpens = 0
            }
        }
        await premium.updateContinuously()
    }
}
