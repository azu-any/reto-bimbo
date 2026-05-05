//
//  SplashView.swift
//  Bimbo
//
//  Vista de inicio (splash) que se muestra al abrir la app.
//  Saluda al vendedor, muestra la ruta activa y transiciona
//  automáticamente al mapa después de 2.5 segundos.
//

import SwiftUI

/// Pantalla de bienvenida con animaciones de entrada.
struct SplashView: View {
    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    // MARK: - Estado de animaciones
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var spinnerOpacity: Double = 0
    @State private var isSpinning: Bool = false
    
    var body: some View {
        ZStack {
//            Color.white.ignoresSafeArea()
            Color.bimboNavy.ignoresSafeArea()
//            LinearGradient(colors: [.blueish, .blueish,.blueish, .blueish.opacity(0.6), .white], startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Spacer()
                
                // MARK: - Logo de Bimbo
                Image("BimboIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .padding(.bottom, 38)
                
                // MARK: - Saludo al vendedor
                VStack(spacing: 24) {
                    Text("¡Hola, Carlos!")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
//                        .foregroundColor(.bimboNavy)
                    
                    // Badge de ruta activa
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .modifier(PulseModifier())
                        
                        Text("Ruta #4521")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
//                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.bimboGray.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.bimboGray, lineWidth: 1)
                            )
                    )
                    .padding()
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
                
                
                // MARK: - Spinner de carga
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.white.opacity(0.8), lineWidth: 4)
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .opacity(spinnerOpacity)
                    .padding(.bottom, 48)
                    .padding(.top)
                
//                Spacer()
                
                HStack{
                    Image("OsitoBimboLado")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Animación del logo
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // Animación del texto
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                textOffset = 0
                textOpacity = 1.0
            }
            
            // Animación del spinner
            withAnimation(.easeIn(duration: 0.3).delay(1.5)) {
                spinnerOpacity = 1.0
            }
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false).delay(1.5)) {
                isSpinning = true
            }
            
            // Transición automática al mapa
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onNext()
            }
        }
    }
}

// MARK: - Modificador de pulso para el indicador verde

/// Animación de pulso infinita para el indicador de ruta activa.
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

// MARK: - Preview

#Preview {
    SplashView(onNext: {})
}
