//
//  SetGame.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 03/05/2025.
//

import Foundation

struct SetGame {
    
    // MARK: - Properties
    private(set) var cards: [Card]
    
    // MARK: - Init
    init(theme: Theme, display amount: Int, numberOfItems: [Int]) {
        cards = []
        
        for number in numberOfItems {
            for f1 in theme.features[0].possibleValues {
                for f2 in theme.features[1].possibleValues {
                    for f3 in theme.features[2].possibleValues {
                        cards.append(Card(numberOfItems: number, features: [f1, f2, f3]))
                    }
                }
            }
        }
        
        let cardsIndexes = Array(cards.indices)
        let randomIndexes = Array(cardsIndexes.shuffled().prefix(amount))
        for index in randomIndexes {
            cards[index].deckStatus = .table
        }
    }
    
    // MARK: - Computed Properties
    var selectedCards: [Card] {
        cards.filter { $0.selectionStatus == .selected }
    }
    
    var matchedCards: [Card] {
        cards.filter { $0.selectionStatus == .matched }
    }
    
    var misMatchedCards: [Card] {
        cards.filter { $0.selectionStatus == .misMatched }
    }
    
    var deckCards: [Card] {
        cards.filter { $0.deckStatus == .deck }
    }
    
    var tableCards: [Card] {
        cards.filter { $0.deckStatus == .table }
    }
    
    // MARK: - Public Methods
    mutating func addCards() {
        if setChecker(cards: selectedCards) {
            removeSet()
        }
        let addedCards = Array(deckCards.shuffled().prefix(3))
        for card in addedCards {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].deckStatus = .table
            }
        }
    }
    
    mutating func handleCardSelection(card: Card) {
        switch selectedCards.count {
        case 0:
            if misMatchedCards.isEmpty && matchedCards.isEmpty { toggleSelection(of: card) }
            else { fourthCardSelected(card) }
        case 1:
            toggleSelection(of: card)
        case 2:
            toggleSelection(of: card)
            updateSelectionStatuses()
        default: break
        }
        
    }
    
    mutating func fourthCardSelected(_ card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            if misMatchedCards.isEmpty {
                if cards[selectedIndex].selectionStatus != .selected { toggleSelection(of: card) }
                removeSet()
                addCards()
            } else {
                cards[selectedIndex].selectionStatus = .selected
                for misMatchedCard in misMatchedCards {
                    if let index = cards.firstIndex(where: { $0.id == misMatchedCard.id }) {
                        cards[index].selectionStatus = .notSelected
                    }
                }
            }
        }
    }

    
    // MARK: - Private Methods
    mutating private func removeSet() {
        for matchedCard in matchedCards {
            if let index = cards.firstIndex(where: { $0.id == matchedCard.id }) {
                cards[index].selectionStatus = .notSelected
                cards[index].deckStatus = .removed
            }
        }
    }
    
    private func setChecker(cards: [Card]) -> Bool {
        let features: [Int] = [0,1,2,3]
        var feats: [[String]] = [[], [], [], []]
        
        for card in cards {
            for feature in features {
                switch feature {
                case 0: feats[0].append(card.features[0])
                case 1: feats[1].append(card.features[1])
                case 2: feats[2].append(card.features[2])
                case 3: feats[3].append(card.features[3])
                default: break
                }
            }
        }
        return feats.allSatisfy({ $0.allThreeEqual || $0.allThreeDifferent })
    }
    
    mutating private func updateSelectionStatuses() {
        if setChecker(cards: selectedCards) {
            for card in selectedCards {
                changeSelectionStatusOf(card, to: .matched)
            }
        } else {
            for card in selectedCards {
                changeSelectionStatusOf(card, to: .misMatched)
            }
        }
    }
    
    private mutating func changeSelectionStatusOf(_ card: Card, to newStatus: Card.SelectionStatus) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            cards[selectedIndex].selectionStatus = newStatus
        }
    }
    
    
    private mutating func toggleSelection(of card: Card) {
        if card.selectionStatus == .selected {
            changeSelectionStatusOf(card, to: .notSelected)
        } else {
            changeSelectionStatusOf(card, to: .selected)
        }
    }
        
}

// MARK: - Extensions
extension Array where Element: Equatable {
    var allThreeEqual: Bool {
        guard self.count == 3 else { return false }
        return self[0] == self[1] && self[1] == self[2]
    }
}

extension Array where Element: Equatable {
    var allThreeDifferent: Bool {
        guard self.count == 3 else { return false }
        return self[0] != self[1] && self[1] != self[2] && self[0] != self[2]
    }
}
