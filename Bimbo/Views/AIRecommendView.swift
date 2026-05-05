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
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepHeaderView(step: 4, title: "Pedido Inteligente", subtitle: "Recomendaciones con IA")
                
                ScrollView {
                    VStack(spacing: 16) {
                        analysisCard
                        recommendationsList
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
            
            VStack { Spacer(); HStack { OsitoFABView(tip: "La IA tiene un 94% de precisión en esta ruta. ¡Confía en las sugerencias!"); Spacer() } }
        }
        .onAppear { viewModel.cargarRecomendaciones(para: tiendaId) }
    }
    
    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles").foregroundColor(.yellow)
                Text("Análisis de Doña Lupita").fontWeight(.bold)
            }
            Text("Basado en el clima, día de la semana y ventas históricas, este es el pedido óptimo.")
                .font(.subheadline).foregroundColor(.blue.opacity(0.7))
            Divider().background(Color.blue.opacity(0.3))
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total sugerido").font(.caption).foregroundColor(.blue.opacity(0.6))
                    Text("\(viewModel.totalCajas) cajas").font(.title2).fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Venta est.").font(.caption).foregroundColor(.blue.opacity(0.6))
                    Text(viewModel.ventaEstimadaFormateada).font(.title3).fontWeight(.bold).foregroundColor(.green.opacity(0.9))
                }
            }
        }
        .padding(20).foregroundColor(.white)
        .background(LinearGradient(colors: [Color.bimboNavy, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing).clipShape(RoundedRectangle(cornerRadius: 16)))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .bimboNavy.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var recommendationsList: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.recomendaciones.enumerated()), id: \.element.id) { index, producto in
                AIRecommendationRow(producto: producto, onToggle: { viewModel.toggleRecomendacion(producto.id) })
            }
        }
    }
}

struct AIRecommendationRow: View {
    let producto: Producto
    let onToggle: () -> Void
    
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
                Toggle("", isOn: Binding(get: { producto.activo }, set: { _ in onToggle() })).tint(.bimboNavy).labelsHidden()
            }
            if producto.activo {
                HStack {
                    Text("Cantidad").font(.subheadline).foregroundColor(.gray)
                    Spacer()
                    Text("\(producto.cantidad) cajas").font(.subheadline).fontWeight(.bold).foregroundColor(.bimboNavy)
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
