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
    
    @State private var group = 0
    @State private var sort = 0
    @State private var sortReversed = false
    @State private var search = ""
    
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
                                .font(.system(.largeTitle, design: .rounded).weight(.black))
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                .tracking(-0.5)
                                .lineLimit(0)
                                .minimumScaleFactor(0.2)
                                .foregroundColor(bob.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)

                            if bob.desc != nil && bob.desc != "" {
                                Text(bob.desc ?? "")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
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
                
                        HStack {
                            HStack {
                                Image(systemName: "folder\(group != 0 ? ".fill" : "")")
                                    .fontWeight(.medium)
                                    .foregroundColor(PersistenceController.themeColor)
                                    .onTapGesture {
                                        if group != 0 { group = 0 }
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
                                    Text(getGroup(group, display: true))
                                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                        .font(geometry.size.width > 800 ? .headline : .callout)
                                        .lineLimit(0)
                                        .minimumScaleFactor(0.5)
                                }
                                Spacer(minLength: 0)
                            }
                            .onChange(of: self.group) { _ in
                                setGroupAndSort()
                                saveBob()
                            }
                            
                            HStack {
                                Spacer(minLength: 0)
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
                                    HStack {
                                        Text(getSort(sort, display: true))
                                            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                            .font(geometry.size.width > 800 ? .headline : .callout)
                                            .lineLimit(0)
                                            .minimumScaleFactor(0.5)
                                    }
                                }
                                .onChange(of: self.sort) { _ in
                                    setGroupAndSort()
                                    saveBob()
                                }
                                Button(action: {
                                    self.sortReversed.toggle()
                                    setGroupAndSort()
                                    saveBob()
                                }) {
                                    Image(systemName: self.sortReversed ? "arrow.up" : "arrow.down")
                                        .fontWeight(.medium)
                                        .foregroundColor(PersistenceController.themeColor)
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 5)
                        .listRowSeparator(.hidden)
                        
                        HStack(spacing: 0) {
                            Image(systemName: "magnifyingglass")
                                .imageScale(geometry.size.width > 800 ? .medium : .small)
                                .foregroundColor(Color(UIColor.systemGray))
                                .padding(2)
                            TextField("Search", text: self.$search)
                                .fontWeight(.regular)
                                .padding(.horizontal, 7)
                                .onChange(of: self.search) { _ in
                                    setGroupAndSort()
                                }
                            Spacer()
                            if !self.search.isEmpty {
                                Button {
                                    self.search = ""
                                    setGroupAndSort()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.small)
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .padding(2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 5)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .listRowBackground(Color(UIColor.systemGray6).cornerRadius(10).padding(.vertical, 2).padding(.horizontal, 10))
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
                            Section(header:
                                name != "" ? Text(name) : nil
                            ) {
                                ForEach(self.bitLists[group]!, id: \.order) { bit in

                                    NavigationLink(destination: BitView(bit: bit, bob: bob)) {

                                        HStack {

                                            if bob.listType == 2 {
                                                VStack {
                                                    Text(String(bit.order+1))
                                                        .font(.headline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color(UIColor.systemGray))
                                                }
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .padding(.leading, -6)
                                                .padding(.trailing, 2)
                                            }

                                            if bob.displayBitImgList != 2 {
                                                Icon(image: UIImage(data: bit.image ?? Data()) ?? UIImage(),
                                                     size: bob.displayBitImgList == 0 ? 30 : 50,
                                                     faded: bob.listType == 1 && !bit.checked)
                                                    .padding(.vertical, bob.displayBitImgList == 0 ? 3 : 0)
                                                    .padding(.leading, -4)
                                                    .padding(.trailing, 2)
                                            }

                                            VStack(alignment: .leading) {

                                                Text(bit.name ?? "")
                                                    .font(.system(.title3, design: .rounded).weight(.semibold))
                                                    .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                                                    .tracking(-0.5)
                                                    .font(.title2)
                                                    .lineLimit(0)

                                                if self.sort >= 2 && bit.attributes != nil && bob.displayBitDescList {
                                                    if getSortAttribute(sort)?.type == 1 && bit.attributes![getSort(sort)] != nil && bit.attributes![getSort(sort)] != "" {
                                                        Text(editAttributeNumber(bit.attributes![getSort(sort)]!, attribute: getSortAttribute(sort)))
                                                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                            .tracking(-0.25)
                                                            .font(.subheadline)
                                                            .lineLimit(0)
                                                    }
                                                    else if bit.attributes![getSort(sort)] != nil && bit.attributes![getSort(sort)] != "" {
                                                        Text(bit.attributes![getSort(sort)]!)
                                                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                            .tracking(-0.25)
                                                            .font(.subheadline)
                                                            .lineLimit(0)
                                                    }
                                                }
                                                else if bit.desc != nil && bit.desc != "" && bob.displayBitDescList {
                                                    Text(bit.desc!)
                                                        .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                                                        .tracking(-0.25)
                                                        .font(.subheadline)
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
                                }
                                .onMove(perform: moveBits)
                                .onDelete(perform: { offsets in
                                    removeBits(offsets: offsets, group: group)
                                })
                            }
                            .padding(.horizontal, 5)
                            .listRowBackground(Color(UIColor.systemGray6).cornerRadius(10).padding(.vertical, 2).padding(.horizontal, 10))
                        }
                        .listRowSeparator(.hidden)
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
            self.group = Int(bob.group)
            self.sort = Int(bob.sort)
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
                        let value = bit.attributes?[attribute!.name ?? ""] ?? ""
                        if !presets.contains(value) && value != "" {
                            presets += [value]
                        }
                        else if bit.attributes?[attribute!.name ?? ""] == nil || bit.attributes?[attribute!.name ?? ""] == "" {
                            unassigned = true
                        }
                    }
                }
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
                        let value = bit.attributes?[attribute!.name ?? ""] ?? ""
                        if !values.contains(value) && value != "" {
                            values += [value]
                        }
                        else if value == "" {
                            unassigned = true
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
            if (attribute.type == 0 && attribute.sortable) || attribute.type == 1 {
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
        return bob.listType == 2 ? "Ranking" : "Default"
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
        // Only include bits of a specific group if indicated
        var bitArray: [Bit] = filteredBits
        if group != "" || self.group != 0 {
            bitArray = []
            let attribute = getGroup(self.group)
            for bit in filteredBits {
                autoreleasepool {
                    if bit.attributes![attribute] == group || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "Unassigned") || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "False" && getGroupAttribute(self.group)?.type == 2) {
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
            bob.group = Int16(self.group)
            bob.sort = Int16(self.sort)
            bob.sortReversed = self.sortReversed
        }
        
        PersistenceController.shared.save()
    }
}
