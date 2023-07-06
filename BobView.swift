//
//  BobView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI
import Foundation

struct BobView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var bob: Bob
    var bits: [Bit] {
        return bob.bitArray
    }
    
    @State private var groups: [String] = []
    @State private var bitLists: [String:[Bit]] = [:]
    @State private var groupableAttributes: [Attribute] = []
    @State private var sortableAttributes: [Attribute] = []
    
    @State private var topTitle = false

    @State private var editBob = false
    @State private var newBit = false
    @State private var editBits = false
    
    @State private var moveBitWarning = false
    
    @State private var display: ListType = .smallList
    @State private var group = 0
    @State private var sort = 0
    @State private var tags: [String] = []
    @State private var sortReversed = false
    @State private var showSearch = false
    @State private var search = ""
    @FocusState private var keyboardFocused: Bool
    
    @State private var update = false
    
    var body: some View {

        GeometryReader { geometry in
            
            VStack(spacing: 0) {

                VStack(spacing: 0) {
                    
                    ZStack {
                        if bob.image == nil {
                            Rectangle()
                                .fill(Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2))
                                .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.15)
                                .cornerRadius(20)
                                .padding(10)
                        }
                        
                        Image(uiImage: bob.image != nil ? UIImage(data: bob.image!) ?? UIImage() : UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 1)
                            .frame(height: UIScreen.main.bounds.height*0.15)
                            .cornerRadius(10)
                            .padding(10)
                        
                        VStack {
                            Text(bob.name ?? "")
                                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                .tracking(-0.5)
                                .lineLimit(0)
                                .minimumScaleFactor(0.2)
                                .foregroundColor(bob.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)

                            if bob.desc != nil && bob.desc != "" {
                                Text(bob.desc ?? "")
                                    .font(.system(.headline, design: .rounded).weight(.heavy))
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                    .tracking(-0.25)
                                    .lineLimit(0)
                                    .minimumScaleFactor(0.2)
                                    .foregroundColor(Color(bob.image != nil ? UIColor.white : UIColor.systemGray))
                                    .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height*0.15)
                        .padding(.horizontal, 10)
                    }
                    
                    List {
                        
                        if showSearch {
                            
                            HStack(spacing: 0) {
                                Image(systemName: "magnifyingglass")
                                    .fontWeight(.bold)
                                    .foregroundColor(PersistenceController.themeColor)
                                    .padding(.horizontal, 5)
                                    .aspectRatio(1.0, contentMode: .fill)
                                TextField("Search", text: self.$search, onCommit: {
                                    if search == "" {
                                        self.showSearch = false
                                    }
                                })
                                .fontWeight(.regular)
                                .padding(.horizontal, 7)
                                .focused($keyboardFocused)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        keyboardFocused = true
                                    }
                                }
                                Spacer()
                                Button {
                                    self.search = ""
                                    self.showSearch = false
                                    setGroupAndSort()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.small)
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .padding(.horizontal, 5)
                                }
                                .buttonStyle(.plain)
                            }
                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                            .listRowBackground(Color(UIColor.systemGray6).cornerRadius(10).padding(.vertical, 2).padding(.horizontal, 10))
                            .onChange(of: self.search) { search in
                                setGroupAndSort()
                            }
                            
                        }
                        
                        HStack {
                                
                            Menu {
                                Picker("", selection: self.$display) {
                                    Text("Large List")
                                        .tag(ListType.largeList)
                                    Text("Small List")
                                        .tag(ListType.smallList)
//                                                    Text("Icon Grid")
//                                                        .tag(ListType.smallGrid)
//                                                    Text("Full Grid")
//                                                        .tag(ListType.largeGrid)
                                }
                            } label: {
                                circle(icon: "circle.grid.2x2", active: false)
                            }
                            
                            Menu {
                                ForEach(0..<groupableAttributes.count+1, id : \.self) { a in
                                    Button {
                                        withAnimation {
                                            self.group = a
                                        }
                                    } label: {
                                        Text(getGroup(a, display: true))
                                    }
                                }
                            } label: {
                                circle(icon: "folder", active: group != 0)
                            }
                            
                            Menu {
                                ForEach(0..<sortableAttributes.count+2, id : \.self) { a in
                                    Button {
                                        withAnimation {
                                            self.sort = a
                                        }
                                    } label: {
                                        Text(getSort(a, display: true))
                                    }
                                }
                            } label: {
                                circle(icon: "arrow.up.arrow.down", active: sort != 0)
                            }
                            
                            Spacer()
                            
                            Menu {
                                Section {
                                    Button {
                                        self.tags = []
                                    } label: {
                                        Text("None")
                                    }
                                }
                                ForEach(bob.tagList, id: \.self) { tag in
                                    Button {
                                        withAnimation {
                                            if let index = tags.firstIndex(of: tag) {
                                                self.tags.remove(at: index)
                                            } else {
                                                self.tags.append(tag)
                                            }
                                        }
                                    } label: {
                                        if tags.contains(tag) {
                                            Label(tag, systemImage: "checkmark")
                                        } else {
                                            Text(tag)
                                        }
                                    }
                                }
                            } label: {
                                circle(icon: "tag", active: !tags.isEmpty)
                            }
                            
                            Button {
                                self.showSearch.toggle()
                            } label: {
                                circle(icon: "magnifyingglass", active: showSearch)
                            }
                        }
                        .onChange(of: self.display) { _ in
                            saveBob()
                        }
                        .onChange(of: self.group) { _ in
                            setGroupAndSort()
                            saveBob()
                        }
                        .onChange(of: self.sort) { _ in
                            setGroupAndSort()
                            saveBob()
                        }
                        .onChange(of: self.tags) { _ in
                            setGroupAndSort()
                            saveBob()
                        }
                        .padding(.horizontal, -10)
                        .listRowSeparator(.hidden)
                        
                        if self.bob.bitArray.isEmpty {
                            HStack {
                                Spacer()
                                Text("This collection is empty.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .padding()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        }
                            
                        ForEach(self.groups, id: \.self) { group in
                            
                            let name = editGroupName(group)
                            let bits = self.bitLists[group]!

                            Section(header: name.isEmpty ? nil :
                                HStack(alignment: .bottom) {
                                    Text(name)
                                        .font(.system(.headline, design: .rounded, weight: .semibold))
                                    Spacer()
                                    if bits.count > 0 {
                                        Text(bitCountText(bits: bits))
                                            .font(.system(.footnote, design: .rounded, weight: .medium))
                                            .foregroundColor(Color(UIColor.systemGray2))
                                    }
                                }
                            ) {
                                if [.smallList, .largeList].contains(display) {
                                    ForEach(bits, id: \.order) { bit in
                                        
                                        NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                                            
                                            HStack {
                                                
                                                if bob.listType == 2 {
                                                    VStack {
                                                        Text(String(bit.order+1))
                                                            .font(.system(bit.order < 9 ? .title3 : .headline, design: .rounded).weight(.semibold))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(Color(UIColor.systemGray))
                                                            .minimumScaleFactor(0.5)
                                                    }
                                                    .frame(width: 30, height: 30, alignment: .center)
                                                    .padding(.leading, -6)
                                                }
                                                
                                                if display == .smallList || display == .largeList {
                                                    if let icon = bit.icon, let image = UIImage(data: icon) {
                                                        Icon(image: image,
                                                             size: display == .smallList ? 32 : 50,
                                                             faded: bob.listType == 1 && !bit.checked)
                                                        .padding(.leading, -4)
                                                        .padding(.trailing, 2)
                                                    } else {
                                                        Icon(image: nil,
                                                             size: display == .smallList ? 32 : 50,
                                                             faded: bob.listType == 1 && !bit.checked)
                                                        .padding(.leading, -4)
                                                        .padding(.trailing, 2)
                                                    }
                                                }
                                                
                                                VStack(alignment: .leading) {
                                                    
                                                    Text(bit.name ?? "")
                                                        .font(.system(.title3, design: .rounded).weight(.bold))
                                                        .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                                                        .tracking(-0.5)
                                                        .font(.title2)
                                                        .lineLimit(0)
                                                    
                                                    if self.sort >= 2 && bit.attributes != nil && display == .largeList {
                                                        if getSortAttribute(sort)?.type == 1 && bit.attributes![getSort(sort)] != nil && bit.attributes![getSort(sort)] != "" {
                                                            Text(editAttributeNumber(bit.attributes![getSort(sort)]!, attribute: getSortAttribute(sort)))
                                                                .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                                .tracking(-0.25)
                                                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                                .lineLimit(0)
                                                        }
                                                        else if bit.attributes![getSort(sort)] != nil && bit.attributes![getSort(sort)] != "" {
                                                            Text(bit.attributes![getSort(sort)]!)
                                                                .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                                .tracking(-0.25)
                                                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                                .lineLimit(0)
                                                        }
                                                    }
                                                    else if bit.desc != nil && bit.desc != "" && display == .largeList {
                                                        Text(bit.desc!)
                                                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                            .tracking(-0.25)
                                                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                            .lineLimit(0)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                if bob.listType == 1 {
                                                    Check(bob: bob, bit: bit, update: $update)
                                                }
                                            }
                                        }
                                        .id(update)
                                        .contextMenu {
                                            Button {
                                                self.editBits.toggle()
                                            } label: {
                                                Label("Reorder", systemImage: "arrow.forward")
                                            }
                                            Button {
                                                removeBit(bit: bit)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                    .onMove(perform: moveBits)
                                    .onDelete(perform: { offsets in
                                        removeBits(offsets: offsets, group: group)
                                    })
                                }
                            }
                            .padding(.horizontal, 5)
                            .listRowBackground(Color(UIColor.systemGray6).cornerRadius(10).padding(.vertical, 2).padding(.horizontal, 10))
                        }
                        .listRowSeparator(.hidden)
                        
                        if !bits.isEmpty {
                            HStack {
                                Spacer()
                                Text("\(bitCountText(bits: bits)) total")
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundColor(Color(UIColor.systemGray2))
                                Spacer()
                            }
                            .padding()
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(self.editBits ? EditMode.active : EditMode.inactive))
                }
            }
        }
        .navigationBarTitle("\(self.bob.name ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !self.editBits {
                    Menu {
                        Button(action: {
                            self.editBob.toggle()
                        }) {
                            Text("Edit Collection")
                        }
                        Button(action: {
                            self.editBits.toggle()
                        }) {
                            Text("Edit Item List")
                        }
                    } label: {
                        Text("Edit")
                            .foregroundColor(PersistenceController.themeColor)
                            .minimumScaleFactor(0.5)
                    }
                }
                else {
                    Text("Done")
                        .foregroundColor(PersistenceController.themeColor)
                        .onTapGesture {
                            self.editBits.toggle()
                        }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.newBit.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .onAppear {
            self.display = ListType.init(rawValue: Int(bob.displayType)) ?? .smallList
            self.group = Int(bob.group)
            self.sort = Int(bob.sort)
            self.tags = bob.tags ?? []
            self.sortReversed = bob.sortReversed
            setGroupAndSort()
            update.toggle()
        }
        .onChange(of: self.newBit) { value in
            if !value {
                setGroupAndSort()
            }
        }
        .onChange(of: self.editBob) { value in
            if !value {
                setGroupAndSort()
            }
        }
        .sheet(isPresented: self.$newBit, content: {
            BitEditor(bob: bob)
        })
        .sheet(isPresented: self.$editBob, content: {
            BobEditor(bob: bob)
        })
        .alert(isPresented: self.$moveBitWarning) {
            Alert(title: Text("Cannot Move Item"),
                  message: Text("You can only move items \(self.bob.listType == 2 ? "in a ranked list " : "")when grouping by None, sorting by \(self.bob.listType == 2 ? "Ranking" : "Default"), and pointing the arrow down.")
            )
        }
    }
    
    // Set group and sort
    func setGroupAndSort() {
        self.groupableAttributes = getGroupable()
        self.sortableAttributes = getSortable()
        self.groups = groupBits()
        self.bitLists = [:]
        for group in groups {
            self.bitLists[group] = sortBits(group: group)
        }
        if self.group-1 >= self.groupableAttributes.count {
            self.group = 0
            setGroupAndSort()
        }
        if self.sort-2 >= self.sortableAttributes.count {
            self.sort = 0
            setGroupAndSort()
        }
    }
    
    // MARK: Group
    
    // Get groupable attributes
    func getGroupable() -> [Attribute] {
        var groupable: [Attribute] = []
        for attribute in self.bob.attributeList {
            if (attribute.type == 0 && attribute.groupable) || (attribute.type == 1 && attribute.groupable && !attribute.decimal) || attribute.type == 2 {
                groupable += [attribute]
            }
        }
        return groupable
    }
    // Get specific group name
    func getGroup(_ num: Int, display: Bool = false) -> String {
        if num >= 1 && num-1 < groupableAttributes.count {
            return display ? groupableAttributes[num-1].displayName ?? "" : groupableAttributes[num-1].name ?? ""
        }
        return "None"
    }
    // Get specific group attribute
    func getGroupAttribute(_ num: Int) -> Attribute? {
        if num >= 1 && num-1 < groupableAttributes.count {
            return groupableAttributes[num-1]
        }
        return nil
    }
    // Group the bits
    func groupBits() -> [String] {
        let filteredBits = self.bits.filter { $0.bob == self.bob }
        // Return a single item if no groups specified
        if self.group == 0 {
            return [""]
        }
        // Group by attribute
        else {
            // Get the attribute that groups are grouped by
            let attribute = getGroupAttribute(group)
            guard attribute != nil else { return [""] }
            // Group by text
            if attribute!.type == 0 {
                var presets = attribute!.presets ?? []
                // Add all bits' values to presets
                var unassigned = false
                for bit in filteredBits {
                    autoreleasepool {
                        for value in bit.allAttributeValues(attribute!.name) {
                            if !presets.contains(value) && value != "" {
                                presets += [value]
                            }
                            else if value == "" {
                                unassigned = true
                            }
                        }
                    }
                }
                // Remove empty presets
                presets = presets.filter { !$0.isEmpty }
                // Group by preset order
                if attribute!.sortTextType == 0 {
                    if attribute!.unassignedGroup && unassigned {
                        presets += ["Unassigned"]
                    }
                    return presets
                }
                // Group by name
                else if attribute!.sortTextType == 1 {
                    presets = presets.sorted(by: { $0 < $1 })
                    if attribute!.unassignedGroup && unassigned {
                        presets += ["Unassigned"]
                    }
                    return presets
                }
            }
            // Group by number
            else if attribute!.type == 1 {
                var values: [String] = []
                var unassigned = false
                for bit in filteredBits {
                    autoreleasepool {
                        for value in bit.allAttributeValues(attribute!.name) {
                            if !values.contains(value) && value != "" {
                                values += [value]
                            }
                            else if value == "" {
                                unassigned = true
                            }
                        }
                    }
                }
                if unassigned {
                    values += ["Unassigned"]
                }
                return values.sorted { Double($0) ?? .infinity < Double($1) ?? .infinity }
            }
            // Group by boolean
            else if attribute!.type == 2 {
                return ["True","False"]
            }
            return [""]
        }
    }
    
    // MARK: Sort
    
    // Get sortable attributes
    func getSortable() -> [Attribute] {
        var sortable: [Attribute] = []
        for attribute in self.bob.attributeList {
            if (attribute.type == 0 && attribute.sortable) || attribute.type == 1, !attribute.allowMultiple {
                sortable += [attribute]
            }
        }
        return sortable
    }
    // Get specific sorting name
    func getSort(_ num: Int, display: Bool = false) -> String {
        if num >= 2 && num-2 < sortableAttributes.count {
            return display ? sortableAttributes[num-2].displayName ?? "" : sortableAttributes[num-2].name ?? ""
        }
        else if num == 1 {
            return "Name"
        }
        return bob.listType == 2 ? "No Sort" : "No Sort"
    }
    // Get specific sorting attribute
    func getSortAttribute(_ num: Int) -> Attribute? {
        if num >= 2 && num-2 < sortableAttributes.count {
            return sortableAttributes[num-2]
        }
        return nil
    }
    // Sort the bits
    func sortBits(group: String) -> [Bit] {
        var filteredBits = self.bits.filter { $0.bob == self.bob }
        if !search.isEmpty {
            filteredBits = filteredBits.filter { $0.name?.uppercased().contains(self.search.uppercased()) ?? false }
        }
        if !tags.isEmpty {
            filteredBits = filteredBits.filter { $0.tags?.contains(where: { self.tags.contains($0) }) ?? false }
        }
        // Only include bits of a specific group if indicated
        var bitArray: [Bit] = filteredBits
        if group != "" || self.group != 0 {
            bitArray = []
            let attribute = getGroup(self.group)
            for bit in filteredBits {
                autoreleasepool {
                    if bit.allAttributeValues(attribute).contains(group) || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "Unassigned") || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "False" && getGroupAttribute(self.group)?.type == 2) {
                        bitArray += [bit]
                    }
                }
            }
        }
        // If group out of range, return
        if self.group-1 >= self.groupableAttributes.count {
            return self.sortReversed ? bitArray.reversed() : bitArray
        }
        // Sort by attribute
        if self.sort >= 2 {
            let attribute = getSortAttribute(sort)
            guard attribute != nil else { return self.sortReversed ? bitArray.reversed() : bitArray }
            // Sort by text
            if attribute!.type == 0 {
                var presets = attribute!.presets ?? []
                // Add all bits' values to presets
                for bit in bitArray {
                    autoreleasepool {
                        let value = bit.attributes?[attribute!.name ?? ""] ?? ""
                        if !presets.contains(value) && value != "" {
                            presets += [value]
                        }
                    }
                }
                // Sort by preset order
                if attribute!.sortTextType == 0 {
                    var sortedArray: [Bit] = []
                    for preset in presets {
                        sortedArray += bitArray.filter { $0.attributes![attribute!.name ?? ""] == preset }
                    }
                    let sorted = sortedArray + bitArray.filter { $0.attributes![attribute!.name ?? ""] == nil || $0.attributes![attribute!.name ?? ""] == "" }
                    return self.sortReversed ? sorted.reversed() : sorted
                }
                // Sort by name
                else if attribute!.sortTextType == 1 {
                    if self.sortReversed {
                        return bitArray.sorted { $0.attributes![attribute!.name ?? ""] ?? " " > $1.attributes![attribute!.name ?? ""] ?? " " }
                    }
                    else {
                        return bitArray.sorted { $0.attributes![attribute!.name ?? ""] ?? "ü" < $1.attributes![attribute!.name ?? ""] ?? "ü" }
                    }
                }
            }
            // Sort by number
            else if attribute!.type == 1 {
                if self.sortReversed {
                    return bitArray.sorted { Double($0.attributes![attribute!.name ?? ""] ?? "-inf") ?? -Double.infinity > Double($1.attributes![attribute!.name ?? ""] ?? "-inf") ?? -Double.infinity }
                }
                else {
                    return bitArray.sorted { Double($0.attributes![attribute!.name ?? ""] ?? "inf") ?? Double.infinity < Double($1.attributes![attribute!.name ?? ""] ?? "inf") ?? Double.infinity }
                }
            }
        }
        // Sort by name
        else if self.sort == 1 {
            let sorted = bitArray.sorted { $0.name ?? "" < $1.name ?? "" }
            return self.sortReversed ? sorted.reversed() : sorted
        }
        return self.sortReversed ? bitArray.reversed() : bitArray
    }
    
    // MARK: Formatting
    
    func editGroupName(_ name: String) -> String {
        
        let currentGroup = getGroupAttribute(self.group)
        
        if currentGroup?.type == 1 && Double(name) != nil {
            return editAttributeNumber(name, attribute: currentGroup)
        }
        else if currentGroup?.type == 2 && currentGroup?.boolType == 1 {
            switch name {
            case "True":
                return "Yes"
            case "False":
                return "No"
            default:
                return name
            }
        }
        
        return name
    }
    
    func editAttributeNumber(_ value: String, attribute: Attribute?) -> String {
        guard attribute != nil else { return value }
        if attribute!.prefix != nil && attribute!.suffix != nil && attribute!.prefix != "" && attribute!.suffix != "" {
            return attribute!.prefix! + " " + value + " " + attribute!.suffix!
        }
        else if attribute!.prefix != nil && attribute!.prefix != "" {
            return attribute!.prefix! + " " + value
        }
        else if attribute!.suffix != nil && attribute!.suffix != "" {
            return value + " " + attribute!.suffix!
        }
        return value
    }
    
    // MARK: Edit Bits

    func moveBits(from source: IndexSet, to destination: Int) {
        guard self.sort == 0, self.group == 0, !self.sortReversed else {
            self.moveBitWarning.toggle()
            return
        }
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        bob.bits = NSSet(array: revisedItems)
        PersistenceController.shared.save()
        setGroupAndSort()
    }
    
    func removeBit(bit: Bit) {
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        revisedItems.remove(at: Int(bit.order))
        bob.bits = NSSet(array: revisedItems)
        managedObjectContext.delete(bit)
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }

    func removeBits(offsets: IndexSet, group: String) {
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        for index in offsets {
            // Create a temporary array based on how the list is displayed
            var sortedBitArray: [Bit] = []
            for currentGroup in groupBits() {
                sortedBitArray += sortBits(group: currentGroup)
            }
            // Find the first index of the group if there is a group
            var firstIndexOfGroup = 0
            if group != "" && group != "Unassigned" {
                for currentBit in sortedBitArray {
                    if currentBit.attributes![getGroup(self.group)] == group {
                        break
                    }
                    firstIndexOfGroup += 1
                }
            }
            else if group == "Unassigned" {
                for currentBit in sortedBitArray {
                    if currentBit.attributes![getGroup(self.group)] == nil || currentBit.attributes![getGroup(self.group)] == "" {
                        break
                    }
                    firstIndexOfGroup += 1
                }
            }
            // Find the bit with the index relative to the starting group
            let bit = sortedBitArray[index+firstIndexOfGroup]
            // Remove the bit
            revisedItems.remove(at: Int(bit.order))
            bob.bits = NSSet(array: revisedItems)
            managedObjectContext.delete(bit)
        }
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }
    
    func reorderBits(_ array: [Bit]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        bob.bits = NSSet(array: revisedItems)
        bob.nextBitID = Int16(revisedItems.count)
        PersistenceController.shared.save()
        setGroupAndSort()
    }
    
    // MARK: Save
    
    func saveBob() {
        
        managedObjectContext.performAndWait {
            bob.displayType = Int16(self.display.rawValue)
            bob.group = Int16(self.group)
            bob.sort = Int16(self.sort)
            bob.tags = self.tags
            bob.sortReversed = self.sortReversed
        }
        
        PersistenceController.shared.save()
    }
    
    // MARK: Display
    
    private func bitCountText(bits: [Bit]) -> String {
        bob.listType == 1 ? "\(bits.filter({ $0.checked }).count) of \(bits.count)" : "\(bits.count)"
    }
    
    private func circle(icon: String, active: Bool) -> some View {
        Circle()
            .fill(active ? PersistenceController.themeColor : Color(uiColor: .systemGray6))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: icon)
                    .fontWeight(.bold)
                    .foregroundColor(active ? .white : PersistenceController.themeColor)
            }
    }
}


enum ListType: Int {
    case smallList = 0
    case largeList = 1
    case smallGrid = 3
    case largeGrid = 4
}
