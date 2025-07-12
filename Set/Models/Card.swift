//
//  Card.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 25/05/2025.
//

import Foundation

/// An Set card with a given number of items, features and a status.
struct Card: Identifiable, Equatable, CustomDebugStringConvertible {
    let numberOfFigures: Int // The amount of figures the card has.
    let cardFeatures: [String: String]
            
    var deckStatus: DeckStatus = .deck // Defines in which deck the card is.
    var selectionStatus: SelectionStatus = .notSelected // Defines if the card is selected or not.
    
    var isFaceUp: Bool {
        switch self.deckStatus {
        case .table, .removed:
            true
        default:
            false
        }
    }
    
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
