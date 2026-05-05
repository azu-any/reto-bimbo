//
//  SharedComponents.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import SwiftUI

// MARK: - Triangle (forma para bocadillos y pins)

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - FloatingModifier (animación de flotación vertical)

struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -10 : 10)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

// MARK: - PingModifier (animación de expansión tipo radar)

struct PingModifier: ViewModifier {
    @State private var isPinging = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPinging ? 2.0 : 1.0)
            .opacity(isPinging ? 0.0 : 0.5)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isPinging = true
                }
            }
    }
}

// MARK: - AudioWaveBar (barra animada de onda de audio)

struct AudioWaveBar: View {
    let delay: Double
    @State private var animating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.bimboRed)
            .frame(width: 6, height: animating ? 24 : 8)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    animating = true
                }
            }
    }
}

// MARK: - GridPattern (cuadrícula para fondos tipo mapa)

struct GridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 40
                let width = geometry.size.width
                let height = geometry.size.height
                
                var x: CGFloat = 0
                while x <= width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                    x += spacing
                }
                
                var y: CGFloat = 0
                while y <= height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.bimboNavy, lineWidth: 0.5)
        }
    }
}
