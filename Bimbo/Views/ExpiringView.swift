//
//  ExpiringView.swift
//  Bimbo
//
//  Vista de revisión de productos próximos a caducar.
//  Muestra productos con su fecha de caducidad y acción sugerida.
//  Los productos gestionados desaparecen con animación.
//

import SwiftUI

/// Pantalla de gestión de productos por caducar en el anaquel usando IA.
struct ExpiringView: View {
    let agent: OsitoAgent
    let onNext: () -> Void
    @State private var gestionados: Set<String> = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 2, title: "Revisión de anaquel", subtitle: "Productos por caducar")
                ScrollView {
                    VStack(spacing: 16) {
                        if agent.productosPorCaducar.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundColor(.green)
                                Text("Todo en orden — sin productos por caducar.")
                                    .multilineTextAlignment(.center).foregroundColor(.gray)
                            }.padding(48)
                        } else {
                            ForEach(agent.productosPorCaducar, id: \.productoId) { p in
                                tarjeta(p)
                            }
                        }
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(title: "Continuar", iconName: "chevron.right") {
                    // La IA transiciona al siguiente estado lógicamente
                    Task { await agent.avanzarA(.recomendacionIA) } // Nota: Ajustado a recomendacionIA en lugar de resurtido porque resurtido estaba comentado
                    onNext()
                }
                .padding(24)
            }
        }
    }
    
    private func tarjeta(_ p: CalcularCaducidadTool.ProductoCaducidad) -> some View {
        let isManaged = gestionados.contains(p.productoId)
        return VStack(alignment: .leading, spacing: 12) {
            Text(p.nombre).font(.body).fontWeight(.bold)
            Text("Caduca en \(p.diasRestantes) días")
                .font(.caption).fontWeight(.bold)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 6).fill(p.urgencia == "alta" ? Color.red.opacity(0.1) : Color.yellow.opacity(0.1)))
                .foregroundColor(p.urgencia == "alta" ? .red : .orange)
            Button {
                withAnimation { _ = gestionados.insert(p.productoId) }
            } label: {
                HStack {
                    Image(systemName: p.accionSugerida == "Retirar" ? "trash.fill" : "tag.fill")
                    Text(isManaged ? "Hecho ✓" : p.accionSugerida).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(isManaged ? Color.green : Color.bimboNavy))
                .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(.white)
    }
}
