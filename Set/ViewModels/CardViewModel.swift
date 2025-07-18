//
//  CardViewModel.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 18/07/2025.
//

import Foundation
import SwiftUI

class CardViewModel: ObservableObject {
    // MARK: - Properties
    let tableCards: Int
    
    init(tableCards: Int) {
        self.tableCards = tableCards
    }
    
    // MARK: - Public Methods
    /// Defines the UI Color for a given card content and borders.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: The UI Color associated with the "color" feature of the card.
    func color(for card: Card) -> Color {
        let cardColor = card.cardFeatures["color"]
        switch cardColor {
        case "purple": return .purple
        case "red": return .red
        case "green": return .green
        default: return .black
        }
    }
    
    /// Defines the UI Color used to show selection status for card.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: The UI Color associated with the selection status of the card.
    func selectionColor(for card: Card) -> Color {
        switch card.selectionStatus {
        case .matched: return .green.opacity(Constants.Card.selectionColorOpacity)
        case .misMatched: return .red.opacity(Constants.Card.selectionColorOpacity)
        case .selected: return .teal.opacity(Constants.Card.selectionColorOpacity)
        case .notSelected: return Color(UIColor.systemBackground)
        }
    }
    
    /// Defines the symbol View used as shape in the card.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: A View of the corresponding shape (diamond, squiggle or pill) with shading and color.
    @ViewBuilder
    func symbolView(for card: Card) -> some View {
        if let cardShape = card.cardFeatures["shape"], let cardShading = card.cardFeatures["shading"] {
            switch cardShape {
            case "diamond": applyShading(to: Diamond(), shading: cardShading)
            case "squiggle": applyShading(to: Squiggle(), shading: cardShading)
            case "capsule": applyShading(to: Capsule(), shading: cardShading)
            default: Text("Error")
            }
        }
    }
    
    //MARK: -Private Methods
    /// Returns a given shaded version of a given shape.
    /// - Parameters:
    ///   - shape: The shape View to be shaded (diamond, squiggle or pill).
    ///   - shading: The shading to be applied to the shape.
    /// - Returns: A View of a shaded version of the given shape.
    @ViewBuilder
    private func applyShading(to shape: some Shape, shading: String) -> some View {
        switch shading {
        case "solid": shape
        case "striped": makeStriped(shape)
        case "empty": shape.stroke(lineWidth: Constants.Card.shapeLineWidth)
        default: shape
        }
    }
    
    /// Returns a striped version of a given shape.
    /// - Parameter shape: The shape View to be shaded (diamond, squiggle or pill).
    /// - Returns: A View of a striped version of the given shape.
    private func makeStriped(_ shape: some Shape) -> some View {
        ZStack {
            let stripes = stripeSettings()
            StripedOverlay(
                numberOfLines: stripes.count,
                stripeWidth: stripes.width)
                    .clipShape(shape)
            shape
                .stroke(lineWidth: Constants.Card.shapeLineWidth)
        }
    }
    
    /// Returns the amount and width of stripes of a striped shape
    /// based on the actual amount of cards on the table.
    private func stripeSettings() -> (count: Int, width: CGFloat){
        if tableCards < Constants.Stripe.cardsThreshold {
            return Constants.Stripe.bold
        } else {
            let scale = UIScreen.main.scale
            return (Constants.Stripe.bold.count,
                    max(Constants.Stripe.bold.width, 1 / scale)
            )
        }
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
