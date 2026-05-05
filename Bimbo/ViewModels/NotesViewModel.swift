//
//  NotesViewModel.swift
//  Bimbo
//
//  ViewModel para la pantalla de notas del día.
//  Gestiona la captura de texto libre, etiquetas rápidas
//  y la persistencia local mediante SwiftData.
//

import Foundation
import SwiftData

/// Gestiona las notas del vendedor sobre la visita a la tienda.
@Observable
@MainActor
class NotesViewModel {
    
    /// Texto de la nota actual.
    var contenidoNota: String = ""
    
    /// Etiquetas seleccionadas.
    var etiquetasSeleccionadas: [String] = []
    
    /// Indica si el micrófono está "grabando" (mock).
    var isRecording: Bool = false
    
    /// Etiquetas rápidas disponibles.
    let etiquetasDisponibles: [String] = MockDataService.etiquetasRapidas
    
    /// Número de caracteres en la nota actual.
    var conteoCaracteres: Int {
        contenidoNota.count
    }
    
    /// Agrega una etiqueta rápida al contenido de la nota.
    /// - Parameter etiqueta: Texto de la etiqueta a agregar.
    func agregarEtiqueta(_ etiqueta: String) {
        if contenidoNota.isEmpty {
            contenidoNota = etiqueta
        } else {
            contenidoNota += ", \(etiqueta)"
        }
        if !etiquetasSeleccionadas.contains(etiqueta) {
            etiquetasSeleccionadas.append(etiqueta)
        }
    }
    
    /// Alterna el estado de grabación del micrófono (simulado).
    func toggleGrabacion() {
        isRecording.toggle()
        // Mock: En producción, aquí se iniciaría/detendría el reconocimiento de voz
    }
    
    /// Guarda la nota en persistencia local usando SwiftData.
    /// - Parameters:
    ///   - tiendaId: ID de la tienda visitada.
    ///   - modelContext: Contexto de SwiftData para persistir.
    func guardarNota(tiendaId: Int, modelContext: ModelContext) {
        guard !contenidoNota.isEmpty else { return }
        
        let nota = Nota(
            tiendaId: tiendaId,
            contenido: contenidoNota,
            etiquetas: etiquetasSeleccionadas
        )
        modelContext.insert(nota)
        
        // Limpiar estado después de guardar
        contenidoNota = ""
        etiquetasSeleccionadas = []
    }
}
