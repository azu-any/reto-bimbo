//
//  AppFlowViewModel.swift
//  Bimbo
//
//  ViewModel principal que controla el flujo de navegación paso a paso.
//  Actúa como coordinador central: gestiona el paso actual, la tienda activa,
//  y la transición entre pantallas.
//

import Foundation
import SwiftUI

/// ViewModel principal que orquesta el flujo completo de la visita a una tienda.
@Observable
@MainActor
class AppFlowViewModel {
    
    // MARK: - Estado del flujo
    
    /// Paso actual del flujo (0 = splash, 1 = mapa, ..., 9 = éxito).
    var currentStep: AppStep = .splash
    
    /// Vendedor activo en sesión.
    var vendedor: Vendedor = MockDataService.vendedor
    
    /// Tienda actual que se está visitando.
    var tiendaActual: Tienda = MockDataService.tiendaActual
    
    /// Siguiente tienda en la ruta.
    var siguienteTienda: Tienda = MockDataService.siguienteTienda
    
    /// Pedido acumulado durante el flujo de visita.
    var pedidoActual: Pedido?
    
    // MARK: - Navegación
    
    /// Avanza al siguiente paso del flujo.
    /// Si está en el último paso (éxito), regresa al mapa para la siguiente tienda.
    func avanzar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let nextRawValue = currentStep.rawValue + 1
            if nextRawValue <= AppStep.exito.rawValue {
                currentStep = AppStep(rawValue: nextRawValue) ?? .mapa
            } else {
                // Loop: regresa al mapa para la siguiente tienda
                currentStep = .mapa
            }
        }
    }
    
    /// Regresa al paso anterior del flujo.
    func retroceder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let prevRawValue = currentStep.rawValue - 1
            if prevRawValue >= AppStep.splash.rawValue {
                currentStep = AppStep(rawValue: prevRawValue) ?? .splash
            }
        }
    }
    
    /// Reinicia el flujo completo desde el splash.
    func reiniciar() {
        withAnimation {
            currentStep = .splash
            pedidoActual = nil
        }
    }
    
    /// Establece el pedido actual a partir de los productos confirmados.
    func crearPedido(productos: [Producto]) {
        pedidoActual = Pedido(
            tiendaId: tiendaActual.id,
            productos: productos
        )
    }
}
