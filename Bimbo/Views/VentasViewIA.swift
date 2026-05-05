//
//  VentasViewIA.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import SwiftUI

struct VentasViewIA: View {
    let agent: OsitoAgent
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 4, title: "Ventas de la semana", subtitle: "Dicta lo que se vendió")
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !agent.ultimoMensajeOsito.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Text("🐻").font(.title)
                                Text(agent.ultimoMensajeOsito).font(.body).padding(12)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            }
                        }
                        if !agent.ventasRegistradas.isEmpty {
                            Text("Detecté:").font(.subheadline).fontWeight(.bold).padding(.top, 8)
                            ForEach(agent.ventasRegistradas, id: \.productoId) { v in
                                HStack {
                                    Text(v.nombre).fontWeight(.semibold)
                                    Spacer()
                                    Text("\(v.unidadesVendidas) un.").foregroundColor(.bimboNavy).fontWeight(.bold)
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "mic.circle.fill").font(.system(size: 64)).foregroundColor(.bimboNavy)
                                Text("Toca el micrófono y dicta los productos vendidos.")
                                    .multilineTextAlignment(.center).foregroundColor(.gray)
                                Text("Ej: \"vendí 12 panes Bimbo y 8 Gansitos\"")
                                    .font(.caption).foregroundColor(.gray.opacity(0.7))
                            }.padding(48)
                        }
                    }
                    .padding(24).padding(.bottom, 120)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: agent.ventasRegistradas.isEmpty ? "Dicta primero" : "Generar sugerencias",
                    iconName: "chevron.right",
                    disabled: agent.ventasRegistradas.isEmpty
                ) {
                    Task { await agent.avanzarA(.resurtido) }
                }
                .padding(24)
            }
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
}
