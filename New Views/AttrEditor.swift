//
//  AttrEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/1/21.
//

import SwiftUI

struct AttrEditor: View {
    
    var attribute: Attribute? = nil
    
    @Binding var attributes: [Attribute]
    @Binding var nextAttrID: Int16
    
    var bob: Bob? = nil
    
    var create: Bool = true
    
    @State var name = ""
    @State var displayName = ""
    @State var type = 0
    
    // Text
    @State var presets: [String] = []
    @State var restrictPresets: Bool = false
    @State var sortable: Bool = true
    @State var groupable: Bool = false
    @State var sortTextType: Int = 0
    @State var unassignedGroup: Bool = false
    
    // Numbers
    @State var decimal: Bool = false
    @State var maxNum: String = ""
    @State var minNum: String = ""
    @State var maxIncluded: Bool = false
    @State var minIncluded: Bool = true
    @State var prefix: String = ""
    @State var suffix: String = ""
    
    // Booleans
    @State var boolType: Int = 0
    @State var boolDisplayFalse = false
    
    // States
    @State private var editPresets = false
    @State private var createEmptyWarning = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }
    
    var body: some View {
        
        ZStack {
        
            ScrollView {
                
                VStack {
                    
                    VStack {
                    
                        Text(create ? "New Attribute" : "Edit Attribute")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(create ? "Create a new attribute which each bit can be given a value for" : "Edit the \(displayName) attribute")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.systemGray2))
                            .multilineTextAlignment(.center)
                        
                        if create {
                            TextField("Name", text: self.$name)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                        else {
                            TextField("Name", text: self.$displayName)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    if self.type == 0 {
                    
                        Form {
                            
                            Section(header: Text("Data Type")) {
                            
                                Picker("Type", selection: self.$type) {
                                    Text("Text")
                                        .tag(0)
                                    Text("Number")
                                        .tag(1)
                                    Text("Boolean")
                                        .tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Section(header: Text("Sorting")) {
                                
                                Toggle(isOn: self.$sortable) {
                                    VStack(alignment: .leading) {
                                        Text("Sortable")
                                        Text("Bits can be sorted by this attribute")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                
                                Toggle(isOn: self.$groupable) {
                                    VStack(alignment: .leading) {
                                        Text("Groupable")
                                        Text("Bits can be grouped by this attribute")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                
                                if self.sortable || self.groupable {
                                    HStack {
                                        Text("Sorting Method")
                                        Picker("Sorting Method", selection: self.$sortTextType) {
                                            Text("As Listed")
                                                .tag(0)
                                            Text("ABC Order")
                                                .tag(1)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                }
                                
                                if self.groupable {
                                    Toggle(isOn: self.$unassignedGroup) {
                                        VStack(alignment: .leading) {
                                            Text("Include Unassigned Group")
                                            Text("For bits that are not given a value")
                                                .foregroundColor(Color(UIColor.systemGray2))
                                                .font(.caption)
                                        }
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                }
                            }
                            
                            Section(header: Text("Presets")) {
                                
                                Toggle(isOn: self.$restrictPresets) {
                                    VStack(alignment: .leading) {
                                        Text("Restrict to Presets Only")
                                        Text("Only presets can be chosen for bit values")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                
                                ZStack {
                                    Text("Presets")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    HStack {
                                        Button(action: {
                                            self.presets += [""]
                                            PersistenceController.haptic(.medium)
                                        }) {
                                            Text("New")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(PersistenceController.themeColor)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Spacer()
                                        Button(action: {
                                            PersistenceController.haptic(.medium)
                                            self.editPresets.toggle()
                                        }) {
                                            Text(self.editPresets ? "Done" : "Edit")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(PersistenceController.themeColor)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 10)
                                
                                if self.presets.isEmpty {
                                    Text("Define possible values for this attribute which bits can choose from.")
                                        .multilineTextAlignment(.center)
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.systemGray2))
                                        .padding(15)
                                }
                                
                                ForEach(self.presets.indices, id: \.self) { p in
                                    Button(action: {
                                        PersistenceController.haptic(.medium)
                                    }) {
                                        TextField("Value", text: Binding(
                                                    get: { self.presets[p] },
                                                    set: { self.presets[p] = $0 }))
                                            .foregroundColor(Color(UIColor.systemGray))
                                    }
                                }
                                .onMove(perform: moveAttributePresets)
                                .onDelete(perform: removeAttributePresets)
                            }
                        }
                        .frame(height: self.presets.isEmpty ? 700 : CGFloat(self.presets.count) * 50 + 600)
                        .environment(\.editMode, .constant(self.editPresets ? EditMode.active : EditMode.inactive))
                        .animation(.default)
                    }
                    else if type == 1 {
                        
                        Form {
                            
                            Section(header: Text("Data Type")) {
                            
                                Picker("Type", selection: self.$type) {
                                    Text("Text")
                                        .tag(0)
                                    Text("Number")
                                        .tag(1)
                                    Text("Boolean")
                                        .tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Section(header: Text("Restrictions")) {
                                
                                Toggle(isOn: self.$decimal) {
                                    Text("Allow Decimals")
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                .onChange(of: self.decimal) { value in
                                    self.maxNum = self.maxNum == "" ? "" : value ? String(Double(self.maxNum)!) : String(Int(Double(self.maxNum)!))
                                    self.minNum = self.minNum == "" ? "" : value ? String(Double(self.minNum)!) : String(Int(Double(self.minNum)!))
                                }
                                
                                HStack {
                                    Text("Minimum")
                                    Spacer()
                                    TextField("No Limit", text: self.$minNum, onCommit: {
                                        PersistenceController.haptic(.medium)
                                        // Reject if not a number
                                        if Double(self.minNum) == nil {
                                            self.minNum = ""
                                            self.minIncluded = false
                                            return
                                        }
                                        // Turn to integer if decimals are not allowed
                                        if !self.decimal && Int(self.minNum) == nil {
                                            self.minNum = String(Int(Double(self.minNum)!))
                                        }
                                    })
                                    .font(.title3)
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    if self.minNum != "" {
                                        Text(self.minIncluded ? "Inclusive" : "Not inclusive")
                                            .font(.caption)
                                            .foregroundColor(Color(UIColor.systemGray3))
                                            .onTapGesture {
                                                self.minIncluded.toggle()
                                            }
                                    }
                                }
                                .animation(.default)

                                HStack {
                                    Text("Maximum")
                                    Spacer()
                                    TextField("No Limit", text: self.$maxNum, onCommit: {
                                        PersistenceController.haptic(.medium)
                                        // Reject if not a number
                                        if Double(self.maxNum) == nil {
                                            self.maxNum = ""
                                            self.maxIncluded = false
                                            return
                                        }
                                        // Turn to integer if decimals are not allowed
                                        if !self.decimal && Int(self.maxNum) == nil {
                                            self.maxNum = String(Int(Double(self.maxNum)!))
                                        }
                                    })
                                    .font(.title3)
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    if self.maxNum != "" {
                                        Text(self.maxIncluded ? "Inclusive" : "Not inclusive")
                                            .font(.caption)
                                            .foregroundColor(Color(UIColor.systemGray3))
                                            .onTapGesture {
                                                self.maxIncluded.toggle()
                                            }
                                    }
                                }
                                .animation(.default)
                            }
                            
                            Section(header: Text("Styling")) {

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Prefix")
                                        Text("Displayed before number, ex. $")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                    Spacer()
                                    TextField("Prefix", text: self.$prefix)
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                }

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Suffix")
                                        Text("Displayed after number, ex. units")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                    Spacer()
                                    TextField("Suffix", text: self.$suffix)
                                        .font(.title3)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            
                            if !self.decimal {
                            
                                Section(header: Text("Grouping")) {
                                    
                                    Toggle(isOn: self.$groupable) {
                                        VStack(alignment: .leading) {
                                            Text("Groupable")
                                            Text("Bits can be grouped by this attribute")
                                                .foregroundColor(Color(UIColor.systemGray2))
                                                .font(.caption)
                                        }
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                    
                                    if self.groupable {
                                        Toggle(isOn: self.$unassignedGroup) {
                                            VStack(alignment: .leading) {
                                                Text("Include Unassigned Group")
                                                Text("For bits that are not given a value")
                                                    .foregroundColor(Color(UIColor.systemGray2))
                                                    .font(.caption)
                                            }
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                                    }
                                }
                            }
                        }
                        .frame(height: 750)
                    }
                    else if type == 2 {
                        
                        Form {
                            
                            Section(header: Text("Data Type")) {
                            
                                Picker("Type", selection: self.$type) {
                                    Text("Text")
                                        .tag(0)
                                    Text("Number")
                                        .tag(1)
                                    Text("Boolean")
                                        .tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Section(header: Text("Display Options")) {
                            
                                HStack {
                                    Text("Wording")
                                    Picker("Wording", selection: self.$boolType) {
                                        Text("True/False")
                                            .tag(0)
                                        Text("Yes/No")
                                            .tag(1)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                Toggle(isOn: self.$boolDisplayFalse) {
                                    VStack(alignment: .leading) {
                                        Text("Display only if True")
                                        Text("Hide attribute from bit unless true")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                            .font(.caption)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                            }
                        }
                        .frame(height: 400)
                    }
                }
            }
            
            VStack {
                
                Spacer()
            
                Button(action: {
                    PersistenceController.haptic(.medium)
                    saveAttribute()
                }) {
                    Text("Save")
                        .font(.headline)
                        .padding(20)
                        .foregroundColor(.white)
                        .background(PersistenceController.themeColor)
                        .cornerRadius(100)
                }
                .shadow(color: Color(UIColor.systemGray6), radius: 10)
                .padding(20)
                .alert(isPresented: self.$createEmptyWarning) {
                    Alert(title: Text("Please give the attribute a name."))
                }
            }
        }
        .onAppear {
            if attribute != nil {
                self.name = attribute!.name ?? ""
                self.displayName = attribute!.displayName ?? attribute!.name ?? ""
                self.type = Int(attribute!.type)
                
                // Text
                self.presets = attribute!.presets ?? []
                if bob != nil {
                    for bit in bob!.bitArray {
                        let value = bit.attributes?[attribute!.name ?? ""] ?? ""
                        if !self.presets.contains(value) && value != "" {
                            self.presets += [value]
                        }
                    }
                }
                self.restrictPresets = attribute!.restrictPresets
                self.sortable = attribute!.sortable
                self.groupable = attribute!.groupable
                self.sortTextType = Int(attribute!.sortTextType)
                self.unassignedGroup = attribute!.unassignedGroup
                
                // Numbers
                self.decimal = attribute!.decimal
                self.maxNum = attribute!.maxNum == Double.infinity ? "" : self.decimal ? String(attribute!.maxNum) : String(Int(attribute!.maxNum))
                self.minNum = attribute!.minNum == -Double.infinity ? "" : self.decimal ? String(attribute!.minNum) : String(Int(attribute!.minNum))
                self.maxIncluded = attribute!.maxNum == Double.infinity ? false : attribute!.maxIncluded
                self.minIncluded = attribute!.minNum == -Double.infinity ? false : attribute!.minIncluded
                self.prefix = attribute!.prefix ?? ""
                self.suffix = attribute!.suffix ?? ""
                
                // Booleans
                self.boolType = Int(attribute!.boolType)
                self.boolDisplayFalse = attribute!.boolDisplayFalse
            }
        }
    }
    
    func moveAttributePresets(from source: IndexSet, to destination: Int) {
        self.presets.move(fromOffsets: source, toOffset: destination )
    }
    
    func removeAttributePresets(at offsets: IndexSet) {
        self.presets.remove(atOffsets: offsets)
    }
    
    func saveAttribute() {

        guard self.name != "" else {
            self.createEmptyWarning.toggle()
            return
        }
        guard self.displayName != "" || create else {
            self.createEmptyWarning.toggle()
            return
        }
    
        self.presets.removeAll(where: { $0 == "" })
        
        if create {
            
            let attribute = Attribute(context: managedObjectContext)
           
            attribute.order = self.nextAttrID
            self.nextAttrID += 1
            
            attribute.name = self.name
            attribute.displayName = self.displayName != "" ? self.displayName : self.name
            attribute.type = Int16(self.type)
            
            // Text
            attribute.presets = self.presets
            attribute.restrictPresets = self.restrictPresets
            attribute.sortable = self.sortable
            attribute.groupable = self.groupable
            attribute.sortTextType = Int16(self.sortTextType)
            attribute.unassignedGroup = self.unassignedGroup
            
            // Numbers
            attribute.decimal = self.decimal
            attribute.maxNum = self.maxNum == "" ? Double.infinity : self.decimal ? Double(self.maxNum)! : Double(Int(Double(self.maxNum)!))
            attribute.minNum = self.minNum == "" ? -Double.infinity : self.decimal ? Double(self.minNum)! : Double(Int(Double(self.minNum)!))
            attribute.maxIncluded = self.maxNum == "" ? false : self.maxIncluded
            attribute.minIncluded = self.minNum == "" ? false : self.minIncluded
            attribute.prefix = self.prefix
            attribute.suffix = self.suffix
            
            // Booleans
            attribute.boolType = Int16(self.boolType)
            attribute.boolDisplayFalse = self.boolDisplayFalse
            
            self.attributes += [attribute]
        }
        else if self.attribute != nil {
            
            managedObjectContext.performAndWait {
                attribute!.name = self.name
                attribute!.displayName = self.displayName != "" ? self.displayName : self.name
                attribute!.type = Int16(self.type)
                
                // Text
                attribute!.presets = self.presets
                attribute!.restrictPresets = self.restrictPresets
                attribute!.sortable = self.sortable
                attribute!.groupable = self.groupable
                attribute!.sortTextType = Int16(self.sortTextType)
                attribute!.unassignedGroup = self.unassignedGroup
                
                // Numbers
                attribute!.decimal = self.decimal
                attribute!.maxNum = self.maxNum == "" ? Double.infinity : self.decimal ? Double(self.maxNum)! : Double(Int(Double(self.maxNum)!))
                attribute!.minNum = self.minNum == "" ? -Double.infinity : self.decimal ? Double(self.minNum)! : Double(Int(Double(self.minNum)!))
                attribute!.maxIncluded = self.maxNum == "" ? false : self.maxIncluded
                attribute!.minIncluded = self.minNum == "" ? false : self.minIncluded
                attribute!.prefix = self.prefix
                attribute!.suffix = self.suffix
                
                // Booleans
                attribute!.boolType = Int16(self.boolType)
                attribute!.boolDisplayFalse = self.boolDisplayFalse
            }
            
            self.attributes[Int(attribute!.order)] = attribute!
            self.attributes += [attribute!]
            self.attributes.removeLast()
        }
        
        PersistenceController.shared.save()

        presentationMode.wrappedValue.dismiss()
    }
}

