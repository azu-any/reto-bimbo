//
//  ConfirmView.swift
//  Bimbo
//
//  Vista de confirmación del pedido con aprobación dual.
//

import SwiftUI

struct ConfirmacionViewIA: View {
    let agent: OsitoAgent
    
    @State private var aprobadoVendedor = false
    @State private var aprobadoTendero = false
    @State private var cantidadesAjustadas: [String: Int] = [:]
    
 
    private var puedeConfirmar: Bool {
        aprobadoVendedor && aprobadoTendero
    }
    
    private var totalCajas: Int {
        agent.sugerenciasGeneradas.reduce(0) { acc, s in
            acc + (cantidadesAjustadas[s.productoId] ?? s.cantidadSugerida)
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepHeaderView(step: 6, title: "Confirmación", subtitle: "Revisión final del pedido")
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mensaje del Osito
                        if !agent.ultimoMensajeOsito.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                Text("🐻").font(.title)
                                Text(agent.ultimoMensajeOsito)
                                    .font(.body)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            }
                        }
                        
                        orderSummary
                        approvalSection
                    }
                    .padding(24)
                    .padding(.bottom, 120)
                }
            }
            
            VStack {
                Spacer()
                PrimaryButtonView(
                    title: puedeConfirmar ? "Confirmar Pedido" : "Faltan firmas",
                    iconName: "checkmark",
                    variant: puedeConfirmar ? .success : .primary,
                    disabled: !puedeConfirmar
                ) {
                    Task {
                        await confirmarYAvanzar()
                    }
                }
                .padding(24)
            }
            
            VStack { Spacer(); HStack { OsitoFABView(agent: agent); Spacer() } }
        }
    }
    
    // MARK: - Resumen del pedido (datos del agente)
    
    private var orderSummary: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "cart.fill").foregroundColor(.bimboNavy)
                    Text("Resumen").fontWeight(.bold)
                }
                Spacer()
                Text("\(totalCajas) unidades")
                    .font(.subheadline).foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.gray.opacity(0.03))
            
            Divider()
            
            VStack(spacing: 12) {
                if agent.sugerenciasGeneradas.isEmpty {
                    Text("No hay sugerencias para confirmar.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(agent.sugerenciasGeneradas, id: \.productoId) { s in
                        productRow(s)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        )
    }
    
    private func productRow(_ s: GenerarSugerenciasTool.Sugerencia) -> some View {
        let cantidad = cantidadesAjustadas[s.productoId] ?? s.cantidadSugerida
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(s.nombre).fontWeight(.semibold)
                Text(s.justificacion)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
            // Stepper para ajustar cantidad
            HStack(spacing: 8) {
                Button {
                    let nueva = max(0, cantidad - 1)
                    cantidadesAjustadas[s.productoId] = nueva
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Text("\(cantidad)")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
                    .frame(minWidth: 28)
                Button {
                    cantidadesAjustadas[s.productoId] = cantidad + 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.bimboNavy)
                }
            }
        }
        .font(.subheadline)
    }
    
    // MARK: - Aprobaciones
    
    private var approvalSection: some View {
        VStack(spacing: 16) {
            Text("Aprobación requerida")
                .font(.body)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                approvalButton(label: "Vendedor", initial: "C", approved: aprobadoVendedor) {
                    aprobadoVendedor.toggle()
                }
                approvalButton(label: "Tendero", initial: "L", approved: aprobadoTendero) {
                    aprobadoTendero.toggle()
                }
            }
        }
    }
    
    private func approvalButton(label: String, initial: String, approved: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(approved ? Color.green : Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    if approved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Text(initial)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray.opacity(0.4))
                    }
                }
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(approved ? .green : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(approved ? Color.green.opacity(0.05) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(approved ? Color.green : Color.gray.opacity(0.2), lineWidth: 2)
                    )
            )
        }
    }
    
    // MARK: - Confirmación
    
    private func confirmarYAvanzar() async {
        guard let visita = agent.visitaActual else { return }
        let entrega = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        for s in agent.sugerenciasGeneradas {
            let cantidad = cantidadesAjustadas[s.productoId] ?? s.cantidadSugerida
            guard cantidad > 0 else { continue }
            visita.itemsConfirmados.append(ItemPedido(
                productoId: s.productoId,
                nombreProducto: s.nombre,
                unidades: cantidad,
                fechaEntrega: entrega
            ))
        }
        visita.pedidoConfirmado = true
        
        await agent.avanzarA(.notas)
    }
}
