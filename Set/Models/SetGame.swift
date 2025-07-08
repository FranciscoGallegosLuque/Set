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
    private(set) var setSize: Int
    private(set) var gameEnded: Bool = false
    private(set) var score = 0
    
    
    // MARK: - Init
    init(theme: Theme, tableAmount: Int) {
        self.cards = []
        self.setSize = theme.setSize
        
        let features = theme.features
        let combinations = cartesianProduct(features.map { $0.possibleValues })
        
        var featuresNames: [String] = []
        for feature in features {
            featuresNames.append(feature.name)
        }
        
        for i in 1...theme.setSize {
            for combination in combinations {
                let cardFeatures: [String: String] = Dictionary(uniqueKeysWithValues: zip(featuresNames, combination))
                    cards.append(Card(numberOfItems: i, cardFeatures: cardFeatures))
                }
            }
        
        cards = cards.shuffled()
        
        let cardsIndexes = Array(cards.indices)
        let tableIndexes = Array(cardsIndexes.prefix(tableAmount))
        
        for index in tableIndexes {
            cards[index].deckStatus = .table
        } 
    }
    
    
    // MARK: - Computed Properties
    var selectedCards: [Card] { cards.filter { $0.selectionStatus == .selected } }
    var matchedCards: [Card] { cards.filter { $0.selectionStatus == .matched } }
    var misMatchedCards: [Card] { cards.filter { $0.selectionStatus == .misMatched } }
    var deckCards: [Card] { cards.filter { $0.deckStatus == .deck } }
    var tableCards: [Card] { cards.filter { $0.deckStatus == .table } }
    var availableSet: Bool {
        checkAvailableSet()
    }
    
    // MARK: - Public Methods
    mutating func addCards() {
        if availableSet { score -= 3 }
        let addedCards = Array(deckCards.prefix(setSize))
        if matchedCards.isEmpty {
            for card in addedCards {
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].deckStatus = .table
                }
            }
        }
        
    }
    
    mutating func replaceCards() {
        let newCards = Array(deckCards.prefix(matchedCards.count))
        for newCard in newCards {
            if let newCardIndex = cards.firstIndex(where: { $0.id == newCard.id }) {
                if let matchedCardIndex = cards.firstIndex(where: { $0.id == matchedCards.first?.id }) {
                    cards[matchedCardIndex].deckStatus = .removed
                    cards[matchedCardIndex].selectionStatus = .notSelected
                    cards[newCardIndex].deckStatus = .table
                    cards.swapAt(newCardIndex, matchedCardIndex)
                }
            }
        }
    }
    
    mutating func removeCards() {
        for matchedCard in matchedCards {
            if let matchedCardIndex = cards.firstIndex(where: { $0.id == matchedCard.id }) {
                cards[matchedCardIndex].deckStatus = .removed
                cards[matchedCardIndex].selectionStatus = .notSelected
            }
        }
    }
    
    func checkAvailableSet() -> Bool {
        let tableSubsets = subsetsFactory(of: tableCards, taking: setSize)
        return tableSubsets.contains(where: { setChecker(cards: $0) })
    }
    
    mutating func handleCardSelection(card: Card) {
        
        if selectedCards.isEmpty {
            if misMatchedCards.isEmpty && matchedCards.isEmpty {
                toggleSelection(of: card)
            } else if card.selectionStatus != .matched {
                fourthCardSelected(card)
            }
        } else if selectedCards.count == setSize - 1 {
            if card.selectionStatus == .selected {
                toggleSelection(of: card)
            } else {
                toggleSelection(of: card)
                updateSelectionStatuses()
            }
        } else {
            toggleSelection(of: card)
        }
    }
    
    mutating func fourthCardSelected(_ card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            if misMatchedCards.isEmpty {
                if deckCards.isEmpty {
                    removeCards()
                    if cards[selectedIndex].selectionStatus != .selected { toggleSelection(of: card) }
                } else {
                    replaceCards()
                    if cards[selectedIndex].selectionStatus != .selected { toggleSelection(of: card) }
                }
            } else {
                toggleSelection(of: card)
                for misMatchedCard in misMatchedCards {
                    changeSelectionStatusOf(misMatchedCard, to: .notSelected)
                }
            }
        }
    }

    
    // MARK: - Private Methods
    
    private func setChecker(cards: [Card]) -> Bool {
        let amountOfFeatures: Int = setSize
        guard cards.count == amountOfFeatures else { return false }
        guard let firstCard = cards.first else { return false }
        let featuresNames: [String] = Array(firstCard.cardFeatures.keys)

        for featuresName in featuresNames {
            let values = cards.map { $0.cardFeatures[featuresName] }
            if !(values.allThreeEqual || values.allThreeDifferent) {
                return false
            }

        }
        return true
    }
    
    mutating private func updateSelectionStatuses() {
        if setChecker(cards: selectedCards) {
            for card in selectedCards {
                changeSelectionStatusOf(card, to: .matched)
            }
            if tableCards.count == setSize {
                removeCards()
                gameEnded.toggle()
            }
            score += setSize
        } else {
            for card in selectedCards {
                changeSelectionStatusOf(card, to: .misMatched)
            }
            score -= 1
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

    private func cartesianProduct<T>(_ arrays: [[T]]) -> [[T]] {
        var result: [[T]] = [[]]

        for array in arrays {
            var newResult: [[T]] = []
            for partial in result {
                for element in array {
                    newResult.append(partial + [element])
                }
            }
            result = newResult
        }

        return result
    }

    func subsetsFactory<T>(of array: [T], taking n: Int) -> [[T]] {
        guard n > 0 else { return [[]] }
        guard array.count >= n else { return [] }

        if n == array.count {
            return [array]
        }

        if n == 1 {
            return array.map { [$0] }
        }

        var result: [[T]] = []

        for (index, element) in array.enumerated() {
            let remaining = Array(array[(index + 1)...])
            let subCombos = subsetsFactory(of: remaining, taking: n - 1)
            result += subCombos.map { [element] + $0 }
        }

        return result
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
