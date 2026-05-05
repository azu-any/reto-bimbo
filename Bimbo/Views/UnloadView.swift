//
//  UnloadView.swift
//  Bimbo
//
//  Vista de descarga de productos del camión.
//  Muestra un checklist de productos encargados la semana pasada.
//  El vendedor marca cada producto conforme lo baja del camión.
//  Solo puede avanzar cuando todos están marcados.
//

import SwiftUI

struct UnloadViewIA: View {
    let agent: OsitoAgent
    @State private var checked: Set<String> = []
    
    private var productos: [ConsultarHistorialTool.ItemHistorico] {
        agent.pedidoAnteriorParaDescarga
    }
    private var todosListos: Bool {
        productos.isEmpty || checked.count == productos.count
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 1, title: "Bajar del camión", subtitle: "Pedido de la semana pasada")
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        progreso
                        if productos.isEmpty {
                            emptyState
                        } else {
                            ForEach(productos, id: \.productoId) { p in
                                fila(p)
                            }
                        }
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: todosListos ? "Continuar" : "Selecciona todo",
                    iconName: "chevron.right",
                    disabled: !todosListos
                ) {
                    Task { await agent.avanzarA(.caducidad) }
                }
                .padding(24)
            }
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox").font(.system(size: 48)).foregroundColor(.gray)
            Text("Primera visita — no hay pedido previo.")
                .multilineTextAlignment(.center).foregroundColor(.gray)
        }.padding(48).frame(maxWidth: .infinity)
    }
    
    private var progreso: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progreso").font(.subheadline).foregroundColor(.gray)
                Spacer()
                Text("\(checked.count)/\(productos.count) cajas")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.bimboNavy)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4).fill(Color.bimboNavy)
                        .frame(width: g.size.width * (productos.isEmpty ? 0 : Double(checked.count) / Double(productos.count)))
                }
            }.frame(height: 8)
        }
    }
    
    private func fila(_ p: ConsultarHistorialTool.ItemHistorico) -> some View {
        let isChecked = checked.contains(p.productoId)
        return Button {
            if isChecked { checked.remove(p.productoId) }
            else { checked.insert(p.productoId) }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isChecked ? Color.green.opacity(0.1) : Color.bimboCream)
                        .frame(width: 48, height: 48)
                    Image(systemName: "shippingbox.fill").font(.title3)
                        .foregroundColor(isChecked ? .green : .bimboNavy)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(p.nombre).font(.body).fontWeight(.semibold)
                        .strikethrough(isChecked).foregroundColor(isChecked ? .gray : .primary)
                    Text("\(p.unidades) cajas").font(.caption).foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                    Circle().stroke(isChecked ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isChecked {
                        Circle().fill(Color.green).frame(width: 24, height: 24)
                            .overlay(Image(systemName: "checkmark").font(.caption).fontWeight(.bold).foregroundColor(.white))
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(isChecked ? Color.green.opacity(0.05) : Color.white))
        }
        .buttonStyle(.plain)
    }
}
