//
//  AIRecommendViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de recomendaciones con IA.
//  Usa el servicio mock de IA para generar sugerencias de pedido
//  que el vendedor puede aceptar o rechazar individualmente.
//

import Foundation

/// Gestiona las recomendaciones de pedido inteligente generadas por IA.
@Observable
@MainActor
class AIRecommendViewModel {
    
    /// Productos recomendados por la IA.
    var recomendaciones: [Producto] = []
    
    /// Total de cajas en productos activos (aceptados).
    var totalUnidades: Int {
        recomendaciones.filter(\.activo).reduce(0) { $0 + $1.cantidad }
    }
    
    /// Venta estimada basada en productos activos.
    var ventaEstimada: Double {
        let activos = recomendaciones.filter(\.activo)
        return AIRecommendationService.ventaEstimada(para: activos)
    }
    
    /// Venta estimada formateada como moneda.
    var ventaEstimadaFormateada: String {
        return String(format: "$%.0f", ventaEstimada)
    }
    
    /// Carga las recomendaciones de IA para la tienda indicada.
    /// - Parameter tiendaId: ID de la tienda para generar recomendaciones.
    func cargarRecomendaciones(para tiendaId: Int) {
        recomendaciones = AIRecommendationService.generarRecomendaciones(para: tiendaId)
    }
    
    /// Alterna si una recomendación está activa o no.
    /// - Parameter id: ID del producto a alternar.
    func toggleRecomendacion(_ id: Int) {
        if let index = recomendaciones.firstIndex(where: { $0.id == id }) {
            recomendaciones[index].activo.toggle()
        }
    }
    
    /// Retorna los productos activos (aceptados por el vendedor).
    func productosAceptados() -> [Producto] {
        return recomendaciones.filter(\.activo)
    }
    
    
    func updateCantidad(for id: Int, cantidad: Int) {
        if let index = recomendaciones.firstIndex(where: { $0.id == id }) {
            recomendaciones[index].cantidad = cantidad
            
            if cantidad == 0 {
                recomendaciones[index].activo = false
            }
        }
    }
}

