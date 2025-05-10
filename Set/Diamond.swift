//
//  Diamond.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 10/05/2025.
//

import SwiftUI


struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        let verticalOffset: CGFloat = rect.height * 0.2
        let start = CGPoint(x: rect.midX, y: rect.minY)
        
        var p = Path()
        
        p.move(to: start)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    Diamond()
}
