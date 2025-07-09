//
//  Theme.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 04/05/2025.
//

import Foundation

/// A Set game theme that defines what features the game has and how many cards form a set.
struct Theme {
    
    var setSize: Int {
        features.count
    }
    
    let features: [Feature]
    
    struct Feature {
        let name: String
        let possibleValues: [String]
    }
}


