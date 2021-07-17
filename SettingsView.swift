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
    
    var getSampleBobs: () -> Void
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var presentShare = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            NavigationView {
                
                List {
                    
                    if geometry.size.width > 800 {
                        HStack {
                            Image("BitsAndBobs")
                                .resizable()
                                .frame(width: geometry.size.width*0.15, height: geometry.size.width*0.15)
                                .cornerRadius(20)
                            HStack {
                                Text("Bits & Bobs")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .lineLimit(0)
                                    .minimumScaleFactor(0.00001)
                                Spacer()
                            }
                            .frame(width: geometry.size.width*0.5)
                            .padding(.leading, 20)
                            Spacer()
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                    }
                    else {
                        VStack {
                            HStack {
                                Spacer()
                                Image("BitsAndBobs")
                                    .resizable()
                                    .frame(width: geometry.size.width*0.3, height: geometry.size.width*0.3)
                                    .cornerRadius(20)
                                    .padding(.top, 10)
                                Spacer()
                            }
                            Text("Bits & Bobs")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .lineLimit(0)
                                .minimumScaleFactor(0.00001)
                            Spacer()
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                    }
                    
//                    Section {
//
//                        Button(action: {
//                            getSampleBobs()
//                        }) {
//                            NavigationLink(destination: EmptyView()) {
//                                HStack {
//                                    Image(systemName: "arrow.3.trianglepath")
//                                        .imageScale(.small)
//                                        .foregroundColor(PersistenceController.themeColor)
//                                    Text("Generate Sample Bobs")
//                                        .font(.headline)
//                                        .foregroundColor(Color(UIColor.systemGray))
//                                    Spacer()
//                                }
//                            }
//                        }
//                        .padding(10)
//                        .padding(.vertical, 3)
//                    }
                    
                    Section {
                        
                        Link(destination: URL(string: "https://joerup2004.github.io/bits-bobs/support/support.html")!) {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "paperplane")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Contact Support")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                        .padding(10)
                        .padding(.vertical, 3)

                        Link(destination: URL(string: "https://joerup2004.github.io/bits-bobs/privacy/privacy.html")!) {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "hand.raised")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Privacy Policy")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                        
                        Button {
                            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        } label: {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "star")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Rate the App")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                        
                        NavigationLink(destination: MoreApps()) {
                            HStack {
                                Image(systemName: "app")
                                    .imageScale(.small)
                                    .foregroundColor(PersistenceController.themeColor)
                                Text("More Apps")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.systemGray))
                                Spacer()
                            }
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                        
                        
//                    Button {
//                        self.presentShare.toggle()
//                    } label: {
//                        NavigationLink(destination: EmptyView()) {
//                            HStack {
//                                Text("Share the App")
//                                    .font(.headline)
//                                    .foregroundColor(Color.init(white: 0.8))
//                                Image(systemName: "square.and.arrow.up")
//                                    .imageScale(.small)
//                                Spacer()
//                            }
//                        }
//                    }
//                    .padding(10)
//                    .padding(.vertical, 3)
//                    .sheet(isPresented: self.$presentShare, content: {
//                        ActivityViewController(activityItems: [URL(string: "")!])
//                    })
                    }
                    
                    Section {
                        HStack {
                            Text("Version")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.systemGray))
                            Spacer()
                            Text(appVersion ?? "")
                        }
                        .padding(10)
                        .padding(.vertical, 3)
                    }
                    
//                        Button(action: {
//                            self.resetDefault.toggle()
//                        }) {
//                            VStack {
//                                HStack {
//                                    Text("Repopulate Default Bobs")
//                                        .font(.headline)
//                                        .foregroundColor(Color.init(white: 0.8))
//                                    Spacer()
//                                }
//                                HStack {
//                                    Text("Regenerate Destinations & Food.")
//                                        .font(.subheadline)
//                                        .foregroundColor(Color.init(white: 0.5))
//                                        .padding(.top, 1)
//                                    Spacer()
//                                }
//                            }
//                            .padding(10)
//                            .padding(.vertical, 3)
//                        }
//                        .alert(isPresented: $resetDefault) {
//                            Alert(title: Text("Repopulate Default Bobs"),
//                                  message: Text("Would you like to add the sample bobs again?"),
//                                  primaryButton: .default(Text("Cancel"), action: { resetDefault = false }),
//                                  secondaryButton: .default(Text("Add"), action: { getSampleBobs() })
//                            )
//                        }
                }
                .listStyle(InsetGroupedListStyle())
                .accentColor(PersistenceController.themeColor)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding(10)
                        }
                    }
                }
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


struct MoreApps: View {
    
    var body: some View {
        
        List {
            Link(destination: URL(string: "https://apps.apple.com/us/app/omega-calculator/id1528068503")!) {
                HStack {
                    Image("Omega")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    VStack(alignment: .leading) {
                        Text("Omega Calculator")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Your Everyday Calculator")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                    .padding(.leading, 20)
                }
            }
            .padding(.vertical, 5)
            Link(destination: URL(string: "https://apps.apple.com/is/app/planetaria/id1546887479")!) {
                HStack {
                    Image("Planetaria")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    VStack(alignment: .leading) {
                        Text("Planetaria")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Explore Space")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                    .padding(.leading, 20)
                }
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("More Apps")
        .navigationBarTitleDisplayMode(.inline)
    }
}
