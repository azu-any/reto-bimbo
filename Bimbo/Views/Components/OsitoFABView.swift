//
//  OsitoFABView.swift
//  Bimbo
//
//  Componente reutilizable del Osito Bimbo como Floating Action Button.
//  Aparece en varias pantallas del flujo mostrando tips contextuales.
//  Al tocar, muestra/oculta una burbuja de texto con consejos.
//

import SwiftUI

/// Botón flotante del Osito Bimbo con burbuja de tip contextual.
/// Reutilizable en cualquier pantalla del flujo.
struct OsitoFABView: View {
    
    /// Texto del tip que muestra el Osito.
    let tip: String
    
    /// Controla si la burbuja de tip está visible.
    @State private var isOpen: Bool = false
    
    /// Animación pulsante del borde rojo.
    @State private var borderOpacity: Double = 0.2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Burbuja de texto (tip)
            if isOpen {
                Text(tip)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .frame(maxWidth: 250, alignment: .leading)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
            }
            
            // MARK: - Botón del Osito
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOpen.toggle()
                }
            }) {
                ZStack {
                    // Imagen del Osito (placeholder: usa un emoji como fallback)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .overlay(
                            Text("🐻")
                                .font(.system(size: 28))
                        )
                    
                    // Borde rojo pulsante
                    Circle()
                        .stroke(Color.bimboRed, lineWidth: 4)
                        .frame(width: 56, height: 56)
                        .opacity(borderOpacity)
                }
            }
            .onAppear {
                // Animación de pulso infinita en el borde
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    borderOpacity = 0.6
                }
            }
        }
        .padding(.leading, 24)
        .padding(.bottom, 24)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                OsitoFABView(tip: "¡Hola! Asegúrate de llevar el diablito, ¡son varias cajas hoy!")
                Spacer()
            }
        }
    }
}
