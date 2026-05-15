//
//  WaterWaveShape.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import SwiftUI

struct WaterWaveShape: Shape {
    
    var progress: Double
    var waveHeight: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let waterLevel = rect.height * (1 - progress)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: waterLevel))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / rect.width
            
            let sine = sin(relativeX * .pi * 2 + phase)
            
            let y = waterLevel + sine * waveHeight
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}
