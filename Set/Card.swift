//
//  Card.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 25/05/2025.
//

import Foundation

/// An Set card with a given number of items, features and a status.
struct Card: Identifiable, Equatable, CustomDebugStringConvertible {
    let numberOfItems: Int
    let cardFeatures: [String: String]
            
    var deckStatus: DeckStatus = .deck
    var selectionStatus: SelectionStatus = .notSelected
    
    let id: UUID = UUID()
    
    enum DeckStatus {
        case deck, table, removed
    }
    
    enum SelectionStatus {
        case notSelected, selected, matched, misMatched
    }
    
    var debugDescription: String {
            return "[id: \(id), decksStatus: \(deckStatus), selectionStatus: \(selectionStatus)]"
        }
}
