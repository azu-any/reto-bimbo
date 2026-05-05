//
//  Vendedor.swift
//  Bimbo
//
//  Modelo de datos para el vendedor/repartidor de Bimbo.
//  Contiene información de la ruta activa.
//

import Foundation

/// Representa al vendedor que usa la aplicación.
struct Vendedor: Identifiable {
    let id: Int
    let nombre: String
    let rutaNumero: String
    
    /// Indica si la ruta del vendedor está activa.
    var rutaActiva: Bool = true
}
