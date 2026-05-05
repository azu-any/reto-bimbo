//
//  Pedido.swift
//  Bimbo
//
//  Modelo de datos para representar un pedido completo.
//  Agrupa los productos confirmados junto con aprobaciones del vendedor y tendero.
//

import Foundation

/// Representa un pedido completo para una tienda.
struct Pedido: Identifiable {
    let id: UUID
    let tiendaId: Int
    var productos: [Producto]
    var aprobadoVendedor: Bool = false
    var aprobadoTendero: Bool = false
    let fechaCreacion: Date
    
    /// Total monetario del pedido sumando (precio * cantidad) de cada producto.
    var total: Double {
        productos.reduce(0) { $0 + ($1.precio * Double($1.cantidad)) }
    }
    
    /// Total de cajas/unidades en el pedido.
    var totalCajas: Int {
        productos.reduce(0) { $0 + $1.cantidad }
    }
    
    /// Indica si ambas partes (vendedor y tendero) aprobaron el pedido.
    var confirmado: Bool {
        aprobadoVendedor && aprobadoTendero
    }
    
    init(tiendaId: Int, productos: [Producto]) {
        self.id = UUID()
        self.tiendaId = tiendaId
        self.productos = productos
        self.fechaCreacion = Date()
    }
}
