//
//  Samples.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/14/24.
//

import Foundation
import UIKit
import CoreData

class Samples {
                    
    static func getSamples() {
        
        let managedObjectContext = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Bob.fetchRequest()
        do {
            let bobs = try managedObjectContext.fetch(fetchRequest) as! [Bob]
            for bob in bobs {
                for bit in bob.bitArray {
                    managedObjectContext.delete(bit)
                }
                managedObjectContext.delete(bob)
            }
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not fetch or delete objects. \(error), \(error.userInfo)")
        }
        
        // Bobs
        var bobs = [Bob]()
        for _ in 0...5 {
            let bob = Bob(context: managedObjectContext)
            bob.order = PersistenceController.nextBobID
            bobs += [bob]
        }
        
        
        
        // MARK: - Quarters
        
        bobs[0].name = "Quarters"
        bobs[0].desc = "U.S. States and Territories"
        bobs[0].image = UIImage(imageLiteralResourceName: "coins").pngData()
        bobs[0].listType = 1
        bobs[0].displayType = 4

        var attrs0 = [Attribute]()
        for i in 0...2 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs0 += [attr]
        }
        
        attrs0[0].name = "Abbreviation"
        attrs0[0].displayName = "Abbreviation"
        attrs0[0].type = 0

        attrs0[1].name = "Year"
        attrs0[1].displayName = "State Founded"
        attrs0[1].type = 1
        
        attrs0[2].name = "Quarter Year"
        attrs0[2].displayName = "Quarter Introduced"
        attrs0[2].type = 1
        
        var bits0 = [Bit]()
        
        let states = ["DE", "PA", "NJ", "GA", "CT", "MA", "MD", "SC", "NH", "VA", "NY", "NC", "RI", "VT", "KY", "TN", "OH", "LA", "IN", "MS", "IL", "AL", "ME", "MO", "AR", "MI", "FL", "TX", "IA", "WI", "CA", "MN", "OR", "KS", "WV", "NV", "NE", "CO", "ND", "SD", "MT", "WA", "ID", "WY", "UT", "OK", "NM", "AZ", "AK", "HI", "DC", "PR", "GU", "AS", "VI", "MP"]
        let state_names = ["DE": "Delaware", "PA": "Pennsylvania", "NJ": "New Jersey", "GA": "Georgia", "CT": "Connecticut", "MA": "Massachusetts", "MD": "Maryland", "SC": "South Carolina", "NH": "New Hampshire", "VA": "Virginia", "NY": "New York", "NC": "North Carolina", "RI": "Rhode Island", "VT": "Vermont", "KY": "Kentucky", "TN": "Tennessee", "OH": "Ohio", "LA": "Louisiana", "IN": "Indiana", "MS": "Mississippi", "IL": "Illinois", "AL": "Alabama", "ME": "Maine", "MO": "Missouri", "AR": "Arkansas", "MI": "Michigan", "FL": "Florida", "TX": "Texas", "IA": "Iowa", "WI": "Wisconsin", "CA": "California", "MN": "Minnesota", "OR": "Oregon", "KS": "Kansas", "WV": "West Virginia", "NV": "Nevada", "NE": "Nebraska", "CO": "Colorado", "ND": "North Dakota", "SD": "South Dakota", "MT": "Montana", "WA": "Washington", "ID": "Idaho", "WY": "Wyoming", "UT": "Utah", "OK": "Oklahoma", "NM": "New Mexico", "AZ": "Arizona", "AK": "Alaska", "HI": "Hawaii", "DC": "District of Columbia", "PR": "Puerto Rico", "GU": "Guam", "AS": "American Samoa", "VI": "U.S. Virgin Islands", "MP": "Northern Mariana Islands"]
        let state_years = ["DE": 1787, "PA": 1787, "NJ": 1787, "GA": 1788, "CT": 1788, "MA": 1788, "MD": 1788, "SC": 1788, "NH": 1788, "VA": 1788, "NY": 1788, "NC": 1789, "RI": 1790, "VT": 1791, "KY": 1792, "TN": 1796, "OH": 1803, "LA": 1812, "IN": 1816, "MS": 1817, "IL": 1818, "AL": 1819, "ME": 1820, "MO": 1821, "AR": 1836, "MI": 1837, "FL": 1845, "TX": 1845, "IA": 1846, "WI": 1848, "CA": 1850, "MN": 1858, "OR": 1859, "KS": 1861, "WV": 1863, "NV": 1864, "NE": 1867, "CO": 1876, "ND": 1889, "SD": 1889, "MT": 1889, "WA": 1889, "ID": 1890, "WY": 1890, "UT": 1896, "OK": 1907, "NM": 1912, "AZ": 1912, "AK": 1959, "HI": 1959, "DC": 1790, "PR": 1898, "GU": 1898, "AS": 1899, "VI": 1917, "MP": 1947]
        let state_quarters = ["DE": 1999, "PA": 1999, "NJ": 1999, "GA": 1999, "CT": 1999, "MA": 2000, "MD": 2000, "SC": 2000, "NH": 2000, "VA": 2000, "NY": 2001, "NC": 2001, "RI": 2001, "VT": 2001, "KY": 2001, "TN": 2002, "OH": 2002, "LA": 2002, "IN": 2002, "MS": 2002, "IL": 2003, "AL": 2003, "ME": 2003, "MO": 2003, "AR": 2003, "MI": 2004, "FL": 2004, "TX": 2004, "IA": 2004, "WI": 2004, "CA": 2005, "MN": 2005, "OR": 2005, "KS": 2005, "WV": 2005, "NV": 2006, "NE": 2006, "CO": 2006, "ND": 2006, "SD": 2006, "MT": 2007, "WA": 2007, "ID": 2007, "WY": 2007, "UT": 2007, "OK": 2008, "NM": 2008, "AZ": 2008, "AK": 2008, "HI": 2008, "DC": 2009, "PR": 2009, "GU": 2009, "AS": 2009, "VI": 2009, "MP": 2009]
        
        for (i, state) in states.enumerated() {
            let bit = Bit(context: managedObjectContext)
            bit.name = state_names[state] ?? "none"
            bit.image = UIImage(imageLiteralResourceName: state).pngData()
            bit.icon = bit.image?.compressed()
            bit.order = Int16(i)
            bit.attributes = ["Abbreviation" : state, "Year" : String(state_years[state] ?? 0), "Quarter Year" : String(state_quarters[state] ?? 0)]
            bit.checked = Bool.random()
            if state == "NY" {
                bit.paragraph = "The New York quarter commemorated the state's immigrant legacy, prominently featuring the Statue of Liberty."
            }
            bits0 += [bit]
        }
        
        bobs[0].bits = NSSet(array: bits0)
        bobs[0].attributes = NSSet(array: attrs0)
        bobs[0].sort = 3 // sort by Year
        
        
        
        // MARK: - Vinyls
        
        bobs[1].name = "Vinyls"
        bobs[1].image = UIImage(imageLiteralResourceName: "vinyls").pngData()
        bobs[1].listType = 0
        bobs[1].displayType = 1
        
        var attrs1 = [Attribute]()
        for i in 0...2 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs1 += [attr]
        }
        
        attrs1[0].name = "Artist"
        attrs1[0].displayName = "Artist"
        attrs1[0].type = 0
        
        attrs1[1].name = "Genre"
        attrs1[1].displayName = "Genre"
        attrs1[1].type = 0
        attrs1[1].groupable = true
        
        attrs1[2].name = "Year"
        attrs1[2].displayName = "Release Year"
        attrs1[2].type = 1
        
        var bits1 = [Bit]()
        
        let albums = ["parachutes", "sleepwellbeast", "mots", "guts", "1989tv", "eternalsunshine", "abbeyroad", "darkside", "exile"]
        let album_names = ["eternalsunshine" : "Eternal Sunshine", "sleepwellbeast" : "Sleep Well Beast", "1989tv" : "1989 (Taylor's Version)", "parachutes": "Parachutes", "mots" : "Music of the Spheres", "guts" : "GUTS", "abbeyroad": "Abbey Road", "darkside" : "The Dark Side of the Moon", "exile": "Exile on Main St."]
        let album_artists = ["eternalsunshine" : "Ariana Grande", "sleepwellbeast" : "The National", "1989tv" : "Taylor Swift", "parachutes": "Coldplay", "mots" : "Coldplay", "guts" : "Olivia Rodrigo", "abbeyroad": "The Beatles", "darkside": "Pink Floyd", "exile": "The Rolling Stones"]
        let album_years = ["eternalsunshine": 2024, "sleepwellbeast": 2017, "1989tv": 2023, "parachutes": 2000, "mots": 2021, "guts": 2023, "abbeyroad": 1969, "darkside": 1973, "exile": 1972]
        let album_genres = ["eternalsunshine": "Pop", "sleepwellbeast": "Alternative", "1989tv": "Pop", "parachutes": "Alternative", "mots": "Pop", "guts": "Pop", "abbeyroad": "Rock", "darkside": "Rock", "exile": "Rock"]
        
        for (i, album) in albums.enumerated() {
            let bit = Bit(context: managedObjectContext)
            bit.name = album_names[album] ?? "none"
            bit.image = UIImage(imageLiteralResourceName: album).pngData()
            bit.icon = bit.image?.compressed()
            bit.order = Int16(i)
            bit.attributes = ["Artist" : album_artists[album] ?? "none", "Genre": album_genres[album] ?? "none", "Year" : String(album_years[album] ?? 0)]
            bits1 += [bit]
        }
        
        bobs[1].bits = NSSet(array: bits1)
        bobs[1].attributes = NSSet(array: attrs1)
        bobs[1].group = 1 // group by Genre
        
        
        // MARK: - Animals
        
        bobs[2].name = "Animals"
        bobs[2].desc = "Toy Animals"
        bobs[2].image = UIImage(imageLiteralResourceName: "animals").pngData()
        bobs[2].listType = 0
        bobs[2].displayType = 3
        
        var bits2 = [Bit]()
        
        for i in 1...36 {
            let bit = Bit(context: managedObjectContext)
            bit.name = "Animal \(i)"
            bit.image = UIImage(imageLiteralResourceName: "animal\(i)").pngData()
            bit.icon = bit.image?.compressed()
            bit.order = Int16(i-1)
            bits2 += [bit]
        }
        
        bobs[2].bits = NSSet(array: bits2)
        
        
        // MARK: - Books
        
        bobs[3].name = "Books"
        bobs[3].desc = "My favorites"
        bobs[3].image = UIImage(imageLiteralResourceName: "books").pngData()
        bobs[3].listType = 2
        bobs[3].displayType = 0
        
        var attrs3 = [Attribute]()
        for i in 0...0 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs3 += [attr]
        }
        
        attrs3[0].name = "Author"
        attrs3[0].displayName = "Author"
        attrs3[0].type = 0
        
        var bits3 = [Bit]()
        
        let books = ["eastofeden", "kiterunner", "beloved", "road", "mastermargarita", "remainsofday", "lifeofpi", "belljar", "secrethistory", "nightcircus", "shadowwind", "golemjinni"]
        let book_names = ["eastofeden": "East of Eden", "kiterunner": "The Kite Runner", "beloved": "Beloved", "road": "The Road", "mastermargarita": "The Master and Margarita", "remainsofday": "The Remains of the Day", "lifeofpi": "Life of Pi", "belljar": "The Bell Jar", "secrethistory": "The Secret History", "nightcircus": "The Night Circus", "shadowwind": "The Shadow of the Wind", "golemjinni": "The Golem and the Jinni"]
        let book_authors = ["eastofeden": "John Steinbeck", "kiterunner": "Khaled Hosseini", "beloved": "Toni Morrison", "road": "Cormac McCarthy", "mastermargarita": "Mikhail Bulgakov", "remainsofday": "Kazuo Ishiguro", "lifeofpi": "Yann Martel", "belljar": "Sylvia Plath", "secrethistory": "Donna Tartt", "nightcircus": "Erin Morgenstern", "shadowwind": "Carlos Ruiz Zafón", "golemjinni": "Helene Wecker"]
        
        for (i, book) in books.enumerated() {
            let bit = Bit(context: managedObjectContext)
            bit.name = book_names[book] ?? "none"
            bit.order = Int16(i)
            bit.attributes = ["Author" : book_authors[book] ?? ""]
            bits3 += [bit]
        }
        
        bobs[3].bits = NSSet(array: bits3)
        bobs[3].attributes = NSSet(array: attrs3)
        
        
        // MARK: - Other
        
        bobs[4].name = "Shells"
        bobs[4].image = UIImage(imageLiteralResourceName: "shells").pngData()
        
        bobs[5].name = "Cars"
        bobs[5].image = UIImage(imageLiteralResourceName: "cars").pngData()

        PersistenceController.shared.save()

    }
}
