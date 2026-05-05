//
//  Nota.swift
//  Bimbo
//
//  Modelo de datos para las notas del día.
//  El vendedor puede escribir observaciones o usar etiquetas rápidas.
//  Estas notas se almacenan localmente y alimentan al agente para futuras recomendaciones.
//

import Foundation
import SwiftData

/// Notas del vendedor sobre la visita a una tienda.
/// Usa @Model de SwiftData para persistencia local.
@Model
final class Nota {
    var id: UUID
    var tiendaId: Int
    var contenido: String
    var etiquetas: [String]
    var fecha: Date
    
    init(tiendaId: Int, contenido: String, etiquetas: [String] = []) {
        self.id = UUID()
        self.tiendaId = tiendaId
        self.contenido = contenido
        self.etiquetas = etiquetas
        self.fecha = Date()
    }
}
