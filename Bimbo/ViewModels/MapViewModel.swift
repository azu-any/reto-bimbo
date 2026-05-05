//
//  MapViewModel.swift
//  Bimbo
//
//  ViewModel para la vista del mapa.
//  Simula la navegación del vendedor hacia la tienda con un temporizador
//  que reduce la distancia gradualmente.
//

import Foundation
import SwiftUI

/// Gestiona el estado de navegación simulada hacia la tienda destino.
@Observable
@MainActor
class MapViewModel {
    
    /// Distancia restante en metros hacia la tienda.
    var distancia: Int = 320
    
    /// Indica si el vendedor ha llegado a la tienda.
    var haLlegado: Bool = false
    
    /// Tiempo estimado de llegada formateado.
    var etaFormateado: String {
        let minutes = max(1, distancia / 100)
        return "\(minutes) min"
    }
    
    /// Hora estimada de llegada (mock).
    var horaETA: String {
        return "10:45 AM"
    }
    
    private var timer: Timer?
    
    /// Inicia la simulación de manejo hacia la tienda.
    /// Reduce la distancia 40m cada segundo.
    func iniciarSimulacion() {
        distancia = 320
        haLlegado = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.distancia > 0 {
                    withAnimation(.linear(duration: 0.5)) {
                        self.distancia = max(0, self.distancia - 40)
                    }
                }
                if self.distancia == 0 && !self.haLlegado {
                    self.haLlegado = true
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    /// Detiene la simulación de manejo.
    func detenerSimulacion() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        // No se puede acceder a propiedades aisladas al actor principal aquí.
        // Asegúrate de llamar a detenerSimulacion() manualmente antes de liberar la instancia.
    }
}

