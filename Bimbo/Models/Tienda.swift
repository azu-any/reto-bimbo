//
//  Tienda.swift
//  Bimbo
//
//  Modelo de datos para representar una tienda de barrio.
//  Contiene ubicación, nombre del propietario y datos de la próxima visita.
//

import Foundation
import CoreLocation

/// Representa una tienda de barrio en la ruta del vendedor.
struct Tienda: Identifiable, Hashable {
    let id: Int
    let nombre: String
    let propietario: String
    let direccion: String
    let coordenadas: CLLocationCoordinate2D
    
    // MARK: - Hashable conformance (CLLocationCoordinate2D no es Hashable por defecto)
    
    static func == (lhs: Tienda, rhs: Tienda) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
