//
//  Card.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 25/05/2025.
//

import Foundation

struct Card: Identifiable, Equatable {
    let numberOfItems: Int
    let features: [String]
            
    var deckStatus: DeckStatus = .deck
    var selectionStatus: SelectionStatus = .notSelected
    
    let id: UUID = UUID()
    enum DeckStatus {
        case deck, table, removed
    }
    enum SelectionStatus {
        case notSelected, selected, matched, misMatched
    }
}
