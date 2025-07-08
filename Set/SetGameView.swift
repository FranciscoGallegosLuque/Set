//
//  SetGameView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

/// A View that show the Set Game.
struct SetGameView: View {
    
    /// The ViewModel var
    @ObservedObject var viewModel: SetGameViewModel
    
    var body: some View {
        VStack {
            title
            score
            availableSetMessage
            gameStateContent
            controlButtons
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var title: some View {
        Text("Set Game")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
    }
    
    var gameEndedMessage: some View {
        VStack {
            Spacer()
            Text("You won!")
                .font(.largeTitle)
            Spacer()
        }
    }
    
    var score: some View {
        Text("Score: \(viewModel.score)")
            .padding()
    }
    
    var availableSetMessage: some View {
        let message: String = viewModel.availableSet ? "Yes" : "No"
        return Text("Available Set? \(message)")
    }
    
    @ViewBuilder
    private var gameStateContent: some View {
        if viewModel.gameEnded {
            gameEndedMessage
        } else {
            cardGrid
        }
    }
    
    /// A stack of buttons to start a new game and deal new cards if requested.
    var controlButtons: some View {
        HStack(spacing: Constants.controlButtonsSpacing) {
            newGameButton
            dealCardsButton
                .disabled(viewModel.deckCards.isEmpty)
        }
        .buttonStyle(.borderedProminent)
    }
    
    /// A button that starts a new game, with random cards.
    var newGameButton: some View {
        Button("New Game") {
            viewModel.startNewGame()
        }
    }
    
    /// A button that deals 3 cards when requested.
    ///
    /// Whenever 3 non-matching cards are selected, deals 3 more cards. If 3 matching cards are selected, replaces the matching cards with 3 new cards.
    var dealCardsButton: some View {
        Button("Deal cards") {
            viewModel.dealCards()
        }
        
    }
    
    var cardGrid: some View {
        AspectVGrid(viewModel.tableCards, aspectRatio: Constants.cardsAspectRatio) { card in
            CardView(viewModel: viewModel, card: card)
                .padding(Constants.cardsSpacing)
                .onTapGesture {
                    viewModel.select(card)
                }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private struct Constants {
        static let cardsSpacing: CGFloat = 4
        static let cardsAspectRatio: CGFloat = 2/3
        static let controlButtonsSpacing: CGFloat = 60
    }
}


#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
