//
//  SugerenciasViewIA.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import SwiftUI

struct SugerenciasViewIA: View {
    let agent: OsitoAgent
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 5, title: "Pedido Inteligente", subtitle: "Recomendaciones IA")
                ScrollView {
                    VStack(spacing: 16) {
                        if !agent.ultimoMensajeOsito.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Text("🐻").font(.title)
                                Text(agent.ultimoMensajeOsito).font(.body).padding(12)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            }
                        }
                        ForEach(agent.sugerenciasGeneradas, id: \.productoId) { s in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(s.nombre).fontWeight(.bold)
                                    Spacer()
                                    Text("\(s.cantidadSugerida) un.")
                                        .fontWeight(.bold).foregroundColor(.bimboNavy)
                                }
                                Text(s.justificacion).font(.caption).foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                        }
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(title: "Revisar con tendero", iconName: "chevron.right") {
                    Task { await agent.avanzarA(.confirmacion) }
                }
                .padding(24)
            }
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
}
