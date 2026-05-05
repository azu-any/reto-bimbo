//
//  UnloadViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de descarga de productos del camión.
//  Gestiona el checklist de productos y el progreso de la descarga.
//

import Foundation

/// Gestiona la descarga de productos del camión en la tienda.
@Observable
@MainActor
class UnloadViewModel {
    
    /// Lista de productos a descargar con su estado de check.
    var productos: [Producto]
    
    /// Número de productos ya marcados como descargados.
    var checkedCount: Int {
        productos.filter(\.checked).count
    }
    
    /// Total de productos a descargar.
    var totalCount: Int {
        productos.count
    }
    
    /// Progreso de la descarga como porcentaje (0.0 a 1.0).
    var progreso: Double {
        guard totalCount > 0 else { return 0 }
        return Double(checkedCount) / Double(totalCount)
    }
    
    /// Indica si todos los productos han sido descargados.
    var todosDescargados: Bool {
        checkedCount == totalCount
    }
    
    init() {
        self.productos = MockDataService.productosDescarga
    }
    
    /// Alterna el estado de check de un producto.
    /// - Parameter id: ID del producto a marcar/desmarcar.
    func toggleProducto(_ id: Int) {
        if let index = productos.firstIndex(where: { $0.id == id }) {
            productos[index].checked.toggle()
        }
    }
}
