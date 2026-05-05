//
//  AppStep.swift
//  Bimbo
//
//  Enum que define los pasos del flujo principal de la aplicación.
//  Cada caso representa una pantalla en la secuencia de visita a una tienda.
//

import Foundation

/// Pasos del flujo principal de la app.
/// El flujo es lineal: splash → mapa → llegada → descarga → caducidad → resurtido → IA → confirmar → notas → éxito.
enum AppStep: Int, CaseIterable {
    case splash = 0
    case mapa = 1
    case llegada = 2
    case descarga = 3          // Bajar productos del camión
    case caducidad = 4         // Revisar productos por caducar
    case resurtido = 5         // Sugerencias de neuromarketing
    case recomendacionIA = 6   // Pedido inteligente con IA
    case confirmacion = 7      // Confirmación del pedido
    case notas = 8             // Notas del día
    case exito = 9             // Visita completada
    
    /// Total de pasos del flujo (excluyendo splash).
    static let totalSteps = 9
    
    /// Título para el StepHeader de cada pantalla.
    var titulo: String {
        switch self {
        case .splash: return ""
        case .mapa: return "En Ruta"
        case .llegada: return "Llegada"
        case .descarga: return "Bajar del camión"
        case .caducidad: return "Revisión de anaquel"
        case .resurtido: return "Acomodo Estratégico"
        case .recomendacionIA: return "Pedido Inteligente"
        case .confirmacion: return "Confirmación"
        case .notas: return "Notas del día"
        case .exito: return "¡Completado!"
        }
    }
    
    /// Subtítulo descriptivo para el StepHeader.
    var subtitulo: String? {
        switch self {
        case .descarga: return "Pedido de la semana pasada"
        case .caducidad: return "Productos por caducar"
        case .resurtido: return "Sugerencias de neuromarketing"
        case .recomendacionIA: return "Recomendaciones con IA"
        case .confirmacion: return "Revisión final del pedido"
        case .notas: return "Ayuda a mejorar la ruta"
        default: return nil
        }
    }
}
