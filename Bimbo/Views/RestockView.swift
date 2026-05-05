//
//  RestockView.swift
//  Bimbo
//
//  Vista de sugerencias de acomodo estratégico con neuromarketing.
//  Muestra un diagrama de "zonas calientes" y tarjetas de sugerencias
//  con la razón basada en psicología del consumidor.
//

import SwiftUI

/// Pantalla de sugerencias de neuromarketing para acomodo de productos.
struct RestockView: View {
    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    @State private var viewModel = RestockViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                StepHeaderView(
                    step: 9,
                    title: "Acomodo Estratégico",
                    subtitle: "Sugerencias de neuromarketing"
                )
                
                // MARK: - Contenido
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Diagrama de zonas calientes
                        hotZonesDiagram
                        
                        // Título de sugerencias
                        Text("Sugerencias para Doña Lupita")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)
                        
                        // Scroll horizontal de tarjetas
                        suggestionsCarousel
                    }
                    .padding(24)
                    .padding(.bottom, 100)
                }
            }
            
            // MARK: - Botón inferior
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: "Entendido",
                    iconName: "chevron.right",
                    action: onNext
                )
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemGray6).opacity(0),
                            Color(UIColor.systemGray6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    // MARK: - Diagrama de zonas calientes
    
    private var hotZonesDiagram: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zonas Calientes")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                // Zona baja
                zoneBox(label: "Bajo", isHot: false)
                
                // Zona nivel de ojos (caliente)
                zoneBox(label: "Nivel de ojos", isHot: true)
                
                // Zona alta
                zoneBox(label: "Alto", isHot: false)
            }
            .frame(height: 96)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
    }
    
    /// Caja de zona en el diagrama.
    private func zoneBox(label: String, isHot: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isHot ? Color.red.opacity(0.05) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isHot ? Color.bimboRed : Color.gray.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: isHot ? [] : [6, 4])
                        )
                )
            
            Text(label)
                .font(.caption)
                .fontWeight(isHot ? .bold : .regular)
                .foregroundColor(isHot ? .bimboRed : .gray)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Carrusel de sugerencias
    
    private var suggestionsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(viewModel.sugerencias.enumerated()), id: \.element.id) { index, producto in
                    SuggestionCard(
                        producto: producto,
                        onDecrease: { viewModel.ajustarCantidad(producto.id, incremento: -1) },
                        onIncrease: { viewModel.ajustarCantidad(producto.id, incremento: 1) }
                    )
                    .frame(width: 260)
                }
            }
        }
    }
}

// MARK: - Tarjeta de sugerencia

/// Tarjeta individual de sugerencia de neuromarketing.
struct SuggestionCard: View {
    let producto: Producto
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Ícono del producto
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bimboCream)
                    .frame(width: 48, height: 48)
                
                Text(String(producto.nombre.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
            }
            
            // Nombre
            Text(producto.nombre)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Razón de sugerencia
            if let razon = producto.razonSugerencia {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.bimboNavy)
                    
                    Text(razon)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.bimboNavy)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.05))
                )
            }
            
            // Control de cantidad
            HStack {
                Text("Sugerido")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onDecrease) {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("−")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    Text("\(producto.cantidad)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Button(action: onIncrease) {
                        Circle()
                            .fill(Color.bimboNavy)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("+")
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .padding(.top, 8)
            .overlay(alignment: .top) {
                Divider()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    RestockView(onNext: {})
}
