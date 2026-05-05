//
//  OsitoFABView.swift
//  Bimbo
//
//  Componente reutilizable del Osito Bimbo como Floating Action Button.
//  Aparece en varias pantallas del flujo mostrando tips contextuales.
//  Al tocar, muestra/oculta una burbuja de texto con consejos.
//

import SwiftUI

/// Botón flotante del Osito Bimbo con burbuja de tip contextual.
/// Reutilizable en cualquier pantalla del flujo.
struct OsitoFABView: View {
    
    /// Texto del tip que muestra el Osito (opcional ahora).
    var tip: String = ""
    var agent: OsitoAgent? = nil
    
    /// Controla si la hoja de chat está visible.
    @State private var isOpen: Bool = false
    
    /// Animación pulsante del borde rojo.
    @State private var borderOpacity: Double = 0.3
    
    var body: some View {
        if agent != nil {
            VStack(alignment: .trailing, spacing: 8) {
                
                
                // MARK: - Botón del Osito
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7))
                    {
                        isOpen.toggle()
                    }
                }) {
                    ZStack {
                        // Imagen del Osito (placeholder: usa un emoji como fallback)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                        
                        Image("OsitoBimbo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            .clipShape(Circle())
                        
                        // Borde rojo pulsante
                        Circle()
                            .stroke(Color.bimboRed, lineWidth: 4)
                            .frame(width: 60, height: 60)
                            .opacity(borderOpacity)
                    }
                }
                .onAppear {
                    // Animación de pulso infinita en el borde
                    withAnimation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        borderOpacity = 0.8
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OyeOsitoTriggered"))) { notification in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isOpen = true
                    }
                    if let comando = notification.object as? String, !comando.isEmpty {
                        Task {
                            await agent?.vendedorDicta(comando)
                        }
                    }
                }
                
                // MARK: - Hoja de Chat
            }
            .sheet(isPresented: $isOpen) {
                if let agent = agent {
                    ChatView(agent: agent)
                        .presentationDetents([.medium, .large])
                } else {
                    Text("Cargando chat...")
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - ChatView

struct ChatView: View {
    let agent: OsitoAgent
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(agent.mensajes) { msg in
                            HStack {
                                if msg.rol == .vendedor { Spacer() }
                                Text(msg.texto)
                                    .padding(16)
                                    .background(msg.rol == .vendedor ? Color.bimboNavy : Color.bimboCream)
                                    .foregroundColor(msg.rol == .vendedor ? .white : .black)
                                    .cornerRadius(20)
                                    .frame(maxWidth: 300, alignment: msg.rol == .vendedor ? .trailing : .leading)
                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                if msg.rol == .osito { Spacer() }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    if let last = agent.mensajes.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onChange(of: agent.mensajes.count) { _, _ in
                    if let last = agent.mensajes.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            .navigationTitle("Asistente Osito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
//        Color.gray.opacity(0.1).ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                OsitoFABView(tip: "¡Hola! Asegúrate de llevar el diablito, ¡son varias unidades hoy!")
                Spacer()
            }
        }
    }
}
