//
//  SuccessView.swift
//  Bimbo
//
//  Vista de éxito al completar la visita a una tienda.
//  Muestra confeti, resumen de la visita e indica la siguiente parada.
//

import SwiftUI

struct SuccessView: View {
    let onNext: () -> Void
    let siguienteTienda: String
    
    @State private var checkScale: CGFloat = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var statsOffset: CGFloat = 20
    @State private var statsOpacity: Double = 0
    @State private var bottomOffset: CGFloat = 20
    @State private var bottomOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.bimboNavy.ignoresSafeArea()
            
            // Confeti simulado
            ConfettiView()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle().fill(Color.white).frame(width: 96, height: 96)
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundColor(.green)
                }
                .scaleEffect(checkScale)
                .padding(.bottom, 32)
                
                // Título
                Text("¡Visita completada!").font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                    .offset(y: titleOffset).opacity(titleOpacity).padding(.bottom, 8)
                
                Text("Doña Lupita quedó surtida").foregroundColor(.blue.opacity(0.6))
                    .offset(y: titleOffset).opacity(titleOpacity).padding(.bottom, 48)
                
                // Stats
                VStack(spacing: 16) {
                    HStack {
                        Text("Cajas entregadas").foregroundColor(.blue.opacity(0.5))
                        Spacer()
                        Text("11").font(.title2).fontWeight(.bold)
                    }
                    Divider().background(Color.white.opacity(0.2))
                    HStack {
                        Text("Venta total").foregroundColor(.blue.opacity(0.5))
                        Spacer()
                        Text("$1,240").font(.title2).fontWeight(.bold).foregroundColor(.green.opacity(0.9))
                    }
                }
                .foregroundColor(.white)
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1)))
                .padding(.horizontal, 24)
                .offset(y: statsOffset).opacity(statsOpacity)
                
                Spacer()
                
                // Siguiente parada
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Text("Próxima parada:").font(.subheadline).foregroundColor(.blue.opacity(0.5))
                        Image(systemName: "mappin.and.ellipse").font(.caption).foregroundColor(.blue.opacity(0.5))
                        Text(siguienteTienda).font(.subheadline).foregroundColor(.blue.opacity(0.5))
                    }
                    
                    Button(action: onNext) {
                        Text("Ir al mapa")
                            .fontWeight(.semibold).foregroundColor(.bimboNavy)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    }
                }
                .padding(24)
                .offset(y: bottomOffset).opacity(bottomOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) { checkScale = 1.0 }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) { titleOffset = 0; titleOpacity = 1.0 }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) { statsOffset = 0; statsOpacity = 1.0 }
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) { bottomOffset = 0; bottomOpacity = 1.0 }
        }
    }
}

/// Vista de confeti animado.
struct ConfettiView: View {
    let colors: [Color] = [.bimboNavy.opacity(0.8), .bimboRed, .green, .yellow]
    
    var body: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                ConfettiPiece(color: colors[i % colors.count], delay: Double.random(in: 0...0.5))
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    @State private var y: CGFloat = -20
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 12, height: 12)
            .offset(x: CGFloat.random(in: -150...150), y: y)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0).delay(delay)) {
                    y = UIScreen.main.bounds.height
                    opacity = 0
                    rotation = 360
                }
            }
    }
}

#Preview { SuccessView(onNext: {}, siguienteTienda: "Abarrotes El Sol") }
