//
//  RootView.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

// Bimbo/Views/RootView.swift
// RootView.swift
import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var voice = VoiceService()
    @State private var location = LocationService()
    @State private var agent: OsitoAgent?
    @State private var tienda: Tienda?
    @State private var appStep: AppStep = .splash

    var body: some View {
        ZStack {
            switch appStep {
            case .splash:
                SplashView {
                    withAnimation(.easeInOut(duration: 0.4)) { appStep = .mapa }
                }

            case .mapa:
                if let tienda, let agent {
                    MapView(
                        agent : agent,
                        tienda: tienda,
                        location: location,
                        onLlegada: {
                            Task { @MainActor in
                                await agent.iniciarVisita(tienda: tienda)
                                withAnimation(.easeInOut(duration: 0.4)) { appStep = .llegada }
                            }
                        }
                    )
                } else {
                    ZStack {
                        Color.bimboNavy.ignoresSafeArea()
                        ProgressView("Cargando ruta...").tint(.white).foregroundColor(.white)
                    }
                }

            default:
                if let agent, let tienda {
                    FlujoView(agent: agent, tienda: tienda)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                } else {
                    ZStack {
                        Color.bimboNavy.ignoresSafeArea()
                        ProgressView("Preparando al Osito...").tint(.white).foregroundColor(.white)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appStep)
        .task {
            _ = await voice.solicitarPermisos()
            location.solicitarPermisos()

            let desc = FetchDescriptor<Tienda>(sortBy: [SortDescriptor(\.id)])
            if let primera = try? modelContext.fetch(desc).first {
                self.tienda = primera
                self.agent = OsitoAgent(modelContext: modelContext, voice: voice)
            }
        }
    }
}

struct FlujoView: View {
    let agent: OsitoAgent
    let tienda: Tienda

    var body: some View {
        Group {
            switch agent.pasoActual {
            case .llegada:
                ArrivalViewIA(agent: agent, tienda: tienda)
            case .descarga:
                UnloadViewIA(agent: agent)
            case .caducidad:
                ExpiringViewIA(agent: agent)
            case .resurtido:
                RestockViewIA(agent: agent)
            case .recomendacionIA:
                RecomendacionIAView(agent: agent)
            case .confirmacion:
                ConfirmacionViewIA(agent: agent)
            case .notas:
                NotasViewIA(agent: agent, tiendaId: tienda.id)
            case .exito:
                FinView(agent: agent)
            default:
                EmptyView()
            }
        }
        .id(agent.pasoActual)
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.easeInOut(duration: 0.3), value: agent.pasoActual)
        .onAppear {
                    agent.voice.iniciarEscuchaPasiva { pregunta in
                        Task { await agent.vendedorDicta(pregunta) }
                    }
                }

    }
}
