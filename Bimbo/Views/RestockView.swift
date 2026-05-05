//
//  RestockView.swift
//  Bimbo
//
//  Vista de sugerencias de acomodo estratégico con neuromarketing.
//  Muestra un diagrama de "zonas calientes" y tarjetas de sugerencias
//  con la razón basada en psicología del consumidor.
//

import SwiftUI

struct RestockViewIA: View {
    let agent: OsitoAgent
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 3, title: "Acomodo Estratégico", subtitle: "Tip del Osito")
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Mensaje del Osito
                        HStack(alignment: .top, spacing: 12) {
                            Text("🐻").font(.title)
                            Text(agent.ultimoMensajeOsito.isEmpty
                                 ? "El Osito está pensando un tip para ti..."
                                 : agent.ultimoMensajeOsito)
                                .font(.body).padding(16)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                        }
                        // Diagrama de zonas
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Zonas Calientes").font(.subheadline).fontWeight(.bold)
                            HStack(spacing: 8) {
                                zoneBox("Bajo", hot: false)
                                zoneBox("Nivel de ojos", hot: true)
                                zoneBox("Alto", hot: false)
                            }.frame(height: 96)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(title: "Entendido", iconName: "chevron.right") {
                    Task { await agent.avanzarA(.recomendacionIA) }
                }
                .padding(24)
            }
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
    
    private func zoneBox(_ label: String, hot: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(hot ? Color.red.opacity(0.05) : Color.gray.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(hot ? Color.bimboRed : Color.gray.opacity(0.3), lineWidth: 2))
            Text(label).font(.caption).fontWeight(hot ? .bold : .regular)
                .foregroundColor(hot ? .bimboRed : .gray)
                .multilineTextAlignment(.center)
        }
    }
}
