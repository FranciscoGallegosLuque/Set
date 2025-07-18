//
//  Grid.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 18/07/2025.
//

import Foundation

/// A space in a grid that may be empty or contain an object.
struct Slot: Identifiable, CustomDebugStringConvertible {
    let id: UUID = UUID()
    let cardID: Card.ID?
    
    var debugDescription: String {
        if cardID != nil {
            "card: \(String(describing: cardID))"
        } else {
            "card: empty"
        }
    }
}
