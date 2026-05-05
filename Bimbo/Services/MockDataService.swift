//
//  MockDataService.swift
//  Bimbo
//
//  Servicio que provee datos mock para simular un backend.
//  En producción, estos datos vendrían de una API REST o base de datos.
//

import Foundation
import CoreLocation

/// Servicio centralizado de datos mock que simula las respuestas del backend.
struct MockDataService {
    
    // MARK: - Vendedor
    
    /// Vendedor mock que representa al usuario actual de la app.
    static let vendedor = Vendedor(
        id: 1,
        nombre: "Carlos",
        rutaNumero: "4521",
        rutaActiva: true
    )
    
    // MARK: - Tiendas en la ruta
    
    /// Tienda actual a la que se dirige el vendedor.
    static let tiendaActual = Tienda(
        id: 101,
        nombre: "Tiendita Doña Lupita",
        propietario: "Doña Lupita",
        direccion: "Av. Revolución 452",
        coordenadas: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
    )
    
    /// Siguiente tienda en la ruta (se muestra al final del flujo).
    static let siguienteTienda = Tienda(
        id: 102,
        nombre: "Abarrotes El Sol",
        propietario: "Don Ramón",
        direccion: "Calle Hidalgo 78",
        coordenadas: CLLocationCoordinate2D(latitude: 19.4350, longitude: -99.1400)
    )
    
    // MARK: - Productos a descargar (pedido de la semana pasada)
    
    /// Productos que el vendedor debe bajar del camión en la tienda actual.
    static let productosDescarga: [Producto] = [
        Producto(id: 1, nombre: "Pan Bimbo Grande", cantidad: 3, precio: 45.0),
        Producto(id: 2, nombre: "Donas Bimbo", cantidad: 2, precio: 38.0),
        Producto(id: 3, nombre: "Mantecadas", cantidad: 2, precio: 42.0),
        Producto(id: 4, nombre: "Tortillinas Tía Rosa", cantidad: 1, precio: 28.0)
    ]
    
    // MARK: - Productos por caducar
    
    /// Productos en el anaquel que están próximos a caducar.
    static let productosCaducidad: [Producto] = [
        Producto(
            id: 10, nombre: "Pan Blanco Wonder", cantidad: 1, precio: 40.0,
            diasParaCaducar: 2, accionCaducidad: "Retirar"
        ),
        Producto(
            id: 11, nombre: "Submarinos Fresa", cantidad: 1, precio: 15.0,
            diasParaCaducar: 4, accionCaducidad: "Promoción 2x1"
        )
    ]
    
    // MARK: - Sugerencias de Neuromarketing (Resurtido)
    
    /// Sugerencias de acomodo basadas en neuromarketing.
    static let sugerenciasResurtido: [Producto] = [
        Producto(
            id: 20, nombre: "Gansito", cantidad: 2, precio: 100.0,
            razonSugerencia: "Color rojo en zona caja: +18% impulso"
        ),
        Producto(
            id: 21, nombre: "Pan Bimbo", cantidad: 4, precio: 45.0,
            razonSugerencia: "Nivel de ojos del cliente"
        )
    ]
    
    // MARK: - Etiquetas rápidas para notas
    
    /// Chips/etiquetas rápidas para facilitar la captura de notas.
    static let etiquetasRapidas: [String] = [
        "Cambió de dueño",
        "Renovó refri",
        "Pidió promoción",
        "Competencia nueva",
        "Cerrado temprano"
    ]
}
