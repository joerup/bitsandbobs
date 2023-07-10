//
//  BitList.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/9/23.
//

import SwiftUI
import WrappingHStack

struct BitList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var bob: Bob
    
    var groups: [String]
    var bitLists: [String: [Bit]]
    
    var display: ListType
    var group: Int
    var sort: Int
    var sortReversed: Bool
    
    var groupName: String
    var groupAttribute: Attribute?
    
    var sortName: String
    var sortAttribute: Attribute?
    
    var setGroupAndSort: () -> Void
    
    @Binding var editBits: Bool
    
    @Binding var update: Bool
    
    @State private var moveBitWarning = false
    
    @Namespace private var namespace
    @Namespace private var iconNamespace
    @Namespace private var textNamespace
    @Namespace private var detailNamespace
    
    private var smallIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 36 : 32
    }
    private var mediumIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 60 : 50
    }
    private var largeIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 100 : 80
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            if self.bob.bitArray.isEmpty {
                HStack {
                    Spacer()
                    Text("This collection is empty.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding()
                    Spacer()
                }
            } else {
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(self.groups, id: \.self) { group in
                            
                            let name = editGroupName(group)
                            let bits = self.bitLists[group] ?? []
                            
                            Section(header: name.isEmpty ? nil :
                                HStack(alignment: .bottom) {
                                    Text(name)
                                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                    Spacer()
                                    Text(bitCountText(bits: bits))
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                                }
                                .transition(.opacity)
                                .padding(.horizontal, 15)
                                .padding(.bottom, 5)
                                .padding(.top, 15)
                            ) {
                                if [.smallList, .largeList].contains(display) {
                                    list(name: name, bits: bits, size: geometry.size)
                                }
                                else if [.smallGrid, .largeGrid].contains(display) {
                                    grid(name: name, bits: bits, size: geometry.size)
                                }
                                
                            }
                        }
                    }
                    .animation(.default, value: display)
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Spacer()
                        Text("\(displayedBitCountText(bits: bob.bitArray))")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(Color(UIColor.systemGray2))
                        Spacer()
                    }
                    .padding()
                    .animation(.default, value: display)
                }
            }
        }
        .alert(isPresented: self.$moveBitWarning) {
            Alert(title: Text("Cannot Move Item"),
                  message: Text("You can only move items \(self.bob.listType == 2 ? "in a ranked list " : "")when grouping by None, sorting by \(self.bob.listType == 2 ? "Ranking" : "Default"), and pointing the arrow down.")
            )
        }
    }
    
    private func list(name: String, bits: [Bit], size: CGSize) -> some View {
        VStack(spacing: 3) {
            ForEach(bits, id: \.order) { bit in
                let id = bitID(bit, name)
                NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                    bitRow(bit: bit, id: id)
                }
                .padding(5)
                .padding(.horizontal, 5)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .matchedGeometryEffect(id: id, in: namespace)
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
        }
    }
    
    private func grid(name: String, bits: [Bit], size: CGSize) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: Int((size.width-50) / (display == .smallGrid ? (mediumIconSize+4) : (largeIconSize+4))))) {
            ForEach(bits, id: \.order) { bit in
                let id = bitID(bit, name)
                NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                    bitGridItem(bit: bit, id: id)
                }
                .matchedGeometryEffect(id: id, in: namespace)
            }
        }
        .padding(10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
    
    private func bitRow(bit: Bit, id: String) -> some View {
        HStack {

            if bob.listType == 2 {
                VStack {
                    Text(String(bit.order+1))
                        .font(.system(bit.order < 9 ? .title3 : .headline, design: .rounded).weight(.semibold))
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.systemGray))
                        .minimumScaleFactor(0.5)
                }
                .frame(width: smallIconSize*0.7, height: smallIconSize, alignment: .center)
                .matchedGeometryEffect(id: id, in: detailNamespace)
            }

            icon(bit: bit, size: display == .smallList ? smallIconSize : mediumIconSize)
                .matchedGeometryEffect(id: id, in: iconNamespace)
                .padding(.trailing, 2)

            VStack(alignment: .leading) {

                Text(bit.name ?? "")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                    .tracking(-0.5)
                    .lineLimit(0)
                    .matchedGeometryEffect(id: id, in: textNamespace)

                if self.sort >= 2 && bit.attributes != nil && display == .largeList {
                    if sortAttribute?.type == 1 && bit.attributes![sortName] != nil && bit.attributes![sortName] != "" {
                        Text(editAttributeNumber(bit.attributes![sortName]!, attribute: sortAttribute))
                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                            .tracking(-0.25)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .lineLimit(0)
                    }
                    else if bit.attributes![sortName] != nil && bit.attributes![sortName] != "" {
                        Text(bit.attributes![sortName]!)
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
                    .matchedGeometryEffect(id: id, in: detailNamespace)
            }
            
            Image(systemName: "chevron.forward")
                .foregroundColor(Color(uiColor: .quaternaryLabel))
                .imageScale(.small)
        }
        .id(update)
    }
    
    private func bitGridItem(bit: Bit, id: String) -> some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                icon(bit: bit, size: display == .smallGrid ? mediumIconSize : largeIconSize)
                    .matchedGeometryEffect(id: id, in: iconNamespace)
                
                if bob.listType == 1 {
                    Check(bob: bob, bit: bit, update: $update, scaleFactor: display == .smallGrid ? mediumIconSize/largeIconSize : 1)
                        .matchedGeometryEffect(id: id, in: detailNamespace)
                }
                if bob.listType == 2 {
                    VStack {
                        Text(String(bit.order+1))
                            .font(.system(bit.order < 9 ? .title : .title2, design: .rounded).weight(.black))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                            .shadow(color: .secondary, radius: 5)
                    }
                    .frame(width: smallIconSize, height: smallIconSize, alignment: .center)
                    .matchedGeometryEffect(id: id, in: detailNamespace)
                }
            }
            
            if display == .largeGrid {
                Text(bit.name ?? "")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                    .tracking(-0.5)
                    .lineLimit(0)
                    .frame(maxWidth: largeIconSize)
                    .matchedGeometryEffect(id: id, in: textNamespace)
            }
            
            Text(id)
        }
        .padding(2)
        .id(update)
    }
    
    private func icon(bit: Bit, size: CGFloat) -> some View {
        Group {
            if let icon = bit.icon, let image = UIImage(data: icon) {
                Icon(
                    image: image,
                    size: size,
                    faded: bob.listType == 1 && !bit.checked
                )
            } else {
                Icon(
                    image: nil,
                    size: size,
                    faded: bob.listType == 1 && !bit.checked
                )
            }
        }
    }
    
    private func bitID(_ bit: Bit, _ group: String = "") -> String {
        return "\(bit.order)\(group)"
    }
    
    
    // MARK: Edit Bits

    private func moveBits(from source: IndexSet, to destination: Int) {
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
    
    private func removeBit(bit: Bit) {
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        revisedItems.remove(at: Int(bit.order))
        bob.bits = NSSet(array: revisedItems)
        managedObjectContext.delete(bit)
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }

    private func removeBits(offsets: IndexSet, group: String) {
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        for index in offsets {
            // Create a temporary array based on how the list is displayed
            var sortedBitArray: [Bit] = []
            for currentGroup in groups {
                sortedBitArray += bitLists[currentGroup] ?? []
            }
            // Find the first index of the group if there is a group
            var firstIndexOfGroup = 0
            if group != "" && group != "Unassigned" {
                for currentBit in sortedBitArray {
                    if currentBit.attributes![groupName] == group {
                        break
                    }
                    firstIndexOfGroup += 1
                }
            }
            else if group == "Unassigned" {
                for currentBit in sortedBitArray {
                    if currentBit.attributes![groupName] == nil || currentBit.attributes![groupName] == "" {
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
    
    private func reorderBits(_ array: [Bit]) {
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
    
    private func bitCountText(bits: [Bit]) -> String {
        return bob.listType == 1 ? "\(bits.filter({ $0.checked }).count) of \(bits.count)" : "\(bits.count)"
    }
    private func displayedBitCountText(bits: [Bit]) -> String {
        let displayedBits = Array(Set(groups.map({ bitLists[$0] ?? [] }).joined()))
        return bitCountText(bits: displayedBits) + " item\(displayedBits.count == 1 ? "" : "s")"
    }
    
    private func editGroupName(_ name: String) -> String {
        if groupAttribute?.type == 1 && Double(name) != nil {
            return editAttributeNumber(name, attribute: groupAttribute)
        }
        else if groupAttribute?.type == 2 && groupAttribute?.boolType == 1 {
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
    
    private func editAttributeNumber(_ value: String, attribute: Attribute?) -> String {
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
}

enum ListType: Int, CaseIterable {
    
    case smallList = 0
    case largeList = 1
    case smallGrid = 3
    case largeGrid = 4
    
    var name: String {
        switch self {
        case .smallList:
            return "Small List"
        case .largeList:
            return "Large List"
        case .smallGrid:
            return "Small Grid"
        case .largeGrid:
            return "Large Grid"
        }
    }
    var icon: String {
        switch self {
        case .smallList:
            return "list.bullet"
        case .largeList:
            return "checklist.unchecked"
        case .smallGrid:
            return "circle.grid.3x3"
        case .largeGrid:
            return "circle.grid.2x2"
        }
    }
}
