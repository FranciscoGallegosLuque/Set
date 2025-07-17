//
//  SetGame.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 03/05/2025.
//

import Foundation

struct SetGame {
    
    // MARK: - Properties
    private let gameSettings: GameSettings
    private(set) var cards: [Card]
    private(set) var gameEnded: Bool
    var setSize: Int { gameSettings.theme.setSize }
    
    // MARK: - Computed Properties
    var selectedCards: [Card] { cards.filter { $0.selectionStatus == .selected } }
    var matchedCards: [Card] { cards.filter { $0.selectionStatus == .matched } }
    var misMatchedCards: [Card] { cards.filter { $0.selectionStatus == .misMatched } }
    
    var deckCards: [Card] { cards.filter { $0.deckStatus == .deck } }
    var removedCards: [Card] { cards.filter { $0.deckStatus == .removed } }
    var tableCards: [Card] { cards.filter { $0.deckStatus == .table } }
    
    var hasAvailableSet: Bool { checkAvailableSet() }
    
    // MARK: - Init
    /// Creates a Set Game with a given theme and initial number of cards to be displayed on the table.
    /// - Parameters:
    ///   - theme: The theme that defines the features and set size for the game.
    ///   - initialNumberOfCards: The number of cards to be initially displayed on the table.
    init(_ gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        self.cards = []
        self.gameEnded = false
        
        generateDeck(from: gameSettings.theme)
        generateTableCards(with: gameSettings.initialNumberOfCards)
    }

    
    // MARK: - Public Methods
    
    mutating func moveCardsToDeck() {
        for card in cards {
            updateCard(card) { card in
                card.deckStatus = .deck
                card.selectionStatus = .notSelected
            }
        }
    }
    
    mutating func dealCards() {
        gameEnded = false
        generateTableCards(with: gameSettings.initialNumberOfCards)
    }
    
    mutating func select(card: Card) {
        toggleSelection(of: card)
    }

    mutating func deSelect(card: Card) {
        updateCard(card) { card in
            card.selectionStatus = .notSelected
        }
    }
    
    /// Removes a set from the table.
    mutating func removeCards() {
        guard !matchedCards.isEmpty else { return }
        for matchedCard in matchedCards {
            updateCard(matchedCard) { card in
                card.deckStatus = .removed
                card.selectionStatus = .notSelected
            }
        }
    }
    
    /// Adds a defined number of deck cards to the table.
    mutating func addCards() {
        guard matchedCards.isEmpty else { return }
        let addedCards = Array(deckCards.prefix(setSize))
        for addedCard in addedCards {
            updateCard(addedCard) { card in
                card.deckStatus = .table
            }
        }
    }
    
    /// Replaces a selected set from the table with new deck cards.
    mutating func replaceCards() {
        let newCards = Array(deckCards.prefix(matchedCards.count))
        
        for (newCard, matchedCard) in zip(newCards, matchedCards) {
            if let newCardIndex = cards.firstIndex(where: { $0.id == newCard.id }) {
                if let matchedCardIndex = cards.firstIndex(where: { $0.id == matchedCard.id }) {
                    
                    cards[matchedCardIndex].deckStatus = .removed
                    cards[matchedCardIndex].selectionStatus = .notSelected
                    
                    cards[newCardIndex].deckStatus = .table
                }
            }
        }
    }
    
   
    // MARK: - Private Helpers
    
    /// Updates a card by a given changes closure.
    /// - Parameters:
    ///   - card: The card to be updates.
    ///   - changes: A changes closure.
    private mutating func updateCard(_ card: Card, changes: (inout Card) -> Void) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            changes(&cards[index])
        }
    }
    
    /// Changes a given card selection status to a new one.
    /// - Parameters:
    ///   - card: The card to be updated.
    ///   - newStatus: The new selection status of the card.
    private mutating func changeSelectionStatusOf(_ card: Card, to newStatus: Card.SelectionStatus) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            cards[selectedIndex].selectionStatus = newStatus
        }
    }
    
    /// Toggle the selection status of a card from selected to not selected.
    /// - Parameter card: The card to be updated.
    private mutating func toggleSelection(of card: Card) {
        card.selectionStatus == .selected ? changeSelectionStatusOf(card, to: .notSelected) : changeSelectionStatusOf(card, to: .selected)
    }
    
    /// Updates the selection status of cards when a possible set is selected on the table.
    mutating func updateSelectionStatuses(cards: [Card]) {
        if isValidSet(cards: cards) {
            for card in cards {
                changeSelectionStatusOf(card, to: .matched)
            }
            if tableCards.count == setSize {
                removeCards()
                if deckCards.isEmpty { gameEnded.toggle() }
            }
        } else {
            for card in cards {
                changeSelectionStatusOf(card, to: .misMatched)
            }
        }
    }

    
    /// Checks whether a possible set is currently on the table or not.
    /// - Returns: `true` if there is a set on the table; `false` otherwise.
    private func checkAvailableSet() -> Bool {
        let tableSubsets = subsetsFactory(of: tableCards, taking: setSize)
        return tableSubsets.contains(where: { isValidSet(cards: $0) })
    }
    
    /// Checks whether a group of cards forms a valid set or not.
    /// - Parameter cards: The cards possibly forming a set.
    /// - Returns: `true` if the cards form a valid set; `false` otherwise.
    func isValidSet(cards: [Card]) -> Bool {
        let amountOfFeatures: Int = setSize
        guard cards.count == amountOfFeatures else { return false }
        guard let firstCard = cards.first else { return false }
        let featuresNames: [String] = Array(firstCard.cardFeatures.keys)

        for featuresName in featuresNames {
            let values = cards.map { $0.cardFeatures[featuresName] }
            if !(values.allEqual || values.allDifferent) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Deck Generation
    /// Generates a deck of cards with all the combinations of features given by the theme.
    /// - Parameter theme: The Set mode defining the features shown in the cards.
    private mutating func generateDeck(from theme: Theme) {
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
    }
    
    /// Generates a random group of a given number of table cards.
    private mutating func generateTableCards(with initialNumberOfCards: Int) {
        cards.shuffle()
        
        let initialTableCards = Array(cards.prefix(initialNumberOfCards))
        
        for card in initialTableCards {
            updateCard(card) { $0.deckStatus = .table }
        }
    }
}

// MARK: - Utilities
/// Creates all possible combination of a cartesian product of a given array of arrays.
/// - Parameter arrays: The different subset to be combined.
/// - Returns: An array of all the elements of the arrays combined in a cartesian product.
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

/// Return all the possible subsets of size n of a given set.
/// - Parameters:
///   - array: The given set from which the subset are going to be created.
///   - n: The size of the subsets.
/// - Returns: An array of all the possible subsets that can be formed.
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
    /// Returns a Boolean whether all the elements of the array are equal or not.
    var allEqual: Bool {
        guard let first = self.first else { return false }
        return allSatisfy { $0 == first }
    }
}

extension Array where Element: Hashable {
    /// Returns a Boolean whether all the elements of the array are different or not.
    var allDifferent: Bool {
        count == Set(self).count
    }
}
