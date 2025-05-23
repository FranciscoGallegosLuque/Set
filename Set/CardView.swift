//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 06/05/2025.
//

import SwiftUI

struct CardView: View {
    private(set) var viewModel: SetGameViewModel
    let card: SetGame.Card

    var body: some View {
        cardContents
            .cardify(selectionColor: viewModel.cardBackgroundColor(for: card))
            .foregroundStyle(viewModel.color(for: card))
    }
    
    var cardContents: some View {
        VStack {
            ForEach(0..<card.number, id: \.self) { _ in
                viewModel.shape(for: card)
            }
        }
            .minimumScaleFactor(Constants.FontSize.scaleFactor)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 2
        static let inset: CGFloat = 5
        struct FontSize {
            static let largest: CGFloat = 200
            static let smallest: CGFloat = 10
            static let scaleFactor = smallest / largest
        }
    }
}

#Preview {
    CardView(viewModel: SetGameViewModel(),
             card: SetGame.Card(
                number: 2,
                feature1: "red",
                feature2: "diamond",
                feature3: "striped"
        )
    )
}
