//
//  Collection.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import Foundation

class Collection: ObservableObject {
    
    static let collection = Collection()
    
    @Published var bobs = getBobs()
    
    @Published var edit: Bool = false
}

func getBobs() -> [Bob] {
    
    let bobs: [Bob] = [
        
        Bob (
            id: 0,
            name: "Destinations",
            desc: "My favorite places I've been",
            icon: "tropicalbeach",
            bits: [
                Bit (
                    id: 0,
                    name: "Lake Placid, NY",
                    desc: "Olympic ski village in the Adirondacks",
                    paragraph: "Lake Placid hosted the Winter Olympics in 1932 and 1980. During the 1932 games, the trails outside of the village served for the cross-country skiing events and the cross-country skiing part of the Nordic combined event. Lake Placid, St Moritz, and Innsbruck are the only sites to have twice hosted the Winter Olympic Games. Jack Shea, a resident of the village, became the first person to win two gold medals when he doubled in speed skating at the 1932 Winter Olympics. He carried the Olympic torch through Lake Placid in 2002 shortly before his death. His grandson, Jimmy Shea, competed in the 2002 Winter Olympics in Salt Lake City, Utah, in his honor, winning gold in the Skeleton. In the U.S., the village is especially remembered as the site of the 1980 USA–USSR hockey game. Dubbed the \"Miracle on Ice\", a group of American college students and amateurs upset seasoned and professional Soviet national ice hockey team, 4–3, and two days later won the gold medal. Another high point during the Games was the performance of American speed-skater Eric Heiden, who won five gold medals. Lake Placid was interested in bidding for the 2016 Winter Youth Olympics but decided against it; Lillehammer, Norway, was the only bidder and was awarded the games. Lake Placid shifted its interest toward bidding for the 2020 Winter Youth Olympics, but it again did not submit a bid.",
                    icon: "lakeplacid",
                    attributes: [
                        "New York",
                        "Mountains"
                    ]
                ),
                Bit (
                    id: 1,
                    name: "Williamsburg, VA",
                    desc: "Historic settlement on the James River",
                    paragraph: "Williamsburg was founded in 1632 as Middle Plantation, a fortified settlement on high ground between the James and York rivers. The city was the capital of the Colony and Commonwealth of Virginia from 1699 to 1780 and the center of political events in Virginia leading to the American Revolution. The College of William & Mary, established in 1693, is the second-oldest institution of higher education in the United States and the only one of the nine colonial colleges in the South; its alumni include three U.S. presidents as well as many other important figures in the nation's early history. The city's tourism-based economy is driven by Colonial Williamsburg, the city's restored Historic Area. Along with nearby Jamestown and Yorktown, Williamsburg forms part of the Historic Triangle, which annually attracts more than four million tourists. Modern Williamsburg is also a college town, inhabited in large part by William & Mary students, faculty and staff.",
                    icon: "williamsburg",
                    attributes: [
                        "Virginia",
                        "Settlement"
                    ]
                ),
                Bit (
                    id: 2,
                    name: "St. Augustine, FL",
                    desc: "Old Spanish town on the Floridian east coast",
                    paragraph: "St. Augustine (from Spanish: San Agustín) is a city in the Southeastern United States, on the Atlantic coast of northeastern Florida. Founded in 1565 by Spanish explorers, it is the oldest continuously-inhabited European-established settlement in the contiguous United States (San Juan, Puerto Rico was settled earlier, in 1521). St. Augustine was founded on September 8, 1565, by Spanish admiral Pedro Menéndez de Avilés, Florida's first governor. He named the settlement \"San Agustín\", as his ships bearing settlers, troops, and supplies from Spain had first sighted land in Florida eleven days earlier on August 28, the feast day of St. Augustine. The city served as the capital of Spanish Florida for over 200 years. It was designated as the capital of British East Florida when the colony was established in 1763; Great Britain returned Florida to Spain in 1783.",
                    icon: "staugustine",
                    attributes: [
                        "Florida",
                        "Settlement"
                    ]
                ),
                Bit (
                    id: 3,
                    name: "Cape May, NJ",
                    desc: "Shore town in Southern New Jersey",
                    paragraph: "Cape May is a city at the southern tip of Cape May Peninsula in Cape May County, New Jersey, where the Delaware Bay meets the Atlantic Ocean. One of the country's oldest vacation resort destinations, it is part of the Ocean City Metropolitan Statistical Area. The entire city of Cape May is designated the Cape May Historic District, a National Historic Landmark due to its concentration of Victorian buildings. Cape May began hosting vacationers from Philadelphia in the mid 18th century and is recognized as the country's oldest seaside resort. Following the construction of Congress Hall in 1816, Cape May became increasingly popular in the 19th century and was considered one of the finest resorts in America by the 20th century.",
                    icon: "capemay",
                    attributes: [
                        "New Jersey",
                        "Beach"
                    ]
                )
            ],
            attributes: [
                "State",
                "Type"
            ]
        ),
        
        Bob (
            id: 1,
            name: "Food",
            desc: "My favorite things I've eaten",
            icon: "fries",
            bits: [
                Bit (
                    id: 0,
                    name: "French Fries",
                    desc: "Yum yum yum",
                    paragraph: "",
                    icon: "fries",
                    attributes: [
                        "Side",
                        "9"
                    ]
                ),
                Bit (
                    id: 1,
                    name: "Pasta",
                    desc: "Saucy",
                    paragraph: "",
                    icon: "pasta",
                    attributes: [
                        "Dinner",
                        "10"
                    ]
                ),
                Bit (
                    id: 2,
                    name: "Waffles",
                    desc: "Blueberry with syrup",
                    paragraph: "",
                    icon: "waffles",
                    attributes: [
                        "Breakfast",
                        "8"
                    ]
                ),
                Bit (
                    id: 3,
                    name: "Strawberries",
                    desc: "Triangular red fruits",
                    paragraph: "",
                    icon: "strawberry",
                    attributes: [
                        "Fruit",
                        "7"
                    ]
                ),
            ],
            attributes: [
                "Type",
                "Rating"
            ]
        )
    ]
    
    return bobs
    
}
