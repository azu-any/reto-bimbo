//
//  AIRecommendationService.swift
//  Bimbo
//
//  Servicio mock de IA que genera recomendaciones de pedido.
//  En producción, esto se conectaría a un modelo de ML o API de IA
//  que analice histórico de ventas, clima, día de la semana, etc.
//

import Foundation

import CoreML

/// Servicio mock que simula recomendaciones inteligentes de pedido.
struct AIRecommendationService {
    
    /// Genera recomendaciones de productos basadas en el modelo ML BimboRegressor.
    /// - Parameter tiendaId: ID de la tienda para la cual generar recomendaciones.
    /// - Returns: Lista de productos recomendados con razones.
    static func generarRecomendaciones(para tiendaId: Int) -> [Producto] {
        
        var recomendaciones: [Producto] = [
            Producto(
                id: 73, nombre: "Pan Multigrano Linaza 540g", cantidad: 0, precio: 45.0,
                razonSugerencia: "Histórico +12% lunes. Alta demanda proyectada."
            ),
            Producto(
                id: 41, nombre: "Bimbollos Ext sAjonjoli 6p", cantidad: 0, precio: 38.0,
                razonSugerencia: "Incremento de venta por temporalidad."
            ),
            Producto(
                id: 106, nombre: "Wonder 100pct mediano", cantidad: 0, precio: 28.0,
                razonSugerencia: "Alta demanda en la zona centro."
            )
        ]
        
        do {
            let config = MLModelConfiguration()
            let model = try BimboRegressor(configuration: config)
            
            // Semana (mock this to 3), Cliente_ID (mock this to 15766)
            let semanaMock: Int64 = 3
            let clienteIdMock: Int64 = 15766
            
            for i in 0..<recomendaciones.count {
                let p = recomendaciones[i]
                
                // Evaluamos el modelo tabular
                // Venta_uni_hoy mockeado como base para la predicción
                let input = BimboRegressorInput(
                    Semana: semanaMock,
                    Cliente_ID: clienteIdMock,
                    Producto_ID: Int64(p.id),
                    Venta_uni_hoy: 2
                )
                
                let output = try model.prediction(input: input)
                
                // La salida es Demanda_uni_equil (target)
                // Usamos la predicción redondeando hacia arriba
                let demandaPredictiva = max(1, Int(ceil(output.Demanda_uni_equil)))
                recomendaciones[i].cantidad = demandaPredictiva
            }
        } catch {
            print("🚨 Error al ejecutar BimboRegressor: \(error)")
            // Fallback
            recomendaciones[0].cantidad = 4
            recomendaciones[1].cantidad = 2
            recomendaciones[2].cantidad = 3
        }
        
        return recomendaciones
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
