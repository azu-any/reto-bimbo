//
//  Tienda.swift
//  Bimbo
//
//  Modelo de datos para representar una tienda de barrio.
//  Contiene ubicación, nombre del propietario y datos de la próxima visita.
//

import Foundation
import CoreLocation
import SwiftData

/// Representa una tienda de barrio en la ruta del vendedor.


@Model
final class Tienda: Identifiable, Hashable {
    var id: Int
    var nombre: String
    var propietario: String
    var direccion: String
    var latitud: Double
    var longitud: Double
    
    @Relationship(deleteRule: .cascade) var visitas: [Visita] = []
    @Relationship(deleteRule: .cascade) var notas: [NotaVisita] = []

    init(id: Int, nombre: String, direccion: String,
        latitud: Double, longitud: Double, propietario: String) {
        self.id = id; self.nombre = nombre; self.direccion = direccion
        self.latitud = latitud; self.longitud = longitud; self.propietario = propietario
    }
    
    // MARK: - Hashable conformance (CLLocationCoordinate2D no es Hashable por defecto)
    
    static func == (lhs: Tienda, rhs: Tienda) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//@Model
//final class Tienda {
//    @Attribute(.unique) var id: Int
//    var nombre: String
//    var direccion: String
//    var latitud: Double
//    var longitud: Double
//    var nombreTendero: String
//    
//    @Relationship(deleteRule: .cascade) var visitas: [Visita] = []
//    @Relationship(deleteRule: .cascade) var notas: [NotaVisita] = []
//    
//    init(id: Int, nombre: String, direccion: String,
//         latitud: Double, longitud: Double, nombreTendero: String) {
//        self.id = id; self.nombre = nombre; self.direccion = direccion
//        self.latitud = latitud; self.longitud = longitud; self.nombreTendero = nombreTendero
//    }
//}
//
