//
//  ExpiringView.swift
//  Bimbo
//
//  Vista de revisión de productos próximos a caducar.
//  Muestra productos con su fecha de caducidad y acción sugerida.
//  Los productos gestionados desaparecen con animación.
//

import SwiftUI

/// Pantalla de gestión de productos por caducar en el anaquel.
struct ExpiringView: View {
    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    @State private var viewModel = ExpiringViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                StepHeaderView(
                    step: 2,
                    title: "Revisión de anaquel",
                    subtitle: "Productos por caducar"
                )
                
                // MARK: - Contenido
                ScrollView {
                    VStack(spacing: 16) {
                        // Alerta de productos pendientes
                        alertBanner
                        
                        // Lista de productos o estado completado
                        if viewModel.todosGestionados {
                            completedState
                        } else {
                            productCards
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 100)
                }
            }
            
            // MARK: - Botón inferior
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: "Continuar",
                    iconName: "chevron.right",
                    disabled: !viewModel.todosGestionados,
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
            
            // MARK: - Osito FAB
            VStack {
                Spacer()
                HStack {
                    OsitoFABView(tip: "Recuerda aplicar la regla PEPS: Primeras Entradas, Primeras Salidas.")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Banner de alerta
    
    private var alertBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.body)
            
            Text("Hay ")
                .font(.subheadline)
                .foregroundColor(.orange.opacity(0.9)) +
            Text("\(viewModel.pendientes) productos")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.orange.opacity(0.9)) +
            Text(" que requieren atención en el anaquel.")
                .font(.subheadline)
                .foregroundColor(.orange.opacity(0.9))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Tarjetas de productos por caducar
    
    private var productCards: some View {
        ForEach(viewModel.productos.filter { !$0.gestionado }) { producto in
            ExpiringProductCard(
                producto: producto,
                onAction: { viewModel.gestionarProducto(producto.id) }
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.95).combined(with: .opacity),
                removal: .offset(x: -100).combined(with: .opacity)
            ))
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.productos.map(\.gestionado))
    }
    
    // MARK: - Estado completado
    
    private var completedState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
            }
            
            Text("¡Anaquel limpio!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Todo en orden para acomodar lo nuevo.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 48)
        .transition(.opacity)
    }
}

// MARK: - Tarjeta de producto por caducar

/// Tarjeta individual de producto con badge de caducidad y botón de acción.
struct ExpiringProductCard: View {
    let producto: Producto
    let onAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Nombre y badge de caducidad
            VStack(alignment: .leading, spacing: 8) {
                Text(producto.nombre)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Badge de días para caducar
                if let dias = producto.diasParaCaducar {
                    Text("Caduca en \(dias) días")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(dias <= 2 ? Color.red.opacity(0.1) : Color.yellow.opacity(0.1))
                        )
                        .foregroundColor(dias <= 2 ? .red : .yellow.opacity(0.8))
                }
            }
            
            // Botón de acción
            if let accion = producto.accionCaducidad {
                Button(action: onAction) {
                    HStack(spacing: 8) {
                        Image(systemName: accion == "Retirar" ? "trash.fill" : "tag.fill")
                            .font(.subheadline)
                        Text(accion)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                accion == "Retirar"
                                    ? Color.red.opacity(0.05)
                                    : Color.bimboNavy
                            )
                    )
                    .foregroundColor(accion == "Retirar" ? .red : .white)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    ExpiringView(onNext: {})
}
