//
//  RestockViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de resurtido con neuromarketing.
//  Presenta sugerencias de acomodo basadas en psicología del consumidor.
//

import Foundation

/// Gestiona las sugerencias de acomodo estratégico basadas en neuromarketing.
@Observable
@MainActor
class RestockViewModel {
    
    /// Sugerencias de productos con ubicaciones estratégicas.
    var sugerencias: [Producto]
    
    init() {
        self.sugerencias = MockDataService.sugerenciasResurtido
    }
    
    /// Ajusta la cantidad sugerida de un producto.
    /// - Parameters:
    ///   - id: ID del producto.
    ///   - incremento: Valor a sumar (positivo) o restar (negativo).
    func ajustarCantidad(_ id: Int, incremento: Int) {
        if let index = sugerencias.firstIndex(where: { $0.id == id }) {
            let nuevaCantidad = sugerencias[index].cantidad + incremento
            sugerencias[index].cantidad = max(0, nuevaCantidad)
        }
    }
}
