//
//  RecomendacionIAView.swift
//  Bimbo
//
//  Vista temporal (Dummy) para que compile el proyecto.
//

import SwiftUI

struct RecomendacionIAView: View {
    let agent: OsitoAgent
    
    // 1. Arreglo falso para que ya no te marque error el agent.recomendaciones
    let mockRecomendaciones = ["10x Pan Blanco Bimbo", "5x Nito", "3x Mantecadas"]

    var body: some View {
        // 2. Quitamos StepShellView y ponemos un ZStack genérico
        ZStack {
            // Fondo azul para que no se vea feo
            Color.blue.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header icon
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow) // Cambiado a amarillo estándar por si falla .bimboYellow

                Text("Pedido Inteligente (Placeholder)")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Esta es una vista temporal.\nAquí tu compañera pondrá su modelo de IA.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // 3. Usamos la lista de relleno
                VStack(spacing: 12) {
                    ForEach(mockRecomendaciones, id: \.self) { rec in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.yellow)
                            Text(rec)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                Spacer()

                Button {
                    // Mantenemos la acción de avanzar para que el flujo de la app no se rompa
                    Task { await agent.avanzarA(.confirmacion) }
                } label: {
                    Label("Confirmar pedido", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
    }
}
