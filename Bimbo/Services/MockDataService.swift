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
    /// Coordenadas reales alineadas con el sembrado de BimboApp.sembrarDatosIniciales.
    static let tiendaActual = Tienda(
        id: 15766,
        nombre: "Doña Lupita",
        direccion: "Av. Reforma 123",
        latitud: 19.3878,
        longitud: -99.18626,
        propietario: "Lupita"
    )
    
    /// Siguiente tienda en la ruta (se muestra al final del flujo).
    static let siguienteTienda = Tienda(
        id: 15767,
        nombre: "Abarrotes El Sol",
        direccion: "Calle Hidalgo 78",
        latitud: 19.4350,
        longitud: -99.1400,
        propietario: "Don Ramón"
    )
    
    // MARK: - Productos a descargar (pedido de la semana pasada)
    
    /// Productos que el vendedor debe bajar del camión en la tienda actual.
    static let productosDescarga: [Producto] = [
        Producto(id: 73, nombre: "Pan Multigrano Linaza 540g", cantidad: 3, precio: 45.0),
        Producto(id: 41, nombre: "Bimbollos Ext sAjonjoli 6p", cantidad: 4, precio: 38.0),
        Producto(id: 72, nombre: "Div Tira Mini Doradita 4p", cantidad: 8, precio: 42.0),
        Producto(id: 106, nombre: "Wonder 100pct mediano", cantidad: 5, precio: 28.0)
    ]
    
    // MARK: - Productos por caducar
    
    /// Productos en el anaquel que están próximos a caducar.
    static let productosCaducidad: [Producto] = [
        Producto(
            id: 106, nombre: "Wonder 100pct mediano", cantidad: 1, precio: 40.0,
            diasParaCaducar: 2, accionCaducidad: "Retirar"
        ),
        Producto(
            id: 72, nombre: "Div Tira Mini Doradita 4p", cantidad: 1, precio: 15.0,
            diasParaCaducar: 4, accionCaducidad: "Retirar"
        )
    ]
    
    // MARK: - Sugerencias de Neuromarketing (Resurtido)
    
    /// Sugerencias de acomodo basadas en neuromarketing.
    static let sugerenciasResurtido: [Producto] = [
        Producto(
            id: 41, nombre: "Bimbollos Ext sAjonjoli 6p", cantidad: 2, precio: 38.0,
            razonSugerencia: "Color rojo en zona caja: +18% impulso"
        ),
        Producto(
            id: 73, nombre: "Pan Multigrano Linaza 540g", cantidad: 4, precio: 45.0,
            razonSugerencia: "Nivel de ojos del cliente"
        )
    ]
    
    // MARK: - Etiquetas rápidas para notas
    
    /// Chips/etiquetas rápidas para facilitar la captura de notas.
    static let etiquetasRapidas: [String] = [
        "Cambio de dueño",
        "Renovación",
        "Cambio de tendero",
        "Cerrado temprano"
    ]
}
