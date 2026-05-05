//
//  SplashView.swift
//  Bimbo
//
//  Vista de inicio (splash) que se muestra al abrir la app.
//  Saluda al vendedor, muestra la ruta activa y transiciona
//  automáticamente al mapa después de 2.5 segundos.
//

// SplashView.swift
import SwiftUI

struct SplashView: View {
    let onContinuar: () -> Void
    @State private var ositoVisible = false
    @State private var textoVisible = false
    @State private var botonVisible = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.bimboNavy, Color.bimboNavy.opacity(0.85)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decoración de fondo
            Circle()
                .fill(Color.bimboRed.opacity(0.15))
                .frame(width: 300, height: 300)
                .offset(x: 120, y: -180)
            Circle()
                .fill(Color.bimboYellow.opacity(0.10))
                .frame(width: 200, height: 200)
                .offset(x: -100, y: 200)

            VStack(spacing: 36) {
                Spacer()

                // Osito animado
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                    Text("🐻")
                        .font(.system(size: 90))
                        .modifier(FloatingModifier())
                }
                .scaleEffect(ositoVisible ? 1 : 0.3)
                .opacity(ositoVisible ? 1 : 0)

                // Marca
                VStack(spacing: 8) {
                    Text("Osito Bimbo")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Tu asistente inteligente en ruta")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                }
                .opacity(textoVisible ? 1 : 0)
                .offset(y: textoVisible ? 0 : 16)

                Spacer()

                if botonVisible {
                    PrimaryButtonView(
                        title: "Iniciar ruta",
                        iconName: "arrow.right",
                        action: onContinuar
                    )
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 32)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7).delay(0.2))  { ositoVisible = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) { textoVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(1.4)) { botonVisible = true }
        }
    }
}
