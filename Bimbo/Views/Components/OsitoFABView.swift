//
//  OsitoFABView.swift
//  Bimbo
//
//  Componente reutilizable del Osito Bimbo como Floating Action Button.
//  Aparece en varias pantallas del flujo mostrando tips contextuales.
//  Al tocar, muestra/oculta una burbuja de texto con consejos.
//

// OsitoFABView.swift
import SwiftUI

struct OsitoFABView: View {
    let agent: OsitoAgent
    let tip: String?
    @State private var mostrarChat = false
    @State private var pulsando = false
    
    init(agent: OsitoAgent, tip: String? = nil) {
        self.agent = agent
        self.tip = tip
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !agent.ultimoMensajeOsito.isEmpty {
                bocadillo
                    .transition(.scale.combined(with: .opacity))
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                // FAB del osito (toca para abrir chat)
                Button { mostrarChat = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                            .scaleEffect(agent.voice.hablando ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: agent.voice.hablando)
                        Text("🐻").font(.system(size: 36))
                        if agent.voice.hablando {
                            Circle()
                                .stroke(Color.bimboRed, lineWidth: 3)
                                .frame(width: 70, height: 70)
                                .scaleEffect(pulsando ? 1.3 : 1.0)
                                .opacity(pulsando ? 0 : 0.7)
                                .onAppear {
                                    withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                                        pulsando = true
                                    }
                                }
                        }
                    }
                }
                
                // Botón de micrófono (mantén presionado para hablar)
                Button {
                    toggleEscucha()
                } label: {
                    ZStack {
                        Circle()
                            .fill(agent.voice.escuchando ? Color.bimboRed : Color.bimboNavy)
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        Image(systemName: agent.voice.escuchando ? "waveform" : "mic.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(agent.voice.escuchando ? 1.15 : 1.0)
                    .animation(.spring, value: agent.voice.escuchando)
                }
                .disabled(agent.procesando || agent.voice.hablando)
            }
        }
        .padding(.leading, 16)
        .padding(.bottom, 100)
        .sheet(isPresented: $mostrarChat) {
            OsitoChatSheet(agent: agent)
        }
    }
    
    private var bocadillo: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(agent.ultimoMensajeOsito.isEmpty ? (tip ?? "") : agent.ultimoMensajeOsito)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                )
                .frame(maxWidth: 260, alignment: .leading)
        }
    }
    
    // OsitoFABView.swift  — solo se muestra la función modificada; el resto es igual al original
    private func toggleEscucha() {
        if agent.voice.escuchando {
            agent.voice.detenerEscucha()
        } else {
            agent.voice.iniciarEscucha { texto in
                Task { @MainActor in
                    switch agent.pasoActual {
                    case .recomendacionIA:          // antes era .ventas
                        await agent.procesarVozEnVentas(texto)
                    case .notas:
                        await agent.procesarNotaFinal(texto, etiquetas: [])
                    default:
                        await agent.vendedorDicta(texto)
                    }
                }
            }
        }
    }
}

// MARK: - Sheet de chat completo
struct OsitoChatSheet: View {
    let agent: OsitoAgent
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(agent.mensajes) { m in
                            BurbujaChat(mensaje: m).id(m.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: agent.mensajes.count) {
                    if let last = agent.mensajes.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            .navigationTitle("Osito Bimbo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

struct BurbujaChat: View {
    let mensaje: MensajeOsito
    var body: some View {
        HStack {
            if mensaje.rol == .vendedor { Spacer() }
            Text(mensaje.texto)
                .padding(12)
                .background(mensaje.rol == .osito ? Color.orange.opacity(0.15) : Color.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: 280, alignment: mensaje.rol == .osito ? .leading : .trailing)
            if mensaje.rol == .osito { Spacer() }
        }
    }
}
