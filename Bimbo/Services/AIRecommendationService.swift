//
//  AIRecommendationService.swift
//  Bimbo
//
//  Servicio mock de IA que genera recomendaciones de pedido.
//  En producción, esto se conectaría a un modelo de ML o API de IA
//  que analice histórico de ventas, clima, día de la semana, etc.
//

import Foundation

/// Servicio mock que simula recomendaciones inteligentes de pedido.
struct AIRecommendationService {
    
    /// Genera recomendaciones de productos basadas en datos simulados.
    /// - Parameter tiendaId: ID de la tienda para la cual generar recomendaciones.
    /// - Returns: Lista de productos recomendados con razones.
    static func generarRecomendaciones(para tiendaId: Int) -> [Producto] {
        // Mock: Simula que un modelo de IA analiza:
        // - Histórico de ventas de la tienda
        // - Día de la semana (lunes = +12% pan)
        // - Clima (frío = más pan dulce)
        // - Tendencias de la zona
        
        return [
            Producto(
                id: 30, nombre: "Pan Bimbo Grande", cantidad: 4, precio: 45.0,
                razonSugerencia: "Histórico +12% lunes"
            ),
            Producto(
                id: 31, nombre: "Roles Canela", cantidad: 2, precio: 60.0,
                razonSugerencia: "Clima frío previsto"
            ),
            Producto(
                id: 32, nombre: "Donas Bimbo", cantidad: 3, precio: 50.0,
                razonSugerencia: "Alta demanda en la zona"
            )
        ]
    }
    
    /// Calcula la venta estimada del pedido.
    /// - Parameter productos: Lista de productos activos en el pedido.
    /// - Returns: Monto estimado de venta.
    static func ventaEstimada(para productos: [Producto]) -> Double {
        // Mock: En producción usaría un modelo predictivo
        let base = productos.reduce(0.0) { $0 + ($1.precio * Double($1.cantidad)) }
        // Simula un factor de conversión del 85%
        return base * 0.85
    }
}
