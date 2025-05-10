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
    init(numbers: [Int],
         features1: [String],
         features2: [String],
         features3: [String],
         display amount: Int
    ) {
        cards = []
        
        for number in numbers {
            for feature1 in features1 {
                for feature2 in features2 {
                    for feature3 in features3 {
                        cards.append(Card(number: number, feature1: feature1, feature2: feature2, feature3: feature3))
                    }
                }
            }
        }
        
        let cardsIndexes = Array(0..<cards.count - 1)
        let randomIndexes = Array(cardsIndexes.shuffled().prefix(amount))
        for index in randomIndexes {
            cards[index].status = .table
        }
    }
    
    // MARK: - Computed Properties
    var selectedCards: [Card] {
        cards.filter { $0.isSelected }
    }
    
    var matchedCards: [Card] {
        cards.filter { $0.isMatched }
    }
    
    var misMatchedCards: [Card] {
        cards.filter { $0.isMisMatched }
    }
    
    var deckCards: [Card] {
        cards.filter { $0.status == .deck }
    }
    
    var tableCards: [Card] {
        cards.filter { $0.status == .table }
    }
    
    // MARK: - Public Methods
    mutating func addCards() {
        if doTheySet(cards: selectedCards) {
            removeSet()
        }
        let addedCards = Array(deckCards.shuffled().prefix(3))
        for card in addedCards {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].status = .table
            }
        }
    }
    
    mutating func handleCardSelection(card: Card) {
        if selectedCards.count < 2 {
            toggleSelection(of: card)
        } else if selectedCards.count == 2 {
            toggleSelection(of: card)
            setChecker()
        } else if selectedCards.count == 3 {
                if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
                    
                    //case in which the 3 cards were forming a set
                    if doTheySet(cards: selectedCards) {
                        //only change selection of card if it wasn't part of the set
                        if !cards[selectedIndex].isSelected {
                            toggleSelection(of: card)
                        }
                        removeSet()
                        addCards()
                        
                    //case in which the 3 cards were not forming a set
                    } else {
                        //
                        for misMatchedCard in misMatchedCards {
                            if let index = cards.firstIndex(where: { $0.id == misMatchedCard.id }) {
                                cards[index].isMisMatched.toggle()
                                if !(selectedIndex == index) {
                                    cards[index].isSelected.toggle()
                                }
                            }
                        }
                        if !cards[selectedIndex].isSelected {
                            cards[selectedIndex].isSelected.toggle()
                        }
                    }
                    
                }

        }
        
        
    }
    
    // MARK: - Private Methods
    mutating func removeSet() {
        for matchedCard in matchedCards {
            if let index = cards.firstIndex(where: { $0.id == matchedCard.id }) {
                cards[index].isSelected.toggle()
                cards[index].isMatched.toggle()
                cards[index].status = .hand
            }
        }
    }
    
    func doTheySet(cards: [Card]) -> Bool {
        let features: [Int] = [0,1,2,3]
        var feats: [[String]] = [[], [], [], []]
        
        for card in cards {
            for feature in features {
                switch feature {
                case 0: feats[0].append(String(card.number))
                case 1: feats[1].append(card.feature1)
                case 2: feats[2].append(card.feature2)
                case 3: feats[3].append(card.feature3)
                default: break
                }
            }
        }
        return feats.allSatisfy({ $0.allThreeEqual || $0.allThreeDifferent })
    }
    
    mutating func setChecker() {
        if doTheySet(cards: selectedCards) {
            for card in selectedCards {
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].isMatched.toggle()
                }
            }
        } else {
            for card in selectedCards {
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].isMisMatched.toggle()
                }
            }
        }
    }
    
    
    mutating func toggleSelection(of card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            cards[selectedIndex].isSelected.toggle()
        }
    }
    
    mutating func toggleMatching(of card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            cards[selectedIndex].isMatched.toggle()
        }
    }
    
    mutating func toggleMisMatching(of card: Card) {
        if let selectedIndex = cards.firstIndex(where: { $0.id == card.id }) {
            cards[selectedIndex].isMisMatched.toggle()
        }
    }
    
    // MARK: - Nested Types
    struct Card: Identifiable, Equatable {
        let number: Int
        let feature1: String
        let feature2: String
        let feature3: String
        
        var status: Status = .deck

        var isSelected: Bool = false
        var isMatched: Bool = false
        var isMisMatched: Bool = false
        
        let id: UUID = UUID()
        
        enum Status {
            case deck, table, hand
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
