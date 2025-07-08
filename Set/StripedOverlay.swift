//
//  StripedOverlay.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 08/07/2025.
//

import SwiftUI

struct StripedOverlay: View {
    let numberOfLines: Int
    let stripeWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let scale = UIScreen.main.scale
            let totalWidth = geometry.size.width
            let spacing = totalWidth / CGFloat(numberOfLines - 1)
            ZStack {
                ForEach(0..<numberOfLines, id: \.self) { index in
                    let rawX = spacing * CGFloat(index)
                    let pixelAlignedX = (rawX * scale).rounded() / scale
                    Rectangle()
                        .frame(width: stripeWidth)
                        .offset(x: pixelAlignedX)
                }
            }
        }
        
    }
}

#Preview {
    StripedOverlay(numberOfLines: 10, stripeWidth: 1)
}
