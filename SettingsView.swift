//
//  SettingsView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/25/21.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @State var resetDefault: Bool = false
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var premium: Premium
    
    @State private var presentShare = false
    @State private var presentStore = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            NavigationStack {
                
                List {
                    
                    Section {
                        if premium.isActive {
                            HStack {
                                Text("Premium")
                                Spacer()
                                Text("Unlocked")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Button {
                                self.presentStore.toggle()
                            } label: {
                                row("Premium")
                            }
                            .sheet(isPresented: $presentStore) {
                                PremiumView()
                            }
                        }
                    }
                    
                    Section {
                        Button {
                            Samples.getSamples()
                        } label: {
                            row("Generate Sample Collections")
                        }
                    }
                    
                    Section {
                        Link(destination: URL(string: "https://www.joerup.com/bitsandbobs")!) {
                            row("Website")
                        }
                        Link(destination: URL(string: "https://www.joerup.com/bitsandbobs/support")!) {
                            row("Support")
                        }
                        Link(destination: URL(string: "https://www.joerup.com/bitsandbobs/privacy")!) {
                            row("Privacy Policy")
                        }
                    }
                    
                    Section {
                        Button {
                            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1554786457?action=write-review")
                                else { fatalError("Expected a valid URL") }
                            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        } label: {
                            row("Rate the App")
                        }
                        Button {
                            self.presentShare.toggle()
                        } label: {
                            row("Share the App")
                        }
                        .sheet(isPresented: self.$presentShare, content: {
                            ActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/bits-and-bobs/id1554786457")!])
                        })
                    }
                    
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(appVersion ?? "")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .accentColor(PersistenceController.themeColor)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .font(.system(.headline, design: .rounded).bold())
                                .foregroundColor(PersistenceController.themeColor)
                        }
                    }
                }
            }
        }
    }
    
    private func row(_ text: String) -> some View {
        NavigationLink(destination: EmptyView()) {
            HStack {
                Text(text)
                Spacer()
            }
        }
    }
}


struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
