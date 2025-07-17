//
//  CardBackView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 14/07/2025.
//

import SwiftUI

/// Returns a View of the back of a Set card.
struct CardBackView: View {
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let cornerRadius = min(width, height) * Constants.cornerRadius
                let lineWidth = min(width, height) * Constants.lineWidth
                let base: RoundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
                base.strokeBorder(Constants.borderColor, lineWidth: lineWidth)
                    .background(base.fill(Constants.backColor))
                    .overlay(setImage)
            }
        }
    }
    
    /// The Set game logo shown in the back of the card.
    var setImage: some View {
        Image("LaunchLogo")
            .resizable()
            .scaledToFit()
            .rotationEffect(Constants.rotation)
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 0.1
        static let lineWidth: CGFloat = 0.008
        static let backColor = Color(red: 208/255, green: 188/255, blue: 238/255, opacity: 1.0)
        static let borderColor = Color.gray
        static let rotation = Angle.degrees(90)
        struct FontSize {
            static let largest: CGFloat = 200
            static let smallest: CGFloat = 10
            static let scaleFactor = smallest / largest
        }
   }
}

#Preview {
    CardBackView()
}
