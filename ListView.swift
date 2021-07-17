//
//  ListView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct ListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @FetchRequest(
        entity: Bit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bit.order, ascending: true)
        ]
    ) var bits: FetchedResults<Bit>
    
    @State private var newBob = false
    @State private var editBobs = false
    
    @State private var showSettings = false
    
    @State private var search = ""

    var body: some View {

        GeometryReader { geometry in

            NavigationView {
                
                ZStack {
                    
                    VStack {
                        
                        List {
                        
                            ForEach(self.bobs, id: \.self) { bob in

                                NavigationLink(destination: BobView(bob: bob)) {

                                    ZStack {
                                        if bob.image == nil {
                                            Rectangle()
                                                .fill(Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2))
                                                .frame(height: UIScreen.main.bounds.height*0.15)
                                                .cornerRadius(20)
                                        }
                                        
                                        Image(uiImage: bob.image != nil ? UIImage(data: bob.image!) ?? UIImage(named: "") ?? UIImage() : UIImage(named: "") ?? UIImage())
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .blur(radius: 1)
                                            .frame(height: UIScreen.main.bounds.height*0.15)
                                            .cornerRadius(20)
                                        
                                        VStack {
                                            Text(bob.name ?? "")
                                                .fontWeight(.black)
                                                .font(.largeTitle)
                                                .tracking(-0.5)
                                                .lineLimit(0)
                                                .minimumScaleFactor(0.2)
                                                .foregroundColor(bob.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)

                                            if bob.desc != nil && bob.desc != "" {
                                                Text(bob.desc ?? "")
                                                    .fontWeight(.black)
                                                    .font(.headline)
                                                    .tracking(-0.25)
                                                    .lineLimit(0)
                                                    .minimumScaleFactor(0.2)
                                                    .foregroundColor(Color(bob.image != nil ? UIColor.white : UIColor.systemGray))
                                                    .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                                            }
                                        }
                                        .frame(height: UIScreen.main.bounds.height*0.15)
                                    }
                                }
                            }
                            
                            Spacer()
                                .frame(height: 100)
                        }
                        .listStyle(InsetListStyle())
                        .environment(\.editMode, .constant(self.editBobs ? EditMode.active : EditMode.inactive))
                        .sheet(isPresented: self.$editBobs) {
                            RearrangeBobOrder()
                        }
                    }
                    
                    VStack {
                        
                        Spacer()
                        
                        Button(action: {
                            PersistenceController.haptic(.heavy)
                            self.newBob.toggle()
                        }, label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(PersistenceController.themeColor)
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color(UIColor.systemGray6), radius: 10)
                        })
                        .frame(width: 80, height: 80)
                        .padding()
                        .sheet(isPresented: self.$newBob, content: {
                            BobEditor()
                        })
                    }
                }
                .navigationBarTitle("Bits & Bobs")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            PersistenceController.haptic(.medium)
                            self.showSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("Edit")
                            .foregroundColor(PersistenceController.themeColor)
                            .onTapGesture {
                                PersistenceController.haptic(.medium)
                                self.editBobs.toggle()
                            }
                    }
                }
                .sheet(isPresented: self.$showSettings) {
                    SettingsView(getSampleBobs: self.getSampleBobs)
                }
                
                Text("Select a bob on the left")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .accentColor(PersistenceController.themeColor)
            .phoneOnlyStackNavigationView(geometry)
        }
        .onAppear {
            if bobs.isEmpty {
                getSampleBobs()
            }
        }
    }
    
    func getSampleBobs() {
        
        // Bobs
        var bobs = [Bob]()
        for _ in 0..<3 {
            let bob = Bob(context: managedObjectContext)
            bob.order = PersistenceController.nextBobID
            PersistenceController.nextBobID += 1
            bobs += [bob]
        }
        
        // MARK: - DESTINATIONS
        
        // Bob
        
        bobs[0].name = "Destinations"
        bobs[0].desc = "My travel list"
        bobs[0].image = UIImage(imageLiteralResourceName: "sample1").pngData()
        bobs[0].listType = 1 // checklist
        bobs[0].displayBitImgList = 1 // large
        
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
         
        bobs[0].sort = 2 // sort by Country
        bobs[0].bits = NSSet(array: bits0)
        bobs[0].attributes = NSSet(array: attrs0)
        bobs[0].nextBitID = Int16(bits0.count)
        bobs[0].nextAttrID = Int16(attrs0.count)
        
        // MARK: - Food
        
        // Bob
        
        bobs[1].name = "Food"
        bobs[1].desc = "My favorite foods"
        bobs[1].image = UIImage(imageLiteralResourceName: "sample2").pngData()
        bobs[1].listType = 2 // ranking
        bobs[1].displayBitImgList = 0 // small
        
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
         
        bobs[1].sort = 0 // sort by Ranking
        bobs[1].bits = NSSet(array: bits1)
        bobs[1].attributes = NSSet(array: attrs1)
        bobs[1].nextBitID = Int16(bits1.count)
        bobs[1].nextAttrID = Int16(attrs1.count)
        
        // MARK: - Keepsakes
        
        // Bob
        
        bobs[2].name = "Keepsakes"
        bobs[2].desc = "My memories"
        bobs[2].image = UIImage(imageLiteralResourceName: "sample3").pngData()
        bobs[2].listType = 0 // list
        bobs[2].displayBitImgList = 1 // large
        bobs[2].displayBitIcon = true // icon
        
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
        for i in 0..<4 {
            let bit = Bit(context: managedObjectContext)
            bit.order = Int16(i)
            bit.attributes = [:]
            bits2 += [bit]
        }
        
        bits2[0].name = "Necklace"
        bits2[0].image = UIImage(imageLiteralResourceName: "sample3a").pngData()
        bits2[0].attributes!["Origin"] = "Christmas"
        bits2[0].attributes!["Year Obtained"] = "2014"
        bits2[0].paragraph = ""
        
        bits2[1].name = "Teddy"
        bits2[1].image = UIImage(imageLiteralResourceName: "sample3b").pngData()
        bits2[1].attributes!["Origin"] = "Childhood"
        bits2[1].attributes!["Year Obtained"] = "2000"
        bits2[1].paragraph = ""
        
        bits2[2].name = "Souvenir"
        bits2[2].image = UIImage(imageLiteralResourceName: "sample3c").pngData()
        bits2[2].attributes!["Origin"] = "Mt. Rushmore"
        bits2[2].attributes!["Year Obtained"] = "2018"
        bits2[2].paragraph = ""
        
        bits2[3].name = "Ornament"
        bits2[3].image = UIImage(imageLiteralResourceName: "sample3d").pngData()
        bits2[3].attributes!["Origin"] = "Christmas"
        bits2[3].attributes!["Year Obtained"] = "2020"
        bits2[3].paragraph = ""
        
        // Finalize Bob
         
        bobs[2].sort = 3 // sort by Year Obtained
        bobs[2].bits = NSSet(array: bits2)
        bobs[2].attributes = NSSet(array: attrs2)
        bobs[2].nextBitID = Int16(bits2.count)
        bobs[2].nextAttrID = Int16(attrs2.count)
                
        PersistenceController.shared.save()

    }
}


struct RearrangeBobOrder: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @FetchRequest(
        entity: Bit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bit.order, ascending: true)
        ]
    ) var bits: FetchedResults<Bit>
    
    @State private var deleteBob: Bob? = nil
    
    var body: some View {
        VStack {
            Text("Edit Bobs")
                .font(.headline)
                .padding(10)
            List {
                ForEach(self.bobs.map { $0 }, id: \.self) { bob in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 35)
                            Image(systemName: "minus")
                                .foregroundColor(Color(UIColor.white))
                        }
                        .onTapGesture {
                            self.deleteBob = bob
                            print("Deleting \(bob.name ?? "")")
                        }
                        .padding(.leading, -20)
                        
                        Text(bob.name ?? "")
                            .fontWeight(.semibold)
                    }
                }
                .onMove(perform: moveBobs)
                .alert(item: $deleteBob) { bob in
                    Alert(
                        title: Text("Delete \(bob.name ?? "")"),
                        message: Text("Are you absolutely sure you want to delete this bob? This will also delete all of the bits, attributes, and settings it contains. This action cannot be undone."),
                        primaryButton: .cancel() {
                            deleteBob = nil
                        },
                        secondaryButton: .destructive(Text("Delete")) {
                            removeBob(bob)
                            deleteBob = nil
                        }
                    )
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
        }
        .onAppear {
            PersistenceController.haptic(.medium)
        }
    }
    
    func moveBobs(from source: IndexSet, to destination: Int) {
        var revisedItems: [Bob] = bobs.map{ $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        PersistenceController.shared.save()
    }
    
    func removeBob(_ bob: Bob) {
        var reivsedItems: [Bob] = bobs.map { $0 }
        // Remove any bits of that bob
        for bit in bits {
            if bit.bob == bob {
                managedObjectContext.delete(bit)
            }
        }
        let index = reivsedItems.firstIndex(of: bob)!
        reivsedItems.remove(at: index)
        managedObjectContext.delete(bob)
        reorderBobs(reivsedItems)
    }
    
    func reorderBobs(_ array: [Bob]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        PersistenceController.nextBobID = Int16(revisedItems.count)
        PersistenceController.shared.save()
    }
}


extension View {
    func phoneOnlyStackNavigationView(_ geometry: GeometryProxy) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone || geometry.size.height >= geometry.size.width {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
