//
//  ArrivalView.swift
//  Bimbo
//
//  Vista de llegada a la tienda.
//  El Osito Bimbo saluda al vendedor con una animación flotante,
//  muestra un mensaje de bienvenida en burbuja de texto,
//  y simula la reproducción de audio con barras de onda.
//

import SwiftUI

/// Pantalla de bienvenida al llegar a la tienda con el asistente Osito.
struct ArrivalView: View {
    
    let agent: OsitoAgent
    let tienda: Tienda

    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    /// Nombre de la tienda para personalizar el saludo.
    let nombreTienda: String

    // MARK: - Estado de animaciones
    @State private var messageOffset: CGFloat = 20
    @State private var messageOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.bimboNavy.opacity(0.1).ignoresSafeArea()
                .overlay(
                    Image("BimboFondoAzul")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.9)
                        .clipped()
                    )
            
            VStack(spacing: 0) {
                Spacer()
                
                // MARK: - Osito Bimbo con animación
                ositoSection
                    .padding(.bottom, 48)
                
                // MARK: - Burbuja de mensaje dinámica IA
                burbujaIA
                    .padding(.horizontal, 24)
//                    .offset(y: messageOffset)
                    .opacity(messageOpacity)
                
                Spacer()
                
                // MARK: - Botón para continuar
                PrimaryButtonView(
                    title: "¡Vámonos!",
                    iconName: "chevron.right",
                    action: { 
                        Task { await agent.avanzarA(.descarga) }
                        onNext()
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                messageOffset = 0
                messageOpacity = 1.0
            }
            // Solo aquí hablamos automáticamente (pantalla de bienvenida al tendero)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if !agent.ultimoMensajeOsito.isEmpty {
                    agent.voice.hablar(agent.ultimoMensajeOsito)
                }
            }
        }
    }
    
    // MARK: - Sección del Osito con ondas de audio
    
    private var ositoSection: some View {
        VStack(spacing: 0) {
            // Avatar del Osito
            ZStack {
                Image("OsitoBimbo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)


            }
            .modifier(FloatingModifier())
            
            // Barras de onda de audio simuladas
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { index in
                    AudioWaveBar(delay: Double(index) * 0.1)
                }
            }
            .padding(.top, 16)
            .opacity(agent.voice.hablando ? 1 : 0.3)
        }
    }
    
    // MARK: - Burbuja de mensaje del Osito
    
    private var messageBubble: some View {
        VStack(spacing: 0) {
            // Triángulo de la burbuja (apunta hacia arriba)
            Triangle()
                .fill(Color.white)
                .frame(width: 24, height: 16)
                .rotationEffect(.degrees(180))
            
            // Contenido del mensaje
            VStack(spacing: 4) {
                Text("¡Hola Carlos! Llegamos a ")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(nombreTienda)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
                
                Text("")
                    .font(.caption)
                
                Text("Vamos a empezar bajando el pedido de la semana pasada.")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .multilineTextAlignment(.center)
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    private var burbujaIA: some View {
        VStack(spacing: 0) {
            Triangle().fill(Color.white).frame(width: 24, height: 16).rotationEffect(.degrees(180))
            VStack(spacing: 8) {
                Text(agent.ultimoMensajeOsito.isEmpty
                     ? "¡Hola Carlos! Llegamos a \(tienda.nombre) 🐻"
                     : agent.ultimoMensajeOsito)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white).shadow(color: .black.opacity(0.1), radius: 8, y: 4))
        }
    }
}

// MARK: - Barra de onda de audio animada

/// Barra individual que simula una onda de audio.
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

// MARK: - Preview

//#Preview {
//    ArrivalView(
//        onNext: {},
//        nombreTienda: "Doña Lupita"
//    )
//}
