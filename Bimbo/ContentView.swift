//
//  ContentView.swift
//  Bimbo
//
//  Vista raíz que orquesta el flujo completo de la app.
//  Usa AppFlowViewModel para controlar qué pantalla se muestra
//  y gestiona las transiciones animadas entre pasos.
//

import SwiftUI
import SwiftData

/// Vista raíz que muestra la pantalla correspondiente al paso actual del flujo.
struct ContentView: View {
    @State private var flowVM = AppFlowViewModel()
    @State private var audioService = AudioService()
    
    var body: some View {
        ZStack {
            // Switch entre pantallas según el paso actual
            // Cada pantalla recibe su `onNext` para avanzar el flujo
            switch flowVM.currentStep {
            case .splash:
                SplashView(onNext: { flowVM.avanzar() })
                    .transition(.opacity)
                
            case .mapa:
                MapView(
                    onNext: { flowVM.avanzar() },
                    tienda: flowVM.tiendaActual
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
            case .llegada:
                ArrivalView(
                    onNext: { flowVM.avanzar() },
                    nombreTienda: flowVM.tiendaActual.propietario
                )
                .transition(.opacity)
                
            case .descarga:
                UnloadView(onNext: { flowVM.avanzar() })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .caducidad:
                ExpiringView(onNext: { flowVM.avanzar() })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .resurtido:
                RestockView(onNext: { flowVM.avanzar() })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .recomendacionIA:
                AIRecommendView(
                    onNext: { flowVM.avanzar() },
                    tiendaId: flowVM.tiendaActual.id
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
            case .confirmacion:
                ConfirmView(onNext: { flowVM.avanzar() })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .notas:
                NotesView(
                    onNext: { flowVM.avanzar() },
                    tiendaId: flowVM.tiendaActual.id
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                
            case .exito:
                SuccessView(
                    onNext: { flowVM.avanzar() },
                    siguienteTienda: flowVM.siguienteTienda.nombre
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flowVM.currentStep)
        .environment(flowVM)
        .environment(audioService)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Nota.self, inMemory: true)
}
