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
    
    @State var presentShare = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            NavigationStack {
                
                List {
                    
                    Section {

                        Button(action: {
                            getSampleBobs()
                        }) {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "arrow.3.trianglepath")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Generate Sample Bobs")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    Section {
                        
                        Link(destination: URL(string: "https://www.bitsandbobs.app")!) {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "cursorarrow")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Visit our Website")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.bitsandbobs.app/support")!) {
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

                        Link(destination: URL(string: "https://www.bitsandbobs.app/privacy")!) {
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
                        
                        Button {
                            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1554786457?action=write-review")
                                else { fatalError("Expected a valid URL") }
                            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
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
                        
                        Button {
                            self.presentShare.toggle()
                        } label: {
                            NavigationLink(destination: EmptyView()) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .imageScale(.small)
                                        .foregroundColor(PersistenceController.themeColor)
                                    Text("Share the App")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                }
                            }
                        }
                        .sheet(isPresented: self.$presentShare, content: {
                            ActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/bits-and-bobs/id1554786457")!])
                        })
                    }
                    
                    Section {
                        HStack {
                            Text("Version")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.systemGray))
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
    
    func getSampleBobs() {
        
        let managedObjectContext = PersistenceController.shared.container.viewContext
        
        // Bobs
        var bobs = [Bob]()
        for _ in 0..<5 {
            let bob = Bob(context: managedObjectContext)
            bob.order = PersistenceController.nextBobID
            PersistenceController.nextBobID += 1
            bobs += [bob]
        }
        
        // MARK: - Keepsakes
        
        // Bob
        
        bobs[0].name = "Keepsakes"
        bobs[0].desc = "My memories"
        bobs[0].image = UIImage(imageLiteralResourceName: "sample3").pngData()
        bobs[0].listType = 0 // list
        bobs[0].displayBitImgList = 1 // large
        bobs[0].displayBitIcon = true // icon
        
        // Attributes
        
        var attrs2 = [Attribute]()
        for i in 0..<2 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs2 += [attr]
        }
        
        attrs2[0].name = "Origin"
        attrs2[0].displayName = "Origin"
        attrs2[0].type = 0 // text
        attrs2[0].sortable = true
        attrs2[0].groupable = true
        attrs2[0].sortTextType = 1 // abc

        attrs2[1].name = "Year Obtained"
        attrs2[1].displayName = "Year Obtained"
        attrs2[1].type = 1 // number
        attrs2[1].minNum = 2000
        attrs2[1].minIncluded = true
        attrs2[1].maxNum = 2030
        attrs2[1].maxIncluded = true
        
        // Bits
        
        var bits2 = [Bit]()
        for i in 0..<7 {
            let bit = Bit(context: managedObjectContext)
            bit.order = Int16(i)
            bit.attributes = [:]
            bits2 += [bit]
        }
        
        bits2[0].name = "Quilt"
        bits2[0].image = UIImage(imageLiteralResourceName: "sample3g").pngData()
        bits2[0].attributes!["Origin"] = "Family"
        bits2[0].attributes!["Year Obtained"] = "2013"
        bits2[0].paragraph = "This family heirloom holds a special place in our home. It's a treasured item that brings warmth and comfort to our lives."
        
        bits2[1].name = "Teddy Bear"
        bits2[1].image = UIImage(imageLiteralResourceName: "sample3b").pngData()
        bits2[1].attributes!["Origin"] = "Childhood"
        bits2[1].attributes!["Year Obtained"] = "2000"
        bits2[1].paragraph = ""
        
        bits2[2].name = "Souvenir"
        bits2[2].image = UIImage(imageLiteralResourceName: "sample3c").pngData()
        bits2[2].attributes!["Origin"] = "Road Trip"
        bits2[2].attributes!["Year Obtained"] = "2018"
        bits2[2].paragraph = ""
        
        bits2[3].name = "Ornament"
        bits2[3].image = UIImage(imageLiteralResourceName: "sample3d").pngData()
        bits2[3].attributes!["Origin"] = "Christmas"
        bits2[3].attributes!["Year Obtained"] = "2020"
        bits2[3].paragraph = ""
        
        bits2[4].name = "Necklace"
        bits2[4].image = UIImage(imageLiteralResourceName: "sample3a").pngData()
        bits2[4].attributes!["Origin"] = "Christmas"
        bits2[4].attributes!["Year Obtained"] = "2019"
        bits2[4].paragraph = ""
        
        bits2[5].name = "Trucks"
        bits2[5].image = UIImage(imageLiteralResourceName: "sample3f").pngData()
        bits2[5].attributes!["Origin"] = "Childhood"
        bits2[5].attributes!["Year Obtained"] = "2002"
        bits2[5].paragraph = ""
        
        bits2[6].name = "Ring"
        bits2[6].image = UIImage(imageLiteralResourceName: "sample3e").pngData()
        bits2[6].attributes!["Origin"] = "Engagement"
        bits2[6].attributes!["Year Obtained"] = "2023"
        bits2[6].paragraph = ""
        
        // Finalize Bob
         
        bobs[0].sort = 0 // sort by Default
        bobs[0].bits = NSSet(array: bits2)
        bobs[0].attributes = NSSet(array: attrs2)
        bobs[0].nextBitID = Int16(bits2.count)
        bobs[0].nextAttrID = Int16(attrs2.count)
        
        // MARK: - Model Trains
        
        // Bob
        
        bobs[1].name = "Model Trains"
        bobs[1].image = UIImage(imageLiteralResourceName: "sample4").pngData()
        bobs[1].listType = 0 // list
        bobs[1].displayBitImgList = 1 // large
        bobs[1].displayBitIcon = true // icon
        
        // MARK: - Destinations
        
        // Bob
        
        bobs[2].name = "Destinations"
        bobs[2].desc = "My travel list"
        bobs[2].image = UIImage(imageLiteralResourceName: "sample1").pngData()
        bobs[2].listType = 1 // checklist
        bobs[2].displayBitImgList = 1 // large
        
        // Attributes
        
        var attrs0 = [Attribute]()
        for i in 0..<4 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs0 += [attr]
        }
        
        attrs0[0].name = "Country"
        attrs0[0].displayName = "Country"
        attrs0[0].type = 0 // text
        attrs0[0].sortable = true
        attrs0[0].groupable = true
        attrs0[0].sortTextType = 1 // abc
        
        attrs0[1].name = "Location"
        attrs0[1].displayName = "Location"
        attrs0[1].type = 0 // text
        attrs0[1].sortable = true
        attrs0[1].groupable = true
        attrs0[1].sortTextType = 1 // abc
        
        attrs0[2].name = "Language"
        attrs0[2].displayName = "Language"
        attrs0[2].type = 0 // text
        attrs0[2].sortable = true
        attrs0[2].groupable = true
        attrs0[2].sortTextType = 1 // abc
        
        attrs0[3].name = "Distance"
        attrs0[3].displayName = "Distance"
        attrs0[3].type = 1 // number
        attrs0[3].decimal = true
        attrs0[3].minNum = 0
        attrs0[3].minIncluded = true
        attrs0[3].maxNum = Double.infinity
        attrs0[3].maxIncluded = false
        attrs0[3].suffix = "mi"
        
        // Bits
        
        var bits0 = [Bit]()
        for i in 0..<5 {
            let bit = Bit(context: managedObjectContext)
            bit.order = Int16(i)
            bit.attributes = [:]
            bits0 += [bit]
        }
        
        bits0[0].name = "Rome"
        bits0[0].image = UIImage(imageLiteralResourceName: "sample1a").pngData()
        bits0[0].attributes!["Country"] = "Italy"
        bits0[0].attributes!["Location"] = "Europe"
        bits0[0].attributes!["Language"] = "Italian"
        bits0[0].attributes!["Distance"] = "4000"
        bits0[0].paragraph = "A peek into the Old World, a classic civilization as old as time itself."
        bits0[0].checked = true
        
        bits0[1].name = "San Francisco"
        bits0[1].image = UIImage(imageLiteralResourceName: "sample1b").pngData()
        bits0[1].attributes!["Country"] = "United States"
        bits0[1].attributes!["Location"] = "North America"
        bits0[1].attributes!["Language"] = "English"
        bits0[1].attributes!["Distance"] = "3000"
        bits0[1].paragraph = "A staple of California and of American culture, known for its icon, the Golden Gate Bridge."
        bits0[1].checked = true
        
        bits0[2].name = "Svalbard"
        bits0[2].image = UIImage(imageLiteralResourceName: "sample1c").pngData()
        bits0[2].attributes!["Country"] = "Norway"
        bits0[2].attributes!["Location"] = "Arctic Ocean"
        bits0[2].attributes!["Language"] = "Norwegian"
        bits0[2].attributes!["Distance"] = "4000"
        bits0[2].paragraph = "One of the northernmost places in the world, Svalbard is known for its amazing view of the Aurora Borealis."
        bits0[2].checked = true
        
        bits0[3].name = "Bora Bora"
        bits0[3].image = UIImage(imageLiteralResourceName: "sample1d").pngData()
        bits0[3].attributes!["Country"] = "French Polynesia"
        bits0[3].attributes!["Location"] = "South Pacific"
        bits0[3].attributes!["Language"] = "Tahitian"
        bits0[3].attributes!["Distance"] = "6000"
        bits0[3].paragraph = "A luxurious tropical getaway in French Polynesia."
        bits0[3].checked = false
        
        bits0[4].name = "Dubai"
        bits0[4].image = UIImage(imageLiteralResourceName: "sample1e").pngData()
        bits0[4].attributes!["Country"] = "United Arab Emirates"
        bits0[4].attributes!["Location"] = "Western Asia"
        bits0[4].attributes!["Language"] = "Arabic"
        bits0[4].attributes!["Distance"] = "7000"
        bits0[4].paragraph = "Home of the tallest building in the world, the Burj Khalifa, Dubai is a city that showcases modern innovation."
        bits0[4].checked = false
        
        // Finalize Bob
         
        bobs[2].sort = 2 // sort by Country
        bobs[2].bits = NSSet(array: bits0)
        bobs[2].attributes = NSSet(array: attrs0)
        bobs[2].nextBitID = Int16(bits0.count)
        bobs[2].nextAttrID = Int16(attrs0.count)
        
        // MARK: - Food
        
        // Bob
        
        bobs[3].name = "Food"
        bobs[3].desc = "My favorite foods"
        bobs[3].image = UIImage(imageLiteralResourceName: "sample2").pngData()
        bobs[3].listType = 2 // ranking
        bobs[3].displayBitImgList = 0 // small
        
        // Attributes
        
        var attrs1 = [Attribute]()
        for i in 0..<2 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs1 += [attr]
        }
        
        attrs1[0].name = "Type"
        attrs1[0].displayName = "Type"
        attrs1[0].type = 0 // text
        attrs1[0].sortable = true
        attrs1[0].groupable = true
        attrs1[0].sortTextType = 0 // ordered
        attrs1[0].restrictPresets = true
        attrs1[0].presets = ["Breakfast","Dinner","Dessert"]
        
        attrs1[1].name = "Rating"
        attrs1[1].displayName = "Rating"
        attrs1[1].type = 1 // number
        attrs1[1].minNum = 0
        attrs1[1].minIncluded = false
        attrs1[1].maxNum = 10
        attrs1[1].maxIncluded = true
        attrs1[1].suffix = "★"
        
        // Bits
        
        var bits1 = [Bit]()
        for i in 0..<6 {
            let bit = Bit(context: managedObjectContext)
            bit.order = Int16(i)
            bit.attributes = [:]
            bits1 += [bit]
        }
        
        bits1[0].name = "Pasta"
        bits1[0].image = UIImage(imageLiteralResourceName: "sample2a").pngData()
        bits1[0].attributes!["Type"] = "Dinner"
        bits1[0].attributes!["Rating"] = "10"
        bits1[0].paragraph = ""
        
        bits1[1].name = "Waffles"
        bits1[1].image = UIImage(imageLiteralResourceName: "sample2b").pngData()
        bits1[1].attributes!["Type"] = "Breakfast"
        bits1[1].attributes!["Rating"] = "9"
        bits1[1].paragraph = ""
        
        bits1[2].name = "Dumplings"
        bits1[2].image = UIImage(imageLiteralResourceName: "sample2c").pngData()
        bits1[2].attributes!["Type"] = "Dinner"
        bits1[2].attributes!["Rating"] = "9"
        bits1[2].paragraph = ""
        
        bits1[3].name = "Cookies"
        bits1[3].image = UIImage(imageLiteralResourceName: "sample2d").pngData()
        bits1[3].attributes!["Type"] = "Dessert"
        bits1[3].attributes!["Rating"] = "9"
        bits1[3].paragraph = ""
        
        bits1[4].name = "Pizza"
        bits1[4].image = UIImage(imageLiteralResourceName: "sample2e").pngData()
        bits1[4].attributes!["Type"] = "Dinner"
        bits1[4].attributes!["Rating"] = "8"
        bits1[4].paragraph = ""
        
        bits1[5].name = "Sushi"
        bits1[5].image = UIImage(imageLiteralResourceName: "sample2f").pngData()
        bits1[5].attributes!["Type"] = "Dinner"
        bits1[5].attributes!["Rating"] = "7"
        bits1[5].paragraph = ""
        
        // Finalize Bob
         
        bobs[3].sort = 0 // sort by Ranking
        bobs[3].bits = NSSet(array: bits1)
        bobs[3].attributes = NSSet(array: attrs1)
        bobs[3].nextBitID = Int16(bits1.count)
        bobs[3].nextAttrID = Int16(attrs1.count)
        
        // MARK: - Books
        
        // Bob
        
        bobs[4].name = "Books"
        bobs[4].desc = "Favorites ranked"
        bobs[4].image = UIImage(imageLiteralResourceName: "sample6").pngData()
        bobs[4].listType = 0 // list
        bobs[4].displayBitImgList = 1 // large
        bobs[4].displayBitIcon = true // icon
                
        PersistenceController.shared.save()

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
