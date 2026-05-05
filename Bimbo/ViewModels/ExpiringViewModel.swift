//
//  ExpiringViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de productos por caducar.
//  Gestiona las acciones sobre productos cercanos a su fecha de caducidad.
//

import Foundation

/// Gestiona la revisión de productos próximos a caducar en el anaquel.
@Observable
@MainActor
class ExpiringViewModel {
    
    /// Productos que están por caducar.
    var productos: [Producto]
    
    /// Número de productos pendientes de gestionar.
    var pendientes: Int {
        productos.filter { !$0.gestionado }.count
    }
    
    /// Indica si todos los productos han sido gestionados.
    var todosGestionados: Bool {
        productos.allSatisfy(\.gestionado)
    }
    
    init() {
        self.productos = MockDataService.productosCaducidad
    }
    
    /// Marca un producto como gestionado (retirado o promocionado).
    /// - Parameter id: ID del producto a gestionar.
    func gestionarProducto(_ id: Int) {
        if let index = productos.firstIndex(where: { $0.id == id }) {
            productos[index].gestionado = true
        }
    }
}
