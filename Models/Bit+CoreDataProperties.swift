//
//  Bit+CoreDataProperties.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/1/21.
//
//

import Foundation
import CoreData


extension Bit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bit> {
        return NSFetchRequest<Bit>(entityName: "Bit")
    }
    
    @NSManaged public var order: Int16
    
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var image: Data?
    @NSManaged public var icon: Data?
    @NSManaged public var paragraph: String?
    @NSManaged public var attributes: [String:String]?
    @NSManaged public var checked: Bool
    
    @NSManaged public var bob: Bob?
    
    func allAttributeValues(_ name: String?) -> [String] {
        return (attributes?[name ?? ""] ?? "")?.components(separatedBy: CharacterSet(charactersIn: String(Constants.delimiter))) ?? []
    }
}

extension Bit : Identifiable {

}
