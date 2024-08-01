//
//  Attribute+CoreDataProperties.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/1/21.
//
//

import Foundation
import CoreData


extension Attribute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attribute> {
        return NSFetchRequest<Attribute>(entityName: "Attribute")
    }

    @NSManaged public var order: Int16
    @NSManaged public var name: String?
    @NSManaged public var displayName: String?
    @NSManaged public var type: Int16
    @NSManaged public var allowMultiple: Bool
    @NSManaged public var maxCount: Int16
    @NSManaged public var bob: Bob?
    
    // Organization
    @NSManaged public var sortable: Bool
    @NSManaged public var groupable: Bool
    @NSManaged public var taggable: Bool
    
    // Text
    @NSManaged public var presets: [String]?
    
    // Numbers
    @NSManaged public var decimal: Bool
    @NSManaged public var prefix: String?
    @NSManaged public var suffix: String?
    
    // Booleans
    @NSManaged public var boolType: Int16
    @NSManaged public var boolDisplayFalse: Bool

}

extension Attribute : Identifiable {

}
