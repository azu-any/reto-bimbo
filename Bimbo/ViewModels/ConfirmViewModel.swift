//
//  ConfirmViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de confirmación del pedido.
//  Gestiona las aprobaciones del vendedor y el tendero,
//  y calcula los totales finales.
//

import Foundation

/// Gestiona la confirmación final del pedido con aprobación dual.
@Observable
@MainActor
class ConfirmViewModel {
    
    /// Productos en el pedido final.
    var productos: [Producto] = []
    
    /// Aprobación del vendedor.
    var aprobadoVendedor: Bool = false
    
    /// Aprobación del tendero.
    var aprobadoTendero: Bool = false
    
    /// Total monetario del pedido.
    var total: Double {
        productos.reduce(0) { $0 + ($1.precio * Double($1.cantidad)) }
    }
    
    /// Total de cajas del pedido.
    var totalCajas: Int {
        productos.reduce(0) { $0 + $1.cantidad }
    }
    
    /// Total formateado como moneda.
    var totalFormateado: String {
        return String(format: "$%.0f", total)
    }
    
    /// Indica si el pedido puede confirmarse (ambas partes aprueban).
    var puedeConfirmar: Bool {
        aprobadoVendedor && aprobadoTendero
    }
    
    /// Carga los productos finales para confirmar.
    /// - Parameter productos: Productos del pedido.
    func cargarProductos(_ productos: [Producto]) {
        self.productos = productos
    }
    
    /// Genera un pedido confirmado a partir del estado actual.
    func generarPedido(tiendaId: Int) -> Pedido {
        var pedido = Pedido(tiendaId: tiendaId, productos: productos)
        pedido.aprobadoVendedor = aprobadoVendedor
        pedido.aprobadoTendero = aprobadoTendero
        return pedido
    }
}
