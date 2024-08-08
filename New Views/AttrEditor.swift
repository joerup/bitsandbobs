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
    
    // Organization
    @State var sortable: Bool = false
    @State var groupable: Bool = false
    @State var taggable: Bool = false
    
    // Text
    @State var presets: [String] = [""]
    
    // Numbers
    @State var decimal: Bool = false
    @State var prefix: String = ""
    @State var suffix: String = ""
    
    // Booleans
    @State var boolType: Int = 0
    
    @State private var editPresets = false
    @State private var createEmptyWarning = false
    @State private var cancelAlert = false
    
    @State private var deleteAttribute = false
    
    @Binding var bobHasChanges: Bool
    @State private var hasChanges = false

    @Environment(\.dismiss) var dismiss
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }
    
    init(attribute: Attribute? = nil, attributes: Binding<[Attribute]>, nextAttrID: Binding<Int16>, bob: Bob? = nil, hasChanges: Binding<Bool>) {
        self.attribute = attribute
        self._attributes = attributes
        self._nextAttrID = nextAttrID
        self.bob = bob
        
        self._bobHasChanges = hasChanges
        
        if let attribute {
            self.create = false
            
            self._name = State(initialValue: attribute.name ?? "")
            self._displayName = State(initialValue: attribute.displayName ?? attribute.name ?? "")
            self._type = State(initialValue: Int(attribute.type))
            self._allowMultiple = State(initialValue: attribute.allowMultiple)
            self._maxCount = State(initialValue: attribute.maxCount == 0 ? "" : String(attribute.maxCount))
            
            // Organization
            self._sortable = State(initialValue: attribute.sortable)
            self._groupable = State(initialValue: attribute.groupable)
            self._taggable = State(initialValue: attribute.taggable)
            
            // Text
            self._presets = State(initialValue: attribute.presets ?? [])
            
            // Numbers
            self._decimal = State(initialValue: attribute.decimal)
            self._prefix = State(initialValue: attribute.prefix ?? "")
            self._suffix = State(initialValue: attribute.suffix ?? "")
            
            // Booleans
            self._boolType = State(initialValue: Int(attribute.boolType))
        }
        
        self.hasChanges = false
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
                                .onChange(of: name) { _ in
                                    hasChanges = true
                                }
                        }
                        else {
                            TextField("Name", text: self.$displayName)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: displayName) { _ in
                                    hasChanges = true
                                }
                        }
                    }
                    
                    AStack {
                        Text("Data Type")
                        Spacer()
                        Menu {
                            Picker("", selection: $type) {
                                Text("Text")
                                    .tag(0)
                                Text("Number")
                                    .tag(1)
                                Text("Boolean")
                                    .tag(2)
                            }
                        } label: {
                            HStack {
                                Text(type == 0 ? "Text" : type == 1 ? "Number" : "Boolean")
                                Image(systemName: "chevron.up.chevron.down").imageScale(.small)
                            }
                        }
                        .onChange(of: type) { _ in
                            hasChanges = true
                        }
                    }
                }
                
                if self.type != 2 {
                    
                    Section {
                        
                        Toggle(isOn: self.$allowMultiple) {
                            Text("Multiple Values")
                        }
                        .onChange(of: allowMultiple) { _ in
                            hasChanges = true
                        }
                        
                        if self.allowMultiple {
                            AStack {
                                Text("Maximum Count")
                                Spacer()
                                TextField("Unlimited", text: self.$maxCount, onCommit: {
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
                            .onChange(of: maxCount) { _ in
                                hasChanges = true
                            }
                        }
                    }
                }
                
                if self.type == 0 {
                    Section {
                        if !self.allowMultiple {
                            Toggle(isOn: self.$sortable) {
                                Text("Sorting")
                            }
                            .onChange(of: sortable) { _ in
                                hasChanges = true
                            }
                        }
                        
                        Toggle(isOn: self.$groupable) {
                            Text("Grouping")
                        }
                        .onChange(of: groupable) { _ in
                            hasChanges = true
                        }
                        
                        Toggle(isOn: self.$taggable) {
                            Text("Filtering")
                        }
                        .onChange(of: taggable) { _ in
                            hasChanges = true
                        }
                    } footer: {
                        Text("Allow the collection to be organized based on this attribute.")
                    }
                    
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
                            }
                            .padding(.leading)
                        }
                    }, footer: Text("Possible values for this attribute.")
                    ){
                        ForEach(self.presets.indices, id: \.self) { p in
                            TextField("Value", text: Binding(
                                get: { self.presets[p] },
                                set: { self.presets[p] = $0; hasChanges = true }))
                            .foregroundColor(Color(UIColor.label))
                        }
                        .onMove(perform: moveAttributePresets)
                        .onDelete(perform: removeAttributePresets)
                    }
                    .onAppear {
                        if let bob, let attribute {
                            for bit in bob.bitArray {
                                for value in bit.allAttributeValues(attribute.name) {
                                    if !self.presets.contains(value) && value != "" {
                                        self.presets += [value]
                                    }
                                }
                            }
                        }
                        self.presets.removeAll(where: { $0 == "" })
                        self.presets += [""]
                    }
                    .onChange(of: presets) { presets in
                        if presets.last != "" {
                            self.presets += [""]
                        }
                        while self.presets.count >= 2 && self.presets[self.presets.count-2].isEmpty && self.presets[self.presets.count-1].isEmpty {
                            self.presets.removeLast()
                        }
                    }
                }
                else if type == 1 {
                    
                    Section {
                        
                        Toggle(isOn: self.$decimal) {
                            Text("Decimals")
                        }
                        .onChange(of: decimal) { _ in
                            hasChanges = true
                        }
                    }
                    
                    Section {

                        AStack {
                            Text("Prefix")
                            Spacer()
                            TextField("Prefix", text: self.$prefix)
                                .multilineTextAlignment(.trailing)
                                .autocapitalization(.none)
                        }
                        .onChange(of: prefix) { _ in
                            hasChanges = true
                        }

                        AStack {
                            Text("Suffix")
                            Spacer()
                            TextField("Suffix", text: self.$suffix)
                                .multilineTextAlignment(.trailing)
                                .autocapitalization(.none)
                        }
                        .onChange(of: suffix) { _ in
                            hasChanges = true
                        }
                    } footer: {
                        Text("Display a prefix and/or suffix with the number. (currency, units, etc.)")
                    }
                    
                    Section {
                        
                        if !self.allowMultiple {
                            Toggle(isOn: self.$sortable) {
                                Text("Sorting")
                            }
                            .onChange(of: sortable) { _ in
                                hasChanges = true
                            }
                        }
                        
                        if !self.decimal {
                            
                            Toggle(isOn: self.$groupable) {
                                Text("Grouping")
                            }
                            .onChange(of: groupable) { _ in
                                hasChanges = true
                            }
                            
                            Toggle(isOn: self.$taggable) {
                                Text("Filtering")
                            }
                            .onChange(of: taggable) { _ in
                                hasChanges = true
                            }
                            
                        }
                    } footer: {
                        Text("Allow the collection to be organized based on this attribute.")
                    }
                }
                else if type == 2 {
                    
                    Section {
                        AStack {
                            Text("Display Type")
                            Spacer()
                            Menu {
                                Picker("", selection: $boolType) {
                                    Text("True/False")
                                        .tag(0)
                                    Text("Yes/No")
                                        .tag(1)
                                }
                            } label: {
                                HStack {
                                    Text(boolType == 0 ? "True/False" : "Yes/No")
                                    Image(systemName: "chevron.up.chevron.down").imageScale(.small)
                                }
                            }
                            .onChange(of: boolType) { _ in
                                hasChanges = true
                            }
                        }
                    }
                    
                    Section {
                        
                        Toggle(isOn: self.$groupable) {
                            Text("Grouping")
                        }
                        .onChange(of: groupable) { _ in
                            hasChanges = true
                        }
                        
                        Toggle(isOn: self.$taggable) {
                            Text("Filtering")
                        }
                        .onChange(of: taggable) { _ in
                            hasChanges = true
                        }
                    } footer: {
                        Text("Allow the collection to be organized based on this attribute.")
                    }
                }
                
                if !create {
                    Button(role: .destructive) {
                        self.deleteAttribute.toggle()
                    } label: {
                        HStack {
                            Text("Delete Attribute")
                            Spacer()
                            Image(systemName: "trash")
                                .font(.callout)
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(self.editPresets ? EditMode.active : EditMode.inactive))
            .navigationBarTitle(create ? "New Attribute" : "Edit Attribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if !hasChanges {
                            dismiss()
                        } else {
                            self.cancelAlert.toggle()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(.headline, design: .rounded))
                    }
                    .confirmationDialog("Cancel", isPresented: $cancelAlert) {
                        Button(create ? "Delete Attribute" : "Discard Changes", role: .destructive) {
                            dismiss()
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
                    }
                    .disabled(self.name == "" || (self.displayName == "" && !create))
                    .alert(isPresented: self.$createEmptyWarning) {
                        Alert(title: Text("Please give the attribute a name."))
                    }
                }
            }
            .alert(isPresented: $deleteAttribute) {
                Alert(
                    title: Text("Delete \(self.displayName)"),
                    message: Text("Are you sure you want to delete this attribute?"),
                    primaryButton: .cancel() {
                        deleteAttribute = false
                    },
                    secondaryButton: .destructive(Text("Delete")) {
                        dismiss()
                        removeAttribute()
                    }
                )
            }
        }
        .interactiveDismissDisabled()
        .tint(PersistenceController.themeColor)
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
        
        if create {
            
            let attribute = Attribute(context: managedObjectContext)
           
            attribute.order = self.nextAttrID
            self.nextAttrID += 1
            
            attribute.name = self.name
            attribute.displayName = self.displayName != "" ? self.displayName : self.name
            attribute.type = Int16(self.type)
            attribute.allowMultiple = self.type == 2 ? false : self.allowMultiple
            attribute.maxCount = Int16(self.maxCount) ?? 0
            
            // Organization
            attribute.sortable = self.sortable
            attribute.taggable = self.taggable
            attribute.groupable = self.groupable
            
            // Text
            attribute.presets = self.presets
            
            // Numbers
            attribute.decimal = self.decimal
            attribute.prefix = self.prefix
            attribute.suffix = self.suffix
            
            // Booleans
            attribute.boolType = Int16(self.boolType)
            
            self.attributes += [attribute]
        }
        else if self.attribute != nil {
            
            managedObjectContext.performAndWait {
                attribute!.name = self.name
                attribute!.displayName = self.displayName != "" ? self.displayName : self.name
                attribute!.type = Int16(self.type)
                attribute!.allowMultiple = self.type == 2 ? false : self.allowMultiple
                attribute!.maxCount = Int16(self.maxCount) ?? 0
                
                // Organization
                attribute!.sortable = self.sortable
                attribute!.groupable = self.groupable
                attribute!.taggable = self.taggable
                
                // Text
                attribute!.presets = self.presets
                
                // Numbers
                attribute!.decimal = self.decimal
                attribute!.prefix = self.prefix
                attribute!.suffix = self.suffix
                
                // Booleans
                attribute!.boolType = Int16(self.boolType)
            }
            
            self.attributes[Int(attribute!.order)] = attribute!
            self.attributes += [attribute!]
            self.attributes.removeLast()
        }
        
        bobHasChanges = true
        
        // do not actually save (this is all nested within bob editor) but still play haptic
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()

        dismiss()
    }
    
    func removeAttribute() {
        guard let attribute else { return }
        var revisedItems: [Attribute] = attributes.map{ $0 }
        revisedItems.remove(at: Int(attribute.order))
        managedObjectContext.delete(attribute)
        reorderAttributes(revisedItems)
    }
    
    func reorderAttributes(_ array: [Attribute]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        self.attributes = revisedItems
        self.nextAttrID = Int16(revisedItems.count)
    }
}

