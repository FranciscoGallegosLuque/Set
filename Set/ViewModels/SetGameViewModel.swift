//
//  SetGameViewModel.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import Foundation
import SwiftUI


class SetGameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var game: SetGame = SetGame(GameConfig.classic)
    @Published var grid: [Slot] = []
    
    // MARK: - State Tracking
    private(set) var removedCardIDsInOrder: [Card.ID] = []
    var newTableCards: [Card] = []
    
    //MARK: - Init
    init() {
        createNewGrid()
    }
    
    //MARK: - Computed Properties
    var cards: [Card] { game.cards }
    var deckCards: [Card] { game.deckCards }
    var tableCards: [Card] { game.tableCards }
    var selectedCards: [Card] { game.selectedCards }
    var matchedCards: [Card] { game.matchedCards }
    var misMatchedCards: [Card] { game.misMatchedCards }
    var removedCards: [Card] {
        removedCardIDsInOrder.compactMap { id in
            cards.first(where: { $0.id == id })
        }
    }
    private var undealtTableCards: [Card] {
        tableCards.filter { card in
            !grid.contains(where: { $0.cardID == card.id })
        }
    }
    var gameEnded: Bool { game.gameEnded }
    var availableSet: Bool { game.hasAvailableSet }
    var isSetComplete: Bool {
        selectedCards.count == game.setSize
    }

    
    // MARK: - Private Methods
    
    /// Creates a new grid with the table cards.
    private func createNewGrid() {
        if !grid.isEmpty { grid = [] }
        for tableCard in tableCards {
            self.grid.append(Slot(cardID: tableCard.id))
        }
    }
    
    /// Creates a new empty grid.
    private func createNewEmptyGrid() {
        grid = []
        for _ in tableCards {
            self.grid.append(Slot(cardID: nil))
        }
    }
    
    /// Removes cards from grid's slots in case they were matched and removed.
    private func removeCardsFromSlots() {
        for index in grid.indices {
            guard let cardID = grid[index].cardID,
                  let card = cards.first(where: { $0.id == cardID }),
                  card.deckStatus == .removed else { continue }
            grid[index] = Slot(cardID: nil)
        }
    }
    
    
    /// Adds cards to grid's empty slots.
    /// - Parameter newCards: The cards to be added to the grid.
    private func fillEmptySlots(with newCards: inout [Card]) {
        if grid.contains(where: {$0.cardID == nil}) {
            for index in grid.indices {
                if grid[index].cardID == nil {
                    if newCards.isEmpty { break }
                    let newSlot: Slot = Slot(cardID: newCards.removeFirst().id)
                    grid[index] = newSlot
                }
            }
        } else {
            for newTableCard in newTableCards {
                grid.append(Slot(cardID: newTableCard.id))
            }
        }
    }
    
    /// Updates the removed cards.
    /// - Parameter allRemovedCards: The actual removed cards, including old ones and newly added.
    func updateRemovedCards(with allRemovedCards: [Card]) {
        let known = Set(removedCardIDsInOrder)
        let newlyRemoved = allRemovedCards.filter { !known.contains($0.id) }
        removedCardIDsInOrder.append(contentsOf: newlyRemoved.map { $0.id })
    }
    
    /// Manages the initial deal when starting a new game.
    private func startInitialDeal() {
        game.dealCards()
        createNewEmptyGrid()
        newTableCards = tableCards
        placeCardsOnGrid(from: newTableCards)
    }
    
    /// Adds new cards to the table when the user taps the deck pile.
    private func dealAdditionalCards() {
        game.addCards()
        newTableCards = undealtTableCards
        placeCardsOnGrid(from: newTableCards)
    }
    
    /// Removes the selected matched set and replaces it for new cards.
    private func replaceMatchedCards() {
        game.replaceCards()
        updateRemovedCards(with: game.removedCards)
        removeCardsFromSlots()
        newTableCards = undealtTableCards
        placeCardsOnGrid(from: newTableCards)
    }
    
    /// Places new cards on the grid.
    /// - Parameter cards: The new cards to be placed on the grid.
    private func placeCardsOnGrid(from cards: [Card]) {
        var copy = cards
        fillEmptySlots(with: &copy)
    }
    
    //MARK: -Intents
    /// Manages grid updates and indicates the Model the user's intent of selecting a card.
    func select(_ card: Card) {
        game.select(card: card)
    }
    
    /// Deselects a card when the user taps on a selected card.
    /// - Parameter card: The card to be deselected.
    func deSelect(_ card: Card) {
        game.deSelect(card: card)
    }
    
    /// Handles the dealing of new cards when the user taps on the deck pile.
    func dealCards() {
        switch (tableCards.isEmpty, matchedCards.isEmpty) {
        case (true, _):
            startInitialDeal()
            
        case (false, true):
            dealAdditionalCards()
            
        case (false, false):
            replaceMatchedCards()
        }
    }
  
    /// Shuffles the Model's table cards and synchronises the View's grid to the changes.
    func shuffleCards() {
        grid = grid.shuffled()
    }
    
    // MARK: - Cards Updates
    
    /// Changes the state of a matched of mismatched set accordingly.
    func updatePossibleSet() {
        game.updateSelectionStatuses(cards: selectedCards)
    }
    
    /// Removes the matched set from the table, updates the discard piles and removes the card views from grid's slot.
    func removeCards() {
        game.removeCards()
        updateRemovedCards(with: game.removedCards)
        removeCardsFromSlots()
    }
    
    /// Updates table cards state to deck state and restarts the removed card pile to empty.
    func moveCardsToDeck() {
        game.moveCardsToDeck()
        removedCardIDsInOrder = []
    }
}

//MARK: -Constants
private struct Constants {
    struct Card {
        static let shapeLineWidth: CGFloat = 1
        static let selectionColorOpacity: CGFloat = 0.2
    }

    struct Stripe {
        static let cardsThreshold: Int = 25 // When this table cards' threshold is reached, stripes setting adapt to fit better on screen.
        static let bold: (count: Int, width: CGFloat) = (count: 20, width: 0.5) // Stripes setting for few table cards on screen.
        static let fine: (count: Int, width: CGFloat) = (count: 30, width: 0.2) // Stripes setting for many table cards on screen.
    }
}


