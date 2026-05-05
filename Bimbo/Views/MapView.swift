//
//  MapView.swift
//  Bimbo
//
//  Vista del mapa que guía al vendedor a la siguiente tienda.
//  Muestra un mapa simulado con la posición actual y destino,
//  distancia restante, ETA y un botón que se activa al llegar.
//

import SwiftUI

/// Pantalla de navegación simulada hacia la tienda destino.
struct MapView: View {
    
    /// Acción para avanzar al siguiente paso.
    let onNext: () -> Void
    
    /// Datos de la tienda destino.
    let tienda: Tienda
    
    @State private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack {
            // MARK: - Fondo de mapa simulado
            mapBackground
            
            VStack(spacing: 0) {
                // MARK: - Tarjeta superior con info de la tienda
                topCard
                
                Spacer()
                
                // MARK: - Panel inferior con distancia y botón
                bottomSheet
            }
        }
        .onAppear {
            viewModel.iniciarSimulacion()
        }
        .onDisappear {
            viewModel.detenerSimulacion()
        }
        .onChange(of: viewModel.haLlegado) { _, llegó in
            if llegó {
                // Auto-transición al llegar (con delay como en el sample TS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onNext()
                }
            }
        }
    }
    
    // MARK: - Mapa de fondo simulado
    
    private var mapBackground: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            // Cuadrícula simulada
            GridPattern()
                .opacity(0.15)
            
            // Pin de destino (Osito)
            VStack(spacing: -4) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(radius: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.bimboNavy, lineWidth: 2)
                    )
                    .overlay(
                        Text("🐻")
                            .font(.title)
                    )
                
                // Triángulo del pin
                Triangle()
                    .fill(Color.bimboNavy)
                    .frame(width: 16, height: 12)
            }
            .offset(y: -100)
            .modifier(FloatingModifier())
            
            // Pin de posición actual
            ZStack {
                Circle()
                    .fill(Color.bimboRed.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .modifier(PingModifier())
                
                Circle()
                    .fill(Color.bimboRed)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
            }
            .offset(
                x: viewModel.haLlegado ? 0 : -50,
                y: viewModel.haLlegado ? -100 : 100
            )
            .animation(.linear(duration: 8), value: viewModel.haLlegado)
        }
    }
    
    // MARK: - Tarjeta superior
    
    private var topCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Próxima parada")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                    
                    Text(tienda.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.bimboNavy)
                }
                
                Spacer()
                
                Text(viewModel.etaFormateado)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.bimboCream)
                    )
            }
            
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                Text(tienda.direccion)
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
    
    // MARK: - Panel inferior
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 48, height: 6)
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            // Distancia y ETA
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.distancia)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.bimboNavy)
                        Text("m")
                            .font(.body)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                    }
                    Text("Distancia restante")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.horaETA)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("ETA")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            // Botón de llegada
            PrimaryButtonView(
                title: viewModel.haLlegado ? "Llegué a la tienda" : "En camino...",
                iconName: "location.fill",
                disabled: !viewModel.haLlegado,
                pulsating: viewModel.haLlegado,
                action: onNext
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: -8)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Componentes auxiliares

/// Patrón de cuadrícula SVG para simular un mapa.
struct GridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 40
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Líneas verticales
                var x: CGFloat = 0
                while x <= width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                    x += spacing
                }
                
                // Líneas horizontales
                var y: CGFloat = 0
                while y <= height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.bimboNavy, lineWidth: 0.5)
        }
    }
}

/// Forma triangular para el pin del mapa.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

/// Animación de flotación vertical para el pin de destino.
struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -10 : 10)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isFloating = true
                }
            }
    }
}

/// Animación de ping (expansión) para el indicador de posición actual.
struct PingModifier: ViewModifier {
    @State private var isPinging = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPinging ? 2.0 : 1.0)
            .opacity(isPinging ? 0.0 : 0.5)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isPinging = true
                }
            }
    }
}

// MARK: - Preview

#Preview {
    MapView(
        onNext: {},
        tienda: MockDataService.tiendaActual
    )
}
