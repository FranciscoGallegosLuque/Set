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
    private let gameSettings: GameSettings
    private let setSize: Int // The number of cards that form a set.
    //    private let numberOfAddedCards: Int // The number of cards added when requested.
    private(set) var gameEnded: Bool = false
    private(set) var score = 0
    
    
    // MARK: - Init
    /// Creates a Set Game with a given theme and initial number of cards to be displayed on the table.
    /// - Parameters:
    ///   - theme: The theme that defines the features and set size for the game.
    ///   - initialNumberOfCards: The number of cards to be initially displayed on the table.
    init(_ gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self.cards = []
        self.setSize = gameSettings.theme.features.count
        
        let themeFeatures: [Theme.Feature] = gameSettings.theme.features
        let featuresCombinations = cartesianProduct(themeFeatures.map { $0.possibleValues })
        
        var featuresNames: [String] = []
        for themeFeature in themeFeatures {
            featuresNames.append(themeFeature.name)
        }
        
        for i in 1...gameSettings.theme.setSize {
            for featuresCombination in featuresCombinations {
                let cardFeaturesValues: [String: String] = Dictionary(uniqueKeysWithValues: zip(featuresNames, featuresCombination))
                cards.append(Card(numberOfFigures: i, cardFeatures: cardFeaturesValues))
            }
        }
        
        cards = cards.shuffled()
        
        let cardsIndexes = Array(cards.indices)
        let tableIndexes = Array(cardsIndexes.prefix(gameSettings.initialNumberOfCards))
        
        for tableIndex in tableIndexes {
            cards[tableIndex].deckStatus = .table
        }
    }
    
    
    // MARK: - Computed Properties
    var selectedCards: [Card] { cards.filter { $0.selectionStatus == .selected } }
    var matchedCards: [Card] { cards.filter { $0.selectionStatus == .matched } }
    var misMatchedCards: [Card] { cards.filter { $0.selectionStatus == .misMatched } }
    var deckCards: [Card] { cards.filter { $0.deckStatus == .deck } }
    var removedCards: [Card] { cards.filter { $0.deckStatus == .removed }}
    var tableCards: [Card] { cards.filter { $0.deckStatus == .table } }
    var hasAvailableSet: Bool { checkAvailableSet() }
    
    // MARK: - Public Methods
    /// Adds a defined number of deck cards to the table.
    mutating func addCards() {
        if hasAvailableSet { score -= 3 }
        guard matchedCards.isEmpty else { return }
        let addedCards = Array(deckCards.prefix(setSize))
        for addedCard in addedCards {
            if let addedCardIndex = cards.firstIndex(where: { $0.id == addedCard.id }) {
                cards[addedCardIndex].deckStatus = .table
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
        return tableSubsets.contains(where: { isValidSet(cards: $0) })
    }
    
    mutating func handleCardSelection(card: Card) {
        
        if selectedCards.isEmpty {
            if misMatchedCards.isEmpty && matchedCards.isEmpty {
                toggleSelection(of: card)
            } else if card.selectionStatus != .matched {
                handleFourthCardSelection(card)
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
    
    mutating func handleFourthCardSelection(_ card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            if misMatchedCards.isEmpty {
                if deckCards.isEmpty {
                    removeCards()
                    if cards[selectedIndex].selectionStatus != .selected { toggleSelection(of: card) }
                } else {
                    removeCards()
//                    replaceCards()
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
    
    private func isValidSet(cards: [Card]) -> Bool {
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
        if isValidSet(cards: selectedCards) {
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
