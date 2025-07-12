//
//  Cardify.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 23/05/2025.
//

import SwiftUI

/// A view modifier that returns a "card" version of the contents passed in.
struct Cardify: ViewModifier {
    var selectionColor: Color
    var isFaceUp: Bool
   
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let cornerRadius = min(width, height) * Constants.cornerRadius
                let lineWidth = min(width, height) * Constants.lineWidth
                let base: RoundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
                base.strokeBorder(lineWidth: lineWidth)
                    .background(base.fill(selectionColor))
                    .overlay(content)
                    .opacity(isFaceUp ? 1 : 0)
                base.fill(Constants.backColor)
                    .opacity(isFaceUp ? 0 : 1)
                
            }
        }
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 0.1
        static let lineWidth: CGFloat = 0.02
        static let backColor = Color(red: 208/255, green: 188/255, blue: 238/255, opacity: 1.0)
   }
}

extension View {
    func cardify(selectionColor: Color, isFaceUp: Bool) -> some View {
        return self.modifier(Cardify(selectionColor: selectionColor, isFaceUp: isFaceUp))
    }
}
