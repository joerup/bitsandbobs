//
//  Bob.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import Foundation

class Bob: Identifiable {
    
    var id: Int
    var name: String
    var desc: String?
    var icon: String?
    var bits: [Bit]
    var attributes: [String]
    
    init(id: Int, name: String, desc: String? = nil, icon: String? = nil, bits: [Bit] = [], attributes: [String] = []) {
        self.id = id
        self.name = name
        self.desc = desc
        self.icon = icon
        self.bits = bits
        self.attributes = attributes
    }
}
