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
    let onBack: () -> Void
    @State private var gestionados: Set<String> = []
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()
            VStack(spacing: 0) {
                StepHeaderView(step: 2, title: "Revisión de anaquel", subtitle: "Productos por caducar")
                ScrollView {
                    VStack(spacing: 16) {
                        if MockDataService.productosCaducidad.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundColor(.green)
                                Text("Todo en orden — sin productos por caducar.")
                                    .multilineTextAlignment(.center).foregroundColor(.gray)
                            }.padding(48)
                        } else {
                            ForEach(MockDataService.productosCaducidad, id: \.id) { p in
                                tarjeta(p)
                            }
                        }
                    }
                    .padding(24).padding(.bottom, 100)
                }
            }
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.bimboNavy)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                    }
                    
                    PrimaryButtonView(title: "Continuar", iconName: "chevron.right") {
                        // La IA transiciona al siguiente estado lógicamente
                        Task { await agent.avanzarA(.recomendacionIA) }
                        onNext()
                    }
                }
                .padding(24)
            }
        }
    }
    
    private func tarjeta(_ p: Producto) -> some View {
        let isManaged = gestionados.contains(String(p.id))
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Imagen del producto
                Image(p.imagenNombre.isEmpty ? "placeholder" : p.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(p.nombre).font(.body).fontWeight(.bold)
                    if let lote = p.lote {
                        Text("Lote: \(lote)")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    Text("Cantidad: \(p.cantidad)")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                
                }
            }
            
            Text("Caduca en 1 semana")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(.red)
                .background(RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(0.1))
                )
            Button {
                withAnimation { _ = gestionados.insert(String(p.id)) }
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Retirar")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12)
                .stroke(isManaged ? Color.green : Color.bimboNavy, lineWidth: 2))
                .foregroundColor(isManaged ? .green : .bimboNavy)
            }
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
