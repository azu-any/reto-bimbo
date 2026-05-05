//
//  UnloadView.swift
//  Bimbo
//
//  Vista de descarga de productos del camión.
//  Muestra un checklist de productos encargados la semana pasada.
//  El vendedor marca cada producto conforme lo baja del camión.
//  Solo puede avanzar cuando todos están marcados.
//

import SwiftUI

/// Pantalla de descarga de productos con checklist interactivo.
struct UnloadView: View {
    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    @State private var viewModel = UnloadViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header con progreso
                StepHeaderView(
                    step: 1,
                    title: "Bajar del camión",
                    subtitle: "Pedido de la semana pasada"
                )
                
                // MARK: - Contenido scrolleable
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Barra de progreso
                        progressSection
                        
                        // Lista de productos
                        productList
                    }
                    .padding(24)
                    .padding(.bottom, 100) // Espacio para el botón fijo
                }
            }
            
            // MARK: - Botón fijo inferior
            VStack {
                Spacer()
                bottomButton
            }
            
            // MARK: - Osito FAB
            VStack {
                Spacer()
                HStack {
                    OsitoFABView(tip: "Asegúrate de llevar el diablito, ¡son varias cajas hoy!")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Sección de progreso
    
    private var progressSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progreso")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.medium)
                Spacer()
                Text("\(viewModel.checkedCount)/\(viewModel.totalCount) cajas")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
            }
            
            // Barra de progreso animada
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bimboNavy)
                        .frame(width: geometry.size.width * viewModel.progreso)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progreso)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Lista de productos
    
    private var productList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.productos.enumerated()), id: \.element.id) { index, producto in
                ProductCheckRow(
                    producto: producto,
                    onToggle: { viewModel.toggleProducto(producto.id) }
                )
                .transition(.asymmetric(
                    insertion: .offset(y: 20).combined(with: .opacity),
                    removal: .opacity
                ))
                .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.1), value: producto.checked)
            }
        }
    }
    
    // MARK: - Botón inferior
    
    private var bottomButton: some View {
        PrimaryButtonView(
            title: viewModel.todosDescargados ? "Listo, todo bajado" : "Selecciona todo para continuar",
            iconName: "chevron.right",
            variant: viewModel.todosDescargados ? .success : .primary,
            disabled: !viewModel.todosDescargados,
            action: onNext
        )
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color(UIColor.systemGray6).opacity(0),
                    Color(UIColor.systemGray6),
                    Color(UIColor.systemGray6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Fila de producto con check

/// Fila individual de producto en el checklist de descarga.
struct ProductCheckRow: View {
    let producto: Producto
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Ícono del producto
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(producto.checked ? Color.green.opacity(0.1) : Color.bimboCream)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "shippingbox.fill")
                        .font(.title3)
                        .foregroundColor(producto.checked ? .green : .bimboNavy)
                }
                
                // Nombre y cantidad
                VStack(alignment: .leading, spacing: 4) {
                    Text(producto.nombre)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(producto.checked ? .gray : .primary)
                        .strikethrough(producto.checked, color: .gray)
                    
                    Text("\(producto.cantidad) cajas")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Indicador de check
                ZStack {
                    Circle()
                        .stroke(producto.checked ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if producto.checked {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(producto.checked ? Color.green.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                producto.checked ? Color.green.opacity(0.2) : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: producto.checked ? .clear : .black.opacity(0.03), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    UnloadView(onNext: {})
}
