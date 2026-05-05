//
//  AppStep.swift
//  Bimbo
//
//  Enum que define los pasos del flujo principal de la aplicación.
//  Cada caso representa una pantalla en la secuencia de visita a una tienda.
//

// AppStep.swift
import Foundation

enum AppStep: Int, CaseIterable, Hashable {
    case splash = 0
    case mapa = 1
    case llegada = 2
    case descarga = 3
    case caducidad = 4
    case resurtido = 5
    case recomendacionIA = 6
    case confirmacion = 7
    case notas = 8
    case exito = 9

    /// Pasos visibles en la barra de progreso (excluye splash y mapa).
    static let totalSteps = 8

    /// Número en la barra de progreso (0 si no aplica).
    var stepNumber: Int {
        switch self {
        case .llegada:        return 1
        case .descarga:       return 2
        case .caducidad:      return 3
        case .resurtido:      return 4
        case .recomendacionIA:return 5
        case .confirmacion:   return 6
        case .notas:          return 7
        case .exito:          return 8
        default:              return 0
        }
    }

    var titulo: String {
        switch self {
        case .splash:          return ""
        case .mapa:            return "En Ruta"
        case .llegada:         return "Llegada"
        case .descarga:        return "Bajar del camión"
        case .caducidad:       return "Revisión de anaquel"
        case .resurtido:       return "Acomodo Estratégico"
        case .recomendacionIA: return "Pedido Inteligente"
        case .confirmacion:    return "Confirmación"
        case .notas:           return "Notas del día"
        case .exito:           return "¡Completado!"
        }
    }

    var subtitulo: String? {
        switch self {
        case .descarga:        return "Pedido de la semana pasada"
        case .caducidad:       return "Productos por caducar"
        case .resurtido:       return "Sugerencias de neuromarketing"
        case .recomendacionIA: return "Ventas y recomendaciones con IA"
        case .confirmacion:    return "Revisión final del pedido"
        case .notas:           return "Ayuda a mejorar la ruta"
        default:               return nil
        }
    }
}
