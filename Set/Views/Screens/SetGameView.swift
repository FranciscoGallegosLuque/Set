//
//  SetGameView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

/// A View that show the Set Game.
struct SetGameView: View {
    
    /// The home screen View view model.
    @ObservedObject var viewModel: SetGameViewModel
    @Namespace private var pilesNamespace
    
    private let dealAnimation: Animation = .easeInOut(duration: 0.6)
    private let dealInterval: TimeInterval = 0.1
    private var deckCards: [Card] { viewModel.deckCards }
    private var removedCards: [Card] { viewModel.removedCards }
    
    var body: some View {
        VStack {
            title
            availableSetMessage
            gameStateContent
            cardsPiles
            controlButtons
        }
        .padding()
        .onAppear {
            for card in viewModel.tableCards {
                visuallyDealt.append(card.id)
            }
        }
    }
    
    /// The game title.
    var title: some View {
        Text("Set Game")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
    }
    
    /// A message shown when user selects all sets and wins.
    var gameEndedMessage: some View {
        VStack {
            Spacer()
            Text("You won!")
                .font(.largeTitle)
            Spacer()
        }
    }
    
    
    /// A message indicating whether there is an available set to be chosen in the table.
    var availableSetMessage: some View {
        Text("Available Set? \(viewModel.availableSet ? "Yes" : "No")")
    }
    
    /// A conditional View that shows whether an end message if the player wins or the card grid.
    @ViewBuilder
    private var gameStateContent: some View {
        if viewModel.gameEnded {
            gameEndedMessage
        } else {
            cardGrid
        }
    }
    
    
    /// A View showing the two piles of cards (deck and discard pile).
    var cardsPiles: some View {
        HStack {
            Spacer()
            discardPile
            Spacer()
            deck
            Spacer()
        }
        .padding()
    }
    
    func randomOffset(for card: Card) -> CGSize {
        let seed = card.id.hashValue
        let x = Double(seed % 1000) / 1000.0 - 0.5
        let y = Double((seed / 1000) % 1000) / 1000.0 - 0.5
        return CGSize(width: x * 1, height: y * 1)
    }
    
    /// A pile with the already matched cards.
    var discardPile: some View {
        ZStack {
            ForEach(removedCards) { card in
                CardView(viewModel: viewModel, card: card)
                    .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .offset(randomOffset(for: card))
            }
        }
        .frame(
            width: Constants.deckWidth,
            height: Constants.deckWidth / Constants.aspectRatio
        )
    }
    
    
    /// A pile with the deck of cards.
    var deck: some View {
        ZStack {
            ForEach(deckCards.reversed()) { card in
                CardView(viewModel: viewModel, card: card)
                    .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .offset(randomOffset(for: card))
            }
        }
        .frame(
            width: Constants.deckWidth,
            height: Constants.deckWidth / Constants.aspectRatio
        )
        .onTapGesture {
            dealCards()
        }
    }
    
    @State private var visuallyDealt = [Card.ID]()
    
    private func isDealt(_ card: Card) -> Bool {
        visuallyDealt.contains(card.id)
    }
    
    private var undealtCards: [Card] {
        viewModel.cards.filter { !isDealt($0) }
    }
    
    func dealCards() {
            withAnimation {
                viewModel.dealCards()
            }
            let newCards = viewModel.newTableCards
            var delay: TimeInterval = 0
            for index in newCards.indices {
                withAnimation(dealAnimation.delay(delay)) {
                    visuallyDealt.append(newCards[index].id)
                }
                delay += dealInterval
            }
        }

    
    func selectCard(_ card: Card) {
        if viewModel.matchedCards.isEmpty {
            viewModel.select(card)
        } else {
            withAnimation {
                viewModel.select(card)
            }
        }
    }
    
    /// A stack of buttons to start a new game and deal new cards if requested.
    var controlButtons: some View {
        HStack(spacing: Constants.controlButtonsSpacing) {
            newGameButton
            shuffleButton
//                .disabled(viewModel.deckCards.isEmpty)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    /// A button that starts a new game, with random cards.
    var newGameButton: some View {
        Button("New Game") {
            viewModel.startNewGame()
            for card in viewModel.tableCards {
                visuallyDealt.append(card.id)
            }
        }
        
    }
    
    /// A button that deals 3 cards when requested.
    ///
    /// Whenever 3 non-matching cards are selected, deals 3 more cards.
    /// If 3 matching cards are selected, replaces the matching cards with 3 new cards.
    var shuffleButton: some View {
        Button("Shuffle") {
            withAnimation {
                viewModel.shuffleCards()
            }
        }
    }
    
    func computeZIndex(_ card: Card) -> Double {
        visuallyDealt.suffix(3).contains(card.id) ? 1 : 0
    }
    
    /// A grid of set cards.
    var cardGrid: some View {
        AspectVGrid(viewModel.grid, aspectRatio: Constants.cardsAspectRatio) { slot in
            if let cardID = slot.cardID {
                if let card = viewModel.cards.first(where: { $0.id == cardID }) {
                    if isDealt(card) {
                        let zIndex = computeZIndex(card)
                        CardView(viewModel: viewModel, card: card)
                            .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                            .padding(Constants.cardsSpacing)
                            .onTapGesture {
                                selectCard(card)
                            }
                            .zIndex(zIndex)
                    } else { Color.clear }
                }
            } else { Color.clear }
        }
    }
    
    
    
    private struct Constants {
        static let cardsSpacing: CGFloat = 4
        static let cardsAspectRatio: CGFloat = 2/3
        static let controlButtonsSpacing: CGFloat = 60
        static let deckWidth: CGFloat = 50
        static let aspectRatio: CGFloat = 2/3
    }
}

#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
