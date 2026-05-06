//
//  OsitoFABView.swift
//  Bimbo
//
//  Floating Action Button del Osito Bimbo con chat integrado y botón push-to-talk.
//  Cuando se detecta "Oye Osito" el sheet se abre y el micrófono arranca solo.
//

import SwiftUI
import Speech
import AVFoundation

// MARK: - OsitoFABView

struct OsitoFABView: View {

    var tip: String = ""
    var agent: OsitoAgent? = nil

    @State private var isOpen: Bool = false
    @State private var borderOpacity: Double = 0.3
    // Trigger para que el ChatView active el PTT automáticamente
    @State private var autoActivarMic: Bool = false

    var body: some View {
        if agent != nil {
            VStack(alignment: .trailing, spacing: 8) {

                // MARK: Transcripción flotante (solo durante captura activa)
                if let tx = agent?.voice.transcripcion, !tx.isEmpty,
                   agent?.voice.capturandoComando == true {
                    Text(tx)
                        .font(.caption)
                        .padding(10)
                        .background(.black.opacity(0.82))
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                        .shadow(radius: 4)
                        .padding(.trailing, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.easeInOut, value: tx)
                }

                // MARK: Botón flotante del Osito
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isOpen = true
                    }
                } label: {
                    ZStack {
                        Circle().fill(.white).frame(width: 60, height: 60)

                        Image("OsitoBimbo")
                            .resizable().scaledToFit()
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            .clipShape(Circle())

                        if let a = agent {
                            Circle()
                                .stroke(
                                    a.voice.capturandoComando ? Color.green : Color.bimboRed,
                                    lineWidth: a.voice.capturandoComando ? 6 : 4
                                )
                                .frame(width: 60, height: 60)
                                .opacity(borderOpacity)
                                .scaleEffect(a.voice.capturandoComando ? 1.15 : 1.0)
                                .animation(.spring(), value: a.voice.capturandoComando)

                            if a.voice.capturandoComando {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                    .offset(x: 22, y: -22)
                                    .transition(.scale)
                            }
                        }
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        borderOpacity = 0.8
                    }
                }
                // "Oye Osito" detectado → abrir sheet + activar mic automáticamente
                .onReceive(NotificationCenter.default.publisher(
                    for: Notification.Name("OyeOsitoTriggered"))
                ) { notification in
                    let raw = notification.object as? String ?? ""
                    print("🐻 OsitoFAB notificación: '\(raw)'")
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isOpen = true
                    }
                    if raw.isEmpty {
                        // Solo trigger de wake-word → activar mic en el chat
                        autoActivarMic = true
                    } else {
                        // Texto ya capturado (ej. App Intent) → enviarlo directo
                        Task { await agent?.vendedorDicta(raw) }
                    }
                }
            }
            .sheet(isPresented: $isOpen, onDismiss: { autoActivarMic = false }) {
                if let a = agent {
                    ChatView(agent: a, activarMicAlAbrir: $autoActivarMic)
                        .presentationDetents([.medium, .large])
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - ChatView con Push-to-Talk

struct ChatView: View {
    let agent: OsitoAgent
    @Environment(\.dismiss) var dismiss

    /// Cuando es true, el botón de mic se activa automáticamente al aparecer la vista.
    @Binding var activarMicAlAbrir: Bool

    // Estado interno del PTT
    @State private var grabando: Bool = false
    @State private var textoEntrada: String = ""
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Lista de mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(agent.mensajes) { msg in
                                HStack {
                                    if msg.rol == .vendedor { Spacer(minLength: 48) }
                                    VStack(alignment: msg.rol == .vendedor ? .trailing : .leading, spacing: 4) {
                                        Text(msg.texto)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                msg.rol == .vendedor ? Color.bimboNavy : Color.bimboCream
                                            )
                                            .foregroundStyle(msg.rol == .vendedor ? Color.white : Color.black)
                                            .cornerRadius(20)
                                            .frame(maxWidth: 300, alignment: msg.rol == .vendedor ? .trailing : .leading)
                                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                    }
                                    if msg.rol == .osito { Spacer(minLength: 48) }
                                }
                                .id(msg.id)
                                .padding(.horizontal)
                            }

                            // Indicador de procesando
                            if agent.procesando {
                                HStack {
                                    TypingIndicator()
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: agent.mensajes.count) { _, _ in
                        withAnimation { scrollToBottom(proxy: proxy) }
                    }
                    .onChange(of: agent.procesando) { _, _ in
                        withAnimation { scrollToBottom(proxy: proxy) }
                    }
                }

                Divider()

                // MARK: Barra inferior: campo de texto + botón PTT
                VStack(spacing: 10) {

                    // Campo de texto para transcripción o escritura manual
                    if !textoEntrada.isEmpty || grabando {
                        HStack {
                            Text(grabando ? (agent.voice.transcripcion.isEmpty ? "Escuchando..." : agent.voice.transcripcion) : textoEntrada)
                                .foregroundStyle(grabando ? .secondary : .primary)
                                .font(.body)
                            Spacer()
                            if !grabando && !textoEntrada.isEmpty {
                                Button {
                                    enviarTexto()
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.bimboNavy)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // Botón micrófono push-to-talk
                    Button {
                        if grabando {
                            detenerGrabacion()
                        } else {
                            iniciarGrabacion()
                        }
                    } label: {
                        ZStack {
                            // Pulso exterior cuando graba
                            if grabando {
                                Circle()
                                    .fill(Color.red.opacity(0.25))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(pulseScale)
                            }

                            Circle()
                                .fill(grabando ? Color.red : Color.bimboNavy)
                                .frame(width: 64, height: 64)
                                .shadow(color: (grabando ? Color.red : Color.bimboNavy).opacity(0.4), radius: 8, y: 4)

                            Image(systemName: grabando ? "stop.fill" : "mic.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .disabled(agent.procesando)
                    .padding(.bottom, 12)
                }
                .padding(.top, 10)
//                .background(Color(.systemBackground))
            }
            .navigationTitle("Osito Bimbo 🐻")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        if grabando { detenerGrabacion() }
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Si llegamos aquí por "Oye Osito", arrancar mic automáticamente
            if activarMicAlAbrir {
                activarMicAlAbrir = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    iniciarGrabacion()
                }
            }
        }
    }

    // MARK: - Push-to-Talk

    private func iniciarGrabacion() {
        guard !grabando, !agent.procesando else { return }
        grabando = true
        textoEntrada = ""

        // Animación de pulso
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }

        agent.voice.iniciarEscucha { texto in
            let limpio = texto.trimmingCharacters(in: .whitespacesAndNewlines)
            grabando = false
            pulseScale = 1.0
            if !limpio.isEmpty {
                textoEntrada = limpio
                // Enviar automáticamente al agente
                Task { await agent.vendedorDicta(limpio) }
                textoEntrada = ""
            }
        }
    }

    private func detenerGrabacion() {
        guard grabando else { return }
        agent.voice.detenerEscucha()
        grabando = false
        pulseScale = 1.0
        // Si hay texto parcial, enviarlo
        let parcial = agent.voice.transcripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        if !parcial.isEmpty {
            Task { await agent.vendedorDicta(parcial) }
            textoEntrada = ""
        }
    }

    private func enviarTexto() {
        guard !textoEntrada.isEmpty else { return }
        let texto = textoEntrada
        textoEntrada = ""
        Task { await agent.vendedorDicta(texto) }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = agent.mensajes.last {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}

// MARK: - Indicador de "escribiendo..."

struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(phase == i ? 1.3 : 0.8)
                    .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: phase)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.bimboCream)
        .cornerRadius(20)
        .onAppear { phase = 0 }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        VStack {
            Spacer()
            HStack {
                Spacer()
                OsitoFABView(tip: "¡Hola!")
            }
        }
    }
}
