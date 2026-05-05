//
//  StepHeaderView.swift
//  Bimbo
//
//  Componente reutilizable de encabezado de paso.
//  Muestra el progreso del flujo con indicadores visuales,
//  el título del paso actual y un subtítulo descriptivo.
//

import SwiftUI

/// Encabezado de cada paso del flujo con indicador de progreso.
struct StepHeaderView: View {
    
    /// Número del paso actual (1-based).
    let step: Int
    
    /// Total de pasos en el flujo.
    var totalSteps: Int = AppStep.totalSteps
    
    /// Título principal del paso.
    let title: String
    
    /// Subtítulo descriptivo (opcional).
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Indicadores de progreso
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < step ? Color.bimboNavy : Color.gray.opacity(0.2))
                        .frame(
                            width: index < step ? 24 : 16,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.3), value: step)
                }
                
                Spacer()
                
                // Ícono de audio
                Image(systemName: "speaker.wave.2.fill")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.4))
            }
            
            // MARK: - Título
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.bimboNavy)
            
            // MARK: - Subtítulo
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        StepHeaderView(
            step: 3,
            title: "Acomodo Estratégico",
            subtitle: "Sugerencias de neuromarketing"
        )
        Spacer()
    }
}
