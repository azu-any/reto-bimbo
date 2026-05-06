//
//  NotesView.swift
//  Bimbo
//
//  Vista de notas del día con texto libre y etiquetas rápidas.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    let agent: OsitoAgent
    let onNext: () -> Void
    let tiendaId: Int
    @State private var viewModel = NotesViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                StepHeaderView(step: 5, title: "Notas del día", subtitle: "Ayuda a mejorar la ruta")
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Di \"Oye Osito\" para escribir con voz")
                            .foregroundColor(viewModel.isRecording ? .red : .gray)

                        
                        noteInput
                        quickChips
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            
            VStack {
                Spacer()
                PrimaryButtonView(title: "Guardar y finalizar", iconName: "chevron.right") {
                    Task {
                        if !viewModel.contenidoNota.isEmpty {
                            await agent.procesarNotaFinal(viewModel.contenidoNota, etiquetas: Array(viewModel.etiquetasSeleccionadas))
                        }
                        await agent.avanzarA(.exito)
                        onNext()
                    }
                }
                .padding(24)
                .background(LinearGradient(colors: [Color(UIColor.systemGray6).opacity(0), Color(UIColor.systemGray6)], startPoint: .top, endPoint: .bottom))
            }
        }
    }
    
    // MARK: - Campo de texto
    private var noteInput: some View {
        VStack(spacing: 0) {
            
            
            TextEditor(text: $viewModel.contenidoNota)
                .frame(minHeight: 128)
                .scrollContentBackground(.hidden)
                .padding(4)
            
            Divider()
            

            
            HStack {
                Text("\(viewModel.conteoCaracteres) caracteres")
                    .font(.caption).foregroundColor(.gray.opacity(0.4))
                Spacer()
            }
            .padding(.horizontal, 8).padding(.vertical, 8)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2))
    }
    
    // MARK: - Etiquetas rápidas
    private var quickChips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Etiquetas rápidas").font(.subheadline).fontWeight(.bold)
            
            FlowLayout(spacing: 8) {
                ForEach(viewModel.etiquetasDisponibles, id: \.self) { etiqueta in
                    Button(action: { viewModel.agregarEtiqueta(etiqueta) }) {
                        Text(etiqueta)
                            .font(.subheadline)
                            .foregroundColor(viewModel.etiquetasSeleccionadas.contains(etiqueta) ? .bimboNavy : .gray)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(Capsule().stroke(
                                        viewModel.etiquetasSeleccionadas.contains(etiqueta) ? Color.bimboNavy : Color.gray.opacity(0.2),
                                        lineWidth: 1
                                    ))
                            )
                    }
                }
            }
        }
    }
}

/// Layout de flujo horizontal que envuelve elementos cuando se acaba el espacio.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

//#Preview { NotesView(onNext: {}, tiendaId: 101) }
