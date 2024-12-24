//
//  Bob+CoreDataProperties.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/1/21.
//
//

import Foundation
import CoreData


extension Bob {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bob> {
        return NSFetchRequest<Bob>(entityName: "Bob")
    }
    
    @NSManaged public var order: Int16
    
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    
    @NSManaged public var image: Data?
    @NSManaged public var imageOffsetX: Double
    @NSManaged public var imageOffsetY: Double
    @NSManaged public var imageScale: Double
    
    @NSManaged public var listType: Int16
    @NSManaged public var displayType: Int16
    
    @NSManaged public var nextBitID: Int16
    @NSManaged public var nextAttrID: Int16
    
    @NSManaged public var group: Int16
    @NSManaged public var sort: Int16
    @NSManaged public var sortReversed: Bool
    
    @NSManaged public var bits: NSSet?
    @NSManaged public var attributes: NSSet?
    
    public var bitArray: [Bit] {
        let set = bits as? Set<Bit> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }
    
    public var attributeList: [Attribute] {
        let set = attributes as? Set<Attribute> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }
    
    public var tagList: [String] {
        var tags: [String] = []
        for bit in bitArray {
            bit.tags?.forEach { !tags.contains($0) ? tags.append($0) : nil }
        }
        return Array(tags)
    }
}

// MARK: Generated accessors for bits
extension Bob {

    @objc(addBitsObject:)
    @NSManaged public func addToBits(_ value: Bit)

    @objc(removeBitsObject:)
    @NSManaged public func removeFromBits(_ value: Bit)

    @objc(addBits:)
    @NSManaged public func addToBits(_ values: NSSet)

    @objc(removeBits:)
    @NSManaged public func removeFromBits(_ values: NSSet)

}

// MARK: Generated accessors for attributes
extension Bob {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: Attribute)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: Attribute)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

extension Bob : Identifiable {

}
