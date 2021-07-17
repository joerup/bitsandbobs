//
//  ContentView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import Foundation
import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        ListView()
//        TestAllObjectsView()
    }
}

struct TestAllObjectsView: View {
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @FetchRequest(
        entity: Bit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bit.order, ascending: true)
        ]
    ) var bits: FetchedResults<Bit>
    
    var body: some View {
        List(bits.sorted(by: { $0.name ?? "" < $1.name ?? "" })) { bit in
            VStack(alignment: .leading) {
                Text(bit.name ?? "")
                Text("\(bit.bob?.name ?? "") #\(String(bit.order))")
            }
        }
    }
}
