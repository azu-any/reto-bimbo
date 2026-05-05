//
//  ConfirmView.swift
//  Bimbo
//
//  Vista de confirmación del pedido con aprobación dual.
//

import SwiftUI

struct ConfirmView: View {
    let onNext: () -> Void
    @State private var viewModel = ConfirmViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepHeaderView(step: 5, title: "Confirmación", subtitle: "Revisión final del pedido")
                
                ScrollView {
                    VStack(spacing: 24) {
                        orderSummary
                        approvalSection
                    }
                    .padding(24).padding(.bottom, 120)
                }
            }
            
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: viewModel.puedeConfirmar ? "Confirmar Pedido" : "Faltan firmas",
                    variant: viewModel.puedeConfirmar ? .success : .primary,
                    disabled: !viewModel.puedeConfirmar,
                    action: onNext
                )
                .padding(24)
                .background(Color.white.shadow(.drop(color: .black.opacity(0.05), radius: 10, y: -5)))
            }
        }
        .onAppear {
            // Cargar productos mock para el pedido final
            viewModel.cargarProductos([
                Producto(id: 1, nombre: "Pan Bimbo Grande", cantidad: 4, precio: 45.0),
                Producto(id: 2, nombre: "Roles Canela", cantidad: 2, precio: 60.0),
                Producto(id: 3, nombre: "Donas Bimbo", cantidad: 3, precio: 50.0),
                Producto(id: 4, nombre: "Gansito", cantidad: 2, precio: 100.0)
            ])
        }
    }
    
    // MARK: - Resumen del pedido
    private var orderSummary: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "cart.fill").foregroundColor(.bimboNavy)
                    Text("Resumen").fontWeight(.bold)
                }
                Spacer()
                Text("\(viewModel.totalCajas) cajas").font(.subheadline).foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.gray.opacity(0.03))
            
            Divider()
            
            // Productos
            VStack(spacing: 12) {
                ForEach(viewModel.productos) { producto in
                    HStack {
                        HStack(spacing: 8) {
                            Text("\(producto.cantidad)").fontWeight(.bold).foregroundColor(.gray).frame(width: 20)
                            Text(producto.nombre).foregroundColor(.gray.opacity(0.8))
                        }
                        Spacer()
                        Text(String(format: "$%.0f", producto.precio * Double(producto.cantidad))).fontWeight(.medium)
                    }
                    .font(.subheadline)
                }
                
                // Total
                Divider().padding(.vertical, 4)
                HStack {
                    Text("Total a pagar").fontWeight(.bold)
                    Spacer()
                    Text(viewModel.totalFormateado).font(.title2).fontWeight(.bold).foregroundColor(.bimboNavy)
                }
            }
            .padding(16)
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2))
    }
    
    // MARK: - Sección de aprobación
    private var approvalSection: some View {
        VStack(spacing: 16) {
            Text("Aprobación requerida").font(.body).fontWeight(.bold).foregroundColor(.primary)
            
            HStack(spacing: 16) {
                approvalButton(label: "Vendedor", initial: "C", approved: viewModel.aprobadoVendedor) {
                    viewModel.aprobadoVendedor.toggle()
                }
                approvalButton(label: "Doña Lupita", initial: "L", approved: viewModel.aprobadoTendero) {
                    viewModel.aprobadoTendero.toggle()
                }
            }
        }
    }
    
    private func approvalButton(label: String, initial: String, approved: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(approved ? Color.green : Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    if approved {
                        Image(systemName: "checkmark.circle.fill").font(.title2).foregroundColor(.white)
                    } else {
                        Text(initial).font(.title2).fontWeight(.bold).foregroundColor(.gray.opacity(0.4))
                    }
                }
                Text(label).font(.subheadline).fontWeight(.bold)
                    .foregroundColor(approved ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(approved ? Color.green.opacity(0.05) : Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(approved ? Color.green : Color.gray.opacity(0.2), lineWidth: 2))
            )
        }
    }
}

#Preview { ConfirmView(onNext: {}) }
