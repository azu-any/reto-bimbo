//
//  AIRecommendView.swift
//  Bimbo
//
//  Vista de recomendaciones de pedido inteligente con IA.
//

import SwiftUI

struct AIRecommendView: View {
    let onNext: () -> Void
    let tiendaId: Int
    @State private var viewModel = AIRecommendViewModel()
    @State var showListProduct = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepHeaderView(step: 3, title: "Pedido Inteligente", subtitle: "Recomendaciones con IA")
                
                ScrollView {
                    VStack(spacing: 16) {
                        analysisCard
                        recommendationsList
                        
                        addProduct
                    }
                    .padding(24)
                    .padding(.bottom, 100)
                }
            }
            
            VStack {
                Spacer()
                PrimaryButtonView(title: "Revisar con tendero", iconName: "chevron.right", action: onNext)
                    .padding(24)
                    .background(LinearGradient(colors: [Color(UIColor.systemGray6).opacity(0), Color(UIColor.systemGray6)], startPoint: .top, endPoint: .bottom))
            }
        }
        .onAppear { viewModel.cargarRecomendaciones(para: tiendaId) }
    }
    
    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles").foregroundColor(.yellow)
                Text("Análisis de Doña Lupita").fontWeight(.bold)
            }
            
            Text("Basado en el día de la semana y ventas históricas, este es el pedido óptimo.")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Divider().background(Color.white.opacity(0.5))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total sugerido")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(viewModel.totalUnidades) unidades")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))

                }

            }
        }
        .padding(20).foregroundColor(.white)
        .background(
            LinearGradient(
                colors: [Color.bimboNavy, Color.bimboNavy.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
                .clipShape(RoundedRectangle(cornerRadius: 16)
                          )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .bimboNavy.opacity(0.3), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showListProduct) {
            
        }
    }
    
    private var recommendationsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.recomendaciones.enumerated()), id: \.element.id) { index, producto in
                AIRecommendationRow(
                    producto: producto,
                    onCantidadChange: { nuevaCantidad in viewModel.updateCantidad(for: producto.id, cantidad: nuevaCantidad) }
                )
            }
        }
    }
    
    
    private var addProduct: some View {
        PrimaryButtonView(title: "Agregar producto", variant: .outline, action: { showListProduct.toggle() } )
    }
}

struct AIRecommendationRow: View {
    let producto: Producto
    let onCantidadChange: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(producto.nombre).font(.body).fontWeight(.bold)
                    if let razon = producto.razonSugerencia {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right").font(.caption2).foregroundColor(.green)
                            Text(razon).font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                Stepper("",
                        onIncrement: { onCantidadChange(producto.cantidad + 1) },
                        onDecrement: { if producto.cantidad > 0 { onCantidadChange(producto.cantidad - 1) } }
                )
                            }
            if producto.activo {
                HStack {
                    Text("Cantidad").font(.subheadline).foregroundColor(.gray)
                    Spacer()
                    Text("\(producto.cantidad) unidades").font(.subheadline).fontWeight(.bold).foregroundColor(.bimboNavy)
                }
                .padding(8).background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.05)))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).overlay(RoundedRectangle(cornerRadius: 16).stroke(producto.activo ? Color.bimboNavy : Color.clear, lineWidth: 2)).shadow(color: producto.activo ? .black.opacity(0.03) : .clear, radius: 4, x: 0, y: 2))
        .opacity(producto.activo ? 1.0 : 0.6)
    }
}

#Preview { AIRecommendView(onNext: {}, tiendaId: 101) }
