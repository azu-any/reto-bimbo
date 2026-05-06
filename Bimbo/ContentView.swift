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
    @Environment(\.modelContext) private var modelContext

    @State private var flowVM = AppFlowViewModel()
    @State private var audioService = AudioService()
    @State private var voice = VoiceService()
    @State private var location = LocationService()
    @State private var agent: OsitoAgent?
    @State private var tienda: Tienda?
    @State private var appStep: AppStep = .splash

    
    var body: some View {
        ZStack {
            // Switch entre pantallas según el paso actual
            // Cada pantalla recibe su `onNext` para avanzar el flujo
            switch flowVM.currentStep {
            case .splash:
                SplashView(onNext: { flowVM.avanzar() })
                    .transition(.opacity)
                
            case .mapa:
                if let tienda, let agent {
                    MapView(
                        agent: agent,
                        location: location,   // servicio compartido, ya solicitó permisos en .task
                        tienda: tienda,        // tienda real de SwiftData (coordenadas correctas)
                        onLlegada: { flowVM.avanzar() }  // MapView llama agent.iniciarVisita internamente
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
            case .llegada:
                if let tienda, let agent {
                    ArrivalView(
                        agent: agent,
                        tienda: tienda,
                        onNext: { flowVM.avanzar() },
                        nombreTienda: flowVM.tiendaActual.propietario
                    )
                    .transition(.opacity)
                }
                
            case .descarga:
                UnloadView(onNext: { flowVM.avanzar() })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                
            case .caducidad:
                if let agent {
                    ExpiringView(
                        agent: agent,
                        onNext: { flowVM.avanzar() },
                        onBack: { flowVM.retroceder() }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
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
                if let agent {
                    NotesView(
                        agent: agent,
                        onNext: { flowVM.avanzar() },
                        tiendaId: flowVM.tiendaActual.id
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                
            case .exito:
                if let agent {
                    SuccessView(
                        onNext: { flowVM.avanzar() },
                        siguienteTienda: flowVM.siguienteTienda.nombre,
                        agent: agent
                    )
                    .transition(.opacity)
                }
            }
            
            // Botón global del chat de IA
            if let agent = agent, flowVM.currentStep != .splash, flowVM.currentStep != .llegada, flowVM.currentStep != .exito {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        OsitoFABView(agent: agent)
                            .padding(.bottom, 52)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flowVM.currentStep)
        .environment(flowVM)
        .environment(audioService)
        .onChange(of: flowVM.currentStep) { _, _ in
            agent?.voice.detenerVoz()
        }
        .task {
           _ = await voice.solicitarPermisos()
           location.solicitarPermisos()
           
           voice.onOyeOsito = { comando in
               NotificationCenter.default.post(name: Notification.Name("OyeOsitoTriggered"), object: comando)
           }
           voice.iniciarEscuchaContinua()

           let desc = FetchDescriptor<Tienda>(sortBy: [SortDescriptor(\.id)])
           if let primera = try? modelContext.fetch(desc).first {
               self.tienda = primera
               self.agent = OsitoAgent(modelContext: modelContext, voice: voice)
           }
       }

    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Nota.self, inMemory: true)
}
