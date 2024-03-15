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
            PersistenceController.nextBobID += 1
            bobs += [bob]
        }
        
        
        
        // MARK: - Quarters
        
        bobs[0].name = "Quarters"
        bobs[0].desc = "U.S. States and Territories"
        bobs[0].image = UIImage(imageLiteralResourceName: "coins").pngData()
        bobs[0].listType = 1
        bobs[0].displayType = 3
        bobs[0].displayBitIcon = true

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
        bobs[1].displayBitIcon = false
        
        var attrs1 = [Attribute]()
        for i in 0...2 {
            let attr = Attribute(context: managedObjectContext)
            attr.order = Int16(i)
            attrs1 += [attr]
        }
        
        attrs1[0].name = "Artist"
        attrs1[0].displayName = "Artist"
        attrs1[0].type = 0
        attrs1[0].groupable = true
        
        attrs1[1].name = "Genre"
        attrs1[1].displayName = "Genre"
        attrs1[1].type = 0
        
        attrs1[2].name = "Year"
        attrs1[2].displayName = "Release Year"
        attrs1[2].type = 1
        
        var bits1 = [Bit]()
        
        let albums = ["parachutes", "mots", "ahfod", "darksideofthemoon", "folklore", "1989tv", "positions"]
        let album_names = ["positions" : "Positions", "darksideofthemoon" : "The Dark Side of the Moon", "folklore" : "Folklore", "1989tv" : "1989 (Taylor's Version)", "parachutes": "Parachutes", "mots" : "Music of the Spheres", "ahfod" : "A Head Full of Dreams"]
        let album_artists = ["positions" : "Ariana Grande", "darksideofthemoon" : "Pink Floyd", "folklore" : "Taylor Swift", "1989tv" : "Taylor Swift", "parachutes": "Coldplay", "mots" : "Coldplay", "ahfod" : "Coldplay"]
        let album_years = ["positions": 2020, "darksideofthemoon": 1973, "folklore": 2020, "1989tv": 2023, "parachutes": 2000, "mots": 2021, "ahfod": 2015]
        let album_genres = ["positions": "Pop", "darksideofthemoon": "Rock", "folklore": "Alternative", "1989tv": "Pop", "parachutes": "Alternative", "mots": "Pop", "ahfod": "Alternative"]
        
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
        bobs[1].group = 1 // group by Artist
        
        
        // MARK: - Other
        
        bobs[2].name = "Plushies"
        bobs[2].image = UIImage(imageLiteralResourceName: "plushies").pngData()
        
        bobs[3].name = "Books"
        bobs[3].image = UIImage(imageLiteralResourceName: "books").pngData()
        
        bobs[4].name = "Shells"
        bobs[4].image = UIImage(imageLiteralResourceName: "shells").pngData()
        
        bobs[5].name = "Cars"
        bobs[5].image = UIImage(imageLiteralResourceName: "cars").pngData()
        
//        // Bob
//        
//        bobs[0].name = "Keepsakes"
//        bobs[0].desc = "My memories"
//        bobs[0].image = UIImage(imageLiteralResourceName: "sample3").pngData()
//        bobs[0].listType = 0 // list
//        bobs[0].displayType = 1 // large
//        bobs[0].displayBitIcon = true // icon
//        
//        // Attributes
//        
//        var attrs2 = [Attribute]()
//        for i in 0..<2 {
//            let attr = Attribute(context: managedObjectContext)
//            attr.order = Int16(i)
//            attrs2 += [attr]
//        }
//        
//        attrs2[0].name = "Origin"
//        attrs2[0].displayName = "Origin"
//        attrs2[0].type = 0 // text
//        attrs2[0].sortable = true
//        attrs2[0].groupable = true
//        attrs2[0].sortTextType = 1 // abc
//
//        attrs2[1].name = "Year Obtained"
//        attrs2[1].displayName = "Year Obtained"
//        attrs2[1].type = 1 // number
//        attrs2[1].minNum = 2000
//        attrs2[1].minIncluded = true
//        attrs2[1].maxNum = 2030
//        attrs2[1].maxIncluded = true
//        
//        // Bits
//        
//        var bits2 = [Bit]()
//        for i in 0..<7 {
//            let bit = Bit(context: managedObjectContext)
//            bit.order = Int16(i)
//            bit.attributes = [:]
//            bits2 += [bit]
//        }
//        
//        bits2[0].name = "Quilt"
//        bits2[0].image = UIImage(imageLiteralResourceName: "sample3g").pngData()
//        bits2[0].attributes!["Origin"] = "Family"
//        bits2[0].attributes!["Year Obtained"] = "2013"
//        bits2[0].paragraph = "This family heirloom holds a special place in our home. It's a treasured item that brings warmth and comfort to our lives."
//        
//        bits2[1].name = "Teddy Bear"
//        bits2[1].image = UIImage(imageLiteralResourceName: "sample3b").pngData()
//        bits2[1].attributes!["Origin"] = "Childhood"
//        bits2[1].attributes!["Year Obtained"] = "2000"
//        bits2[1].paragraph = ""
//        
//        bits2[2].name = "Souvenir"
//        bits2[2].image = UIImage(imageLiteralResourceName: "sample3c").pngData()
//        bits2[2].attributes!["Origin"] = "Road Trip"
//        bits2[2].attributes!["Year Obtained"] = "2018"
//        bits2[2].paragraph = ""
//        
//        bits2[3].name = "Ornament"
//        bits2[3].image = UIImage(imageLiteralResourceName: "sample3d").pngData()
//        bits2[3].attributes!["Origin"] = "Christmas"
//        bits2[3].attributes!["Year Obtained"] = "2020"
//        bits2[3].paragraph = ""
//        
//        bits2[4].name = "Necklace"
//        bits2[4].image = UIImage(imageLiteralResourceName: "sample3a").pngData()
//        bits2[4].attributes!["Origin"] = "Christmas"
//        bits2[4].attributes!["Year Obtained"] = "2019"
//        bits2[4].paragraph = ""
//        
//        bits2[5].name = "Trucks"
//        bits2[5].image = UIImage(imageLiteralResourceName: "sample3f").pngData()
//        bits2[5].attributes!["Origin"] = "Childhood"
//        bits2[5].attributes!["Year Obtained"] = "2002"
//        bits2[5].paragraph = ""
//        
//        bits2[6].name = "Ring"
//        bits2[6].image = UIImage(imageLiteralResourceName: "sample3e").pngData()
//        bits2[6].attributes!["Origin"] = "Engagement"
//        bits2[6].attributes!["Year Obtained"] = "2023"
//        bits2[6].paragraph = ""
//        
//        // Finalize Bob
//         
//        bobs[0].sort = 0 // sort by Default
//        bobs[0].bits = NSSet(array: bits2)
//        bobs[0].attributes = NSSet(array: attrs2)
//        bobs[0].nextBitID = Int16(bits2.count)
//        bobs[0].nextAttrID = Int16(attrs2.count)
//        
//        // MARK: - Model Trains
//        
//        // Bob
//        
//        bobs[1].name = "Model Trains"
//        bobs[1].image = UIImage(imageLiteralResourceName: "sample4").pngData()
//        bobs[1].listType = 0 // list
//        bobs[1].displayType = 1 // large
//        bobs[1].displayBitIcon = true // icon
//        
//        // MARK: - Destinations
//        
//        // Bob
//        
//        bobs[2].name = "Destinations"
//        bobs[2].desc = "My travel list"
//        bobs[2].image = UIImage(imageLiteralResourceName: "sample1").pngData()
//        bobs[2].listType = 1 // checklist
//        bobs[2].displayType = 1 // large
//        
//        // Attributes
//        
//        var attrs0 = [Attribute]()
//        for i in 0..<4 {
//            let attr = Attribute(context: managedObjectContext)
//            attr.order = Int16(i)
//            attrs0 += [attr]
//        }
//        
//        attrs0[0].name = "Country"
//        attrs0[0].displayName = "Country"
//        attrs0[0].type = 0 // text
//        attrs0[0].sortable = true
//        attrs0[0].groupable = true
//        attrs0[0].sortTextType = 1 // abc
//        
//        attrs0[1].name = "Location"
//        attrs0[1].displayName = "Location"
//        attrs0[1].type = 0 // text
//        attrs0[1].sortable = true
//        attrs0[1].groupable = true
//        attrs0[1].sortTextType = 1 // abc
//        
//        attrs0[2].name = "Language"
//        attrs0[2].displayName = "Language"
//        attrs0[2].type = 0 // text
//        attrs0[2].sortable = true
//        attrs0[2].groupable = true
//        attrs0[2].sortTextType = 1 // abc
//        
//        attrs0[3].name = "Distance"
//        attrs0[3].displayName = "Distance"
//        attrs0[3].type = 1 // number
//        attrs0[3].decimal = true
//        attrs0[3].minNum = 0
//        attrs0[3].minIncluded = true
//        attrs0[3].maxNum = Double.infinity
//        attrs0[3].maxIncluded = false
//        attrs0[3].suffix = "mi"
//        
//        // Bits
//        
//        var bits0 = [Bit]()
//        for i in 0..<5 {
//            let bit = Bit(context: managedObjectContext)
//            bit.order = Int16(i)
//            bit.attributes = [:]
//            bits0 += [bit]
//        }
//        
//        bits0[0].name = "Rome"
//        bits0[0].image = UIImage(imageLiteralResourceName: "sample1a").pngData()
//        bits0[0].attributes!["Country"] = "Italy"
//        bits0[0].attributes!["Location"] = "Europe"
//        bits0[0].attributes!["Language"] = "Italian"
//        bits0[0].attributes!["Distance"] = "4000"
//        bits0[0].paragraph = "A peek into the Old World, a classic civilization as old as time itself."
//        bits0[0].checked = true
//        
//        bits0[1].name = "San Francisco"
//        bits0[1].image = UIImage(imageLiteralResourceName: "sample1b").pngData()
//        bits0[1].attributes!["Country"] = "United States"
//        bits0[1].attributes!["Location"] = "North America"
//        bits0[1].attributes!["Language"] = "English"
//        bits0[1].attributes!["Distance"] = "3000"
//        bits0[1].paragraph = "A staple of California and of American culture, known for its icon, the Golden Gate Bridge."
//        bits0[1].checked = true
//        
//        bits0[2].name = "Svalbard"
//        bits0[2].image = UIImage(imageLiteralResourceName: "sample1c").pngData()
//        bits0[2].attributes!["Country"] = "Norway"
//        bits0[2].attributes!["Location"] = "Arctic Ocean"
//        bits0[2].attributes!["Language"] = "Norwegian"
//        bits0[2].attributes!["Distance"] = "4000"
//        bits0[2].paragraph = "One of the northernmost places in the world, Svalbard is known for its amazing view of the Aurora Borealis."
//        bits0[2].checked = true
//        
//        bits0[3].name = "Bora Bora"
//        bits0[3].image = UIImage(imageLiteralResourceName: "sample1d").pngData()
//        bits0[3].attributes!["Country"] = "French Polynesia"
//        bits0[3].attributes!["Location"] = "South Pacific"
//        bits0[3].attributes!["Language"] = "Tahitian"
//        bits0[3].attributes!["Distance"] = "6000"
//        bits0[3].paragraph = "A luxurious tropical getaway in French Polynesia."
//        bits0[3].checked = false
//        
//        bits0[4].name = "Dubai"
//        bits0[4].image = UIImage(imageLiteralResourceName: "sample1e").pngData()
//        bits0[4].attributes!["Country"] = "United Arab Emirates"
//        bits0[4].attributes!["Location"] = "Western Asia"
//        bits0[4].attributes!["Language"] = "Arabic"
//        bits0[4].attributes!["Distance"] = "7000"
//        bits0[4].paragraph = "Home of the tallest building in the world, the Burj Khalifa, Dubai is a city that showcases modern innovation."
//        bits0[4].checked = false
//        
//        // Finalize Bob
//         
//        bobs[2].sort = 2 // sort by Country
//        bobs[2].bits = NSSet(array: bits0)
//        bobs[2].attributes = NSSet(array: attrs0)
//        bobs[2].nextBitID = Int16(bits0.count)
//        bobs[2].nextAttrID = Int16(attrs0.count)
//        
//        // MARK: - Food
//        
//        // Bob
//        
//        bobs[3].name = "Food"
//        bobs[3].desc = "My favorite foods"
//        bobs[3].image = UIImage(imageLiteralResourceName: "sample2").pngData()
//        bobs[3].listType = 2 // ranking
//        bobs[3].displayType = 0 // small
//        
//        // Attributes
//        
//        var attrs1 = [Attribute]()
//        for i in 0..<2 {
//            let attr = Attribute(context: managedObjectContext)
//            attr.order = Int16(i)
//            attrs1 += [attr]
//        }
//        
//        attrs1[0].name = "Type"
//        attrs1[0].displayName = "Type"
//        attrs1[0].type = 0 // text
//        attrs1[0].sortable = true
//        attrs1[0].groupable = true
//        attrs1[0].sortTextType = 0 // ordered
//        attrs1[0].restrictPresets = true
//        attrs1[0].presets = ["Breakfast","Dinner","Dessert"]
//        
//        attrs1[1].name = "Rating"
//        attrs1[1].displayName = "Rating"
//        attrs1[1].type = 1 // number
//        attrs1[1].minNum = 0
//        attrs1[1].minIncluded = false
//        attrs1[1].maxNum = 10
//        attrs1[1].maxIncluded = true
//        attrs1[1].suffix = "★"
//        
//        // Bits
//        
//        var bits1 = [Bit]()
//        for i in 0..<6 {
//            let bit = Bit(context: managedObjectContext)
//            bit.order = Int16(i)
//            bit.attributes = [:]
//            bits1 += [bit]
//        }
//        
//        bits1[0].name = "Pasta"
//        bits1[0].image = UIImage(imageLiteralResourceName: "sample2a").pngData()
//        bits1[0].attributes!["Type"] = "Dinner"
//        bits1[0].attributes!["Rating"] = "10"
//        bits1[0].paragraph = ""
//        
//        bits1[1].name = "Waffles"
//        bits1[1].image = UIImage(imageLiteralResourceName: "sample2b").pngData()
//        bits1[1].attributes!["Type"] = "Breakfast"
//        bits1[1].attributes!["Rating"] = "9"
//        bits1[1].paragraph = ""
//        
//        bits1[2].name = "Dumplings"
//        bits1[2].image = UIImage(imageLiteralResourceName: "sample2c").pngData()
//        bits1[2].attributes!["Type"] = "Dinner"
//        bits1[2].attributes!["Rating"] = "9"
//        bits1[2].paragraph = ""
//        
//        bits1[3].name = "Cookies"
//        bits1[3].image = UIImage(imageLiteralResourceName: "sample2d").pngData()
//        bits1[3].attributes!["Type"] = "Dessert"
//        bits1[3].attributes!["Rating"] = "9"
//        bits1[3].paragraph = ""
//        
//        bits1[4].name = "Pizza"
//        bits1[4].image = UIImage(imageLiteralResourceName: "sample2e").pngData()
//        bits1[4].attributes!["Type"] = "Dinner"
//        bits1[4].attributes!["Rating"] = "8"
//        bits1[4].paragraph = ""
//        
//        bits1[5].name = "Sushi"
//        bits1[5].image = UIImage(imageLiteralResourceName: "sample2f").pngData()
//        bits1[5].attributes!["Type"] = "Dinner"
//        bits1[5].attributes!["Rating"] = "7"
//        bits1[5].paragraph = ""
//        
//        // Finalize Bob
//         
//        bobs[3].sort = 0 // sort by Ranking
//        bobs[3].bits = NSSet(array: bits1)
//        bobs[3].attributes = NSSet(array: attrs1)
//        bobs[3].nextBitID = Int16(bits1.count)
//        bobs[3].nextAttrID = Int16(attrs1.count)
//        
//        // MARK: - Books
//        
//        // Bob
//        
//        bobs[4].name = "Books"
//        bobs[4].desc = "Favorites ranked"
//        bobs[4].image = UIImage(imageLiteralResourceName: "sample6").pngData()
//        bobs[4].listType = 0 // list
//        bobs[4].displayType = 1 // large
//        bobs[4].displayBitIcon = true // icon
                
        PersistenceController.shared.save()

    }
}
