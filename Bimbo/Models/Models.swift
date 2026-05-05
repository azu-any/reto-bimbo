//
//  Models.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//


// Models.swift
// Bimbo/Models.swift
import Foundation
import SwiftData

@Model
final class Tienda {
    @Attribute(.unique) var id: Int
    var nombre: String
    var direccion: String
    var latitud: Double
    var longitud: Double
    var nombreTendero: String
    
    @Relationship(deleteRule: .cascade) var visitas: [Visita] = []
    @Relationship(deleteRule: .cascade) var notas: [NotaVisita] = []
    
    init(id: Int, nombre: String, direccion: String,
         latitud: Double, longitud: Double, nombreTendero: String) {
        self.id = id; self.nombre = nombre; self.direccion = direccion
        self.latitud = latitud; self.longitud = longitud; self.nombreTendero = nombreTendero
    }
}

@Model
final class ProductoCatalogo {
    @Attribute(.unique) var productoId: String
    var nombre: String
    var categoria: String
    var vidaUtilSemanas: Int
    var precio: Double
    
    init(productoId: String, nombre: String, categoria: String,
         vidaUtilSemanas: Int, precio: Double) {
        self.productoId = productoId; self.nombre = nombre; self.categoria = categoria
        self.vidaUtilSemanas = vidaUtilSemanas; self.precio = precio
    }
}

@Model
final class Visita {
    var fecha: Date
    var tiendaId: Int
    
    @Relationship(deleteRule: .cascade) var itemsPedidoAnterior: [ItemPedido] = []
    @Relationship(deleteRule: .cascade) var itemsVendidos: [ItemVenta] = []
    @Relationship(deleteRule: .cascade) var itemsConfirmados: [ItemPedido] = []
    
    var pedidoConfirmado: Bool = false
    
    init(fecha: Date, tiendaId: Int) {
        self.fecha = fecha; self.tiendaId = tiendaId
    }
}

@Model
final class ItemPedido {
    var productoId: String
    var nombreProducto: String
    var unidades: Int          // cantidad de PRODUCTOS (no cajas)
    var fechaEntrega: Date
    
    init(productoId: String, nombreProducto: String, unidades: Int, fechaEntrega: Date) {
        self.productoId = productoId; self.nombreProducto = nombreProducto
        self.unidades = unidades; self.fechaEntrega = fechaEntrega
    }
}

@Model
final class ItemVenta {
    var productoId: String
    var nombreProducto: String
    var unidadesVendidas: Int   // cantidad de PRODUCTOS vendidos
    var fechaRegistro: Date
    
    init(productoId: String, nombreProducto: String, unidadesVendidas: Int) {
        self.productoId = productoId; self.nombreProducto = nombreProducto
        self.unidadesVendidas = unidadesVendidas; self.fechaRegistro = Date()
    }
}

@Model
final class NotaVisita {
    var fecha: Date
    var tiendaId: Int
    var vendedor: String        // ← NUEVO: quién escribió la nota
    var contenidoOriginal: String
    var resumenIA: String
    var insights: [String]
    var sentimiento: String
    var etiquetas: [String]
    
    init(fecha: Date, tiendaId: Int,
         vendedor: String = "Desconocido",
         contenidoOriginal: String,
         resumenIA: String = "", insights: [String] = [],
         sentimiento: String = "neutro", etiquetas: [String] = []) {
        self.fecha = fecha; self.tiendaId = tiendaId
        self.vendedor = vendedor
        self.contenidoOriginal = contenidoOriginal
        self.resumenIA = resumenIA; self.insights = insights
        self.sentimiento = sentimiento; self.etiquetas = etiquetas
    }
}
