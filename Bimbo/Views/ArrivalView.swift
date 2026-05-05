//
//  ArrivalView.swift
//  Bimbo
//
//  Vista de llegada a la tienda.
//  El Osito Bimbo saluda al vendedor con una animación flotante,
//  muestra un mensaje de bienvenida en burbuja de texto,
//  y simula la reproducción de audio con barras de onda.
//

// ArrivalViewIA.swift
import SwiftUI

struct ArrivalViewIA: View {
    let agent: OsitoAgent
    let tienda: Tienda
    @State private var messageOffset: CGFloat = 20
    @State private var messageOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.bimboCream.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Osito animado (igual que antes)
                ositoSection
                    .padding(.bottom, 48)
                
                // Bocadillo dinámico con el mensaje del agente
                burbujaIA
                    .padding(.horizontal, 24)
                    .offset(y: messageOffset)
                    .opacity(messageOpacity)
                
                Spacer()
                
                PrimaryButtonView(title: "¡Vámonos!", iconName: "chevron.right") {
                    Task { await agent.avanzarA(.descarga) }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                messageOffset = 0; messageOpacity = 1
            }
        }
    }
    
    private var ositoSection: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(Color.white).frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
                Text("🐻").font(.system(size: 80))
                    .scaleEffect(agent.voice.hablando ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: agent.voice.hablando)
            }
            .modifier(FloatingModifier())
            
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    AudioWaveBar(delay: Double(i) * 0.1)
                }
            }
            .padding(.top, 16)
            .opacity(agent.voice.hablando ? 1 : 0.3)
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
