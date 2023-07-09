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
    
    @State var name: String = ""
    @State var displayName: String = ""
    @State var type: Int = 0
    @State var allowMultiple: Bool = false
    @State var maxCount: String = ""
    
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
    
    @State private var editPresets = false
    @State private var createEmptyWarning = false
    @State private var cancelAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section {
                    AStack {
                        Text("Name")
                        Spacer()
                        if create {
                            TextField("Name", text: self.$name)
                                .multilineTextAlignment(.trailing)
                        }
                        else {
                            TextField("Name", text: self.$displayName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Picker("Data Type", selection: self.$type) {
                        Text("Text")
                            .tag(0)
                        Text("Number")
                            .tag(1)
                        Text("Boolean")
                            .tag(2)
//                        Text("Date")
//                            .tag(3)
                    }
                    .pickerStyle(.menu)
                    .accentColor(PersistenceController.themeColor)
                }
                
                if self.type != 2 {
                    
                    Section {
                        
                        Toggle(isOn: self.$allowMultiple) {
                            Text("Multiple Values")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        
                        if self.allowMultiple {
                            AStack {
                                Text("Count")
                                Spacer()
                                TextField("Any", text: self.$maxCount, onCommit: {
                                    // Reject if less than 2 or not a number
                                    if Int(self.maxCount) == nil || Int(self.maxCount)! < 2 {
                                        self.maxCount = ""
                                        return
                                    }
                                    // Turn to integer if decimal
                                    if Int(self.maxCount) == nil {
                                        self.maxCount = String(Int(Double(self.maxCount)!))
                                    }
                                })
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            }
                            .animation(.default, value: allowMultiple)
                        }
                    } footer: {
                        if allowMultiple {
                            Text("Each item can have \(!allowMultiple ? "one value" : (maxCount == "" ? "any number of values" : "\(maxCount) values")) set for this attribute.")
                        }
                    }
                }
                
                if self.type == 0 {
                    
                    Section(header: HStack {
                        Text("Presets")
                            .lineLimit(0)
                            .font(.callout)
                        Spacer()
                        if !presets.isEmpty {
                            Button(action: {
                                self.editPresets.toggle()
                            }) {
                                Text(self.editPresets ? "Done" : "Edit")
                                    .font(.callout)
                                    .foregroundColor(PersistenceController.themeColor)
                            }
                            .padding(.leading)
                        }
                    }, footer: Text(restrictPresets ? "Values must be chosen from this list." : "Values may be chosen from this list, or others may be entered.")) {
                        ForEach(self.presets.indices, id: \.self) { p in
                            TextField("Value", text: Binding(
                                get: { self.presets[p] },
                                set: { self.presets[p] = $0 }))
                            .foregroundColor(Color(UIColor.label))
                        }
                        .onMove(perform: moveAttributePresets)
                        .onDelete(perform: removeAttributePresets)
                    }
                    .onAppear {
                        if presets.last != "" {
                            self.presets += [""]
                        }
                    }
                    .onChange(of: presets) { presets in
                        if presets.last != "" {
                            self.presets += [""]
                        }
                        while self.presets.count >= 2 && self.presets[self.presets.count-2].isEmpty && self.presets[self.presets.count-1].isEmpty {
                            self.presets.removeLast()
                        }
                    }
                    
                    if !presets.isEmpty || restrictPresets {
                        Section {
                            Toggle(isOn: self.$restrictPresets) {
                                Text("Restrict Choices to Presets")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        }
                    }
                    
                    Section {
                        
                        if !self.allowMultiple {
                            Toggle(isOn: self.$sortable) {
                                Text("Sortable")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        }
                        
                        Toggle(isOn: self.$groupable) {
                            Text("Groupable")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        
                        if self.groupable {
                            Toggle(isOn: self.$unassignedGroup) {
                                Text("Include Unassigned Group")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                            .animation(.default, value: groupable)
                        }
                        
                        if self.sortable || self.groupable {
                            Picker("Default Order", selection: self.$sortTextType) {
                                Text("As Listed")
                                    .tag(0)
                                Text("ABC Order")
                                    .tag(1)
                            }
                            .pickerStyle(.menu)
                            .accentColor(PersistenceController.themeColor)
                            .animation(.default, value: sortable || groupable)
                        }
                    }
                }
                else if type == 1 {
                    
                    Section {
                        
                        Toggle(isOn: self.$decimal) {
                            Text("Allow Decimals")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        .onChange(of: self.decimal) { value in
                            self.maxNum = self.maxNum == "" ? "" : value ? String(Double(self.maxNum)!) : String(Int(Double(self.maxNum)!))
                            self.minNum = self.minNum == "" ? "" : value ? String(Double(self.minNum)!) : String(Int(Double(self.minNum)!))
                        }
                        
                        AStack {
                            Text("Minimum")
                            Spacer()
                            TextField("No Limit", text: self.$minNum, onCommit: {
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

                        AStack {
                            Text("Maximum")
                            Spacer()
                            TextField("No Limit", text: self.$maxNum, onCommit: {
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
                    } footer: {
                        Text("Values \(maxNum == "" && minNum == "" ? (decimal ? "can be any number" : "can be any integer") : "must be \(decimal ? "" : "integers ")")\(maxNum != "" && minNum != "" ? "between \(minNum) and \(maxNum)" : "")\(maxNum != "" && minNum == "" ? "less than\(maxIncluded ? " or equal to" : "") \(maxNum)" : "")\(minNum != "" && maxNum == "" ? "greater than\(minIncluded ? " or equal to" : "") \(minNum)" : "").")
                    }
                    
                    Section {

                        AStack {
                            Text("Prefix")
                            Spacer()
                            TextField("Prefix", text: self.$prefix)
                                .multilineTextAlignment(.trailing)
                                .autocapitalization(.none)
                        }

                        AStack {
                            Text("Suffix")
                            Spacer()
                            TextField("Suffix", text: self.$suffix)
                                .multilineTextAlignment(.trailing)
                                .autocapitalization(.none)
                        }
                    } footer: {
                        Text("Titles, units, currency symbols, etc.")
                    }
                    
                    if !self.decimal {
                    
                        Section {
                            
                            Toggle(isOn: self.$groupable) {
                                Text("Groupable")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                            
                            if self.groupable {
                                Toggle(isOn: self.$unassignedGroup) {
                                    Text("Include Unassigned Group")
                                }
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                            }
                        }
                    }
                }
                else if type == 2 {
                    
                    Section {
                    
                        Picker("Display Type", selection: self.$boolType) {
                            Text("True/False")
                                .tag(0)
                            Text("Yes/No")
                                .tag(1)
                        }
                        .pickerStyle(.menu)
                        .accentColor(PersistenceController.themeColor)
                    
                        Toggle(isOn: self.$boolDisplayFalse) {
                            Text("Display only if True")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                    }
                }
            }
            .environment(\.editMode, .constant(self.editPresets ? EditMode.active : EditMode.inactive))
            .navigationBarTitle(create ? "New Attribute" : "Edit Attribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if create && name.isEmpty {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.cancelAlert.toggle()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(PersistenceController.themeColor)
                    }
                    .confirmationDialog("Cancel", isPresented: $cancelAlert) {
                        Button(create ? "Delete Attribute" : "Discard Changes", role: .destructive) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        Button(create ? "Save Attribute" : "Save Changes") {
                            saveAttribute()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveAttribute()
                    }) {
                        Text("Save")
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(self.name == "" ? .gray : PersistenceController.themeColor)
                    }
                    .alert(isPresented: self.$createEmptyWarning) {
                        Alert(title: Text("Please give the attribute a name."))
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if attribute != nil {
                self.name = attribute!.name ?? ""
                self.displayName = attribute!.displayName ?? attribute!.name ?? ""
                self.type = Int(attribute!.type)
                self.allowMultiple = attribute!.allowMultiple
                self.maxCount = attribute!.maxCount == 0 ? "" : String(attribute!.maxCount)
                
                // Text
                self.presets = attribute!.presets ?? []
                if bob != nil {
                    for bit in bob!.bitArray {
                        for value in bit.allAttributeValues(attribute!.name) {
                            if !self.presets.contains(value) && value != "" {
                                self.presets += [value]
                            }
                        }
                    }
                }
                self.presets.removeAll(where: { $0 == "" })
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
        
        if !(self.maxCount == "" || Double(self.maxCount) != nil) { self.maxCount = "" }
        if !(self.minNum == "" || Double(self.minNum) != nil) { self.minNum = "" }
        if !(self.maxNum == "" || Double(self.maxNum) != nil) { self.maxNum = "" }
        
        if create {
            
            let attribute = Attribute(context: managedObjectContext)
           
            attribute.order = self.nextAttrID
            self.nextAttrID += 1
            
            attribute.name = self.name
            attribute.displayName = self.displayName != "" ? self.displayName : self.name
            attribute.type = Int16(self.type)
            attribute.allowMultiple = self.allowMultiple
            attribute.maxCount = Int16(self.maxCount) ?? 0
            
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
                attribute!.allowMultiple = self.allowMultiple
                attribute!.maxCount = Int16(self.maxCount) ?? 0
                
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

