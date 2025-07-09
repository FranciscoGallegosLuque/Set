//
//  Squiggle.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 07/07/2025.
//

import SwiftUI

/// A View of a squiggle shape with scaling capacities.
struct Squiggle: Shape {
    
    func path(in rect: CGRect) -> Path {
        let originalWidth: CGFloat = 138
        let originalHeight: CGFloat = 75
        
        let scaleX = rect.width / originalWidth
        let scaleY = rect.height / originalHeight
        
        let scale = min(scaleX, scaleY)
        
        let xOffset = (rect.width - originalWidth * scale) / 2
        let yOffset = (rect.height - originalHeight * scale) / 2
        
        func scaled(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * scale + xOffset, y: y * scale + yOffset)
        }
        
        var path = Path()
        path.move(to: scaled(28.4423, 5.27897))
        path.addCurve(to: scaled(11.4423, 71.279),
                      control1: scaled(-8.55767, 19.279),
                      control2: scaled(-1.55716, 63.779))
        path.addCurve(to: scaled(30.9423, 61.779),
                      control1: scaled(17.4424, 74.279),
                      control2: scaled(30.9423, 61.779))
        path.addCurve(to: scaled(50.9424, 58.279),
                      control1: scaled(32.9423, 60.1123),
                      control2: scaled(39.7424, 57.079))
        path.addCurve(to: scaled(84.4424, 65.779),
                      control1: scaled(64.9424, 59.779),
                      control2: scaled(76.4424, 65.779))
        path.addCurve(to: scaled(124.942, 52.279),
                      control1: scaled(92.4424, 65.779),
                      control2: scaled(109.442, 67.279))
        path.addCurve(to: scaled(126.942, 1.77897),
                      control1: scaled(133.942, 44.779),
                      control2: scaled(146.442, 11.779))
        path.addCurve(to: scaled(111.442, 6.27897),
                      control1: scaled(123.942, 0.612307),
                      control2: scaled(116.642, -0.121026))
        path.addCurve(to: scaled(92.9424, 17.279),
                      control1: scaled(107.942, 10.1123),
                      control2: scaled(99.3196, 16.6077))
        path.addCurve(to: scaled(61.4424, 10.279),
                      control1: scaled(83.4424, 18.279),
                      control2: scaled(67.4424, 12.779))
        path.addCurve(to: scaled(28.4423, 5.27896),
                      control1: scaled(56.109, 7.77897),
                      control2: scaled(40.9424, 1.77896))
        path.closeSubpath()
        return path
    }
}


#Preview {
    Squiggle()
}
