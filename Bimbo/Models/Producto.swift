//
//  Producto.swift
//  Bimbo
//
//  Modelo de datos para representar un producto Bimbo.
//  Se usa a lo largo de todo el flujo: descarga, caducidad, resurtido, pedido IA y confirmación.
//

import Foundation

/// Representa un producto individual del catálogo Bimbo.
struct Producto: Identifiable, Hashable {
    let id: Int
    let nombre: String
    var cantidad: Int
    var precio: Double
    
    /// Nombre del asset de imagen en Assets.xcassets (sin extensión).
    /// Vacío si el producto no tiene imagen asignada.
    var imagenNombre: String = ""
    
    /// Número de lote para identificación rápida (opcional).
    var lote: String? = nil
    
    /// Indica si el producto ya fue revisado/marcado en un checklist.
    var checked: Bool = false
    
    /// Días restantes antes de caducar (solo aplica en pantalla de caducidad).
    var diasParaCaducar: Int? = nil
    
    var cantidadCaducada: Int? = nil
    
    /// Acción sugerida para productos por caducar ("Retirar").
    var accionCaducidad: String? = nil
    
    /// Indica si este producto ya fue gestionado en la pantalla de caducidad.
    var gestionado: Bool = false
    
    /// Razón de la sugerencia de neuromarketing o IA.
    var razonSugerencia: String? = nil
    
    /// Indica si la recomendación de IA está activa (el vendedor la aceptó).
    var activo: Bool = true
}
