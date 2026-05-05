//
//  NotesView.swift
//  Bimbo
//
//  Vista de notas del día con texto libre y etiquetas rápidas.
//

import SwiftUI

struct NotasViewIA: View {
    let agent: OsitoAgent
    let tiendaId: Int
    @State private var nota: String = ""
    @State private var etiquetas: Set<String> = []
    
    private let etiquetasDisponibles = ["Cliente molesto", "Cambio de horario", "Promoción", "Falla pago", "Recomendación"]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 7, title: "Notas del día", subtitle: "Para el siguiente vendedor")
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !agent.ultimoMensajeOsito.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Text("🐻").font(.title)
                                Text(agent.ultimoMensajeOsito).font(.body).padding(12)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nota").font(.subheadline).fontWeight(.bold)
                            TextEditor(text: $nota)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                            Text("O dicta con el micrófono del Osito 🎤").font(.caption).foregroundColor(.gray)
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Etiquetas").font(.subheadline).fontWeight(.bold)
                            ForEach(etiquetasDisponibles, id: \.self) { e in
                                Button { toggle(e) } label: {
                                    HStack {
                                        Image(systemName: etiquetas.contains(e) ? "checkmark.circle.fill" : "circle")
                                        Text(e)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .fill(etiquetas.contains(e) ? Color.bimboNavy.opacity(0.1) : Color.white))
                                    .foregroundColor(etiquetas.contains(e) ? .bimboNavy : .primary)
                                }
                            }
                        }
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(title: "Guardar y finalizar", iconName: "checkmark") {
                    Task {
                        if !nota.isEmpty {
                            await agent.procesarNotaFinal(nota, etiquetas: Array(etiquetas))
                        }
                        await agent.avanzarA(.exito)
                    }
                }
                .padding(24)
            }
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
    
    private func toggle(_ e: String) {
        if etiquetas.contains(e) { etiquetas.remove(e) } else { etiquetas.insert(e) }
    }
}
