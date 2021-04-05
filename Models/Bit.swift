//
//  Bit.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import Foundation

class Bit: Identifiable {
    
    var id: Int
    var name: String
    var desc: String?
    var paragraph: String?
    var icon: String?
    var attributes: [String]
    
    init(id: Int, name: String, desc: String? = nil, paragraph: String? = nil, icon: String? = nil, attributes: [String] = []) {
        self.id = id
        self.name = name
        self.desc = desc
        self.paragraph = paragraph
        self.icon = icon
        self.attributes = attributes
    }
}
