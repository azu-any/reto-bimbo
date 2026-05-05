//
//  MapView.swift
//  Bimbo
//
//  Vista de navegación hacia la tienda.
//  Si hay GPS real, lo usa. Si no, simula el recorrido a pie desde un punto
//  cercano a la tienda para que la demo funcione sin moverse físicamente.
//  Todo el flujo de voz es 100% automático — no hay botón de llegada.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - MapView

struct MapView: View {

    // ── Dependencias ────────────────────────────────────────────────────────
    let agent: OsitoAgent
    let location: LocationService
    let tienda: Tienda
    let onLlegada: () -> Void

    // ── Estado del mock walker ───────────────────────────────────────────────
    /// Coordenada actual del "peatón simulado" (solo se usa si no hay GPS real).
    @State private var mockCoord: CLLocationCoordinate2D? = nil
    /// Timer que mueve el peatón step-a-step.
    @State private var mockTimer: Timer? = nil
    /// Paso actual del recorrido simulado.
    @State private var mockStep: Int = 0

    // ── Estado del mapa ──────────────────────────────────────────────────────
    @State private var cameraPosition: MapCameraPosition = .automatic

    // ── Estado de distancia y agente ────────────────────────────────────────
    @State private var distancia: Double? = nil
    @State private var ultimoUmbralAvisado: Int = .max
    @State private var yaSaludo: Bool = false
    @State private var llegadaEnProceso: Bool = false

    // ── Constantes ───────────────────────────────────────────────────────────
    /// Umbral de llegada en metros.
    private let umbralLlegada: Double = 50
    /// Hitos de distancia (metros) en que el Osito habla.
    private let umbralesAviso = [100]
    /// Velocidad de simulación: metros por tick (1 tick/s). Ajustado a 25 m/s para que el pitch sea rápido (llega en ~4 seg).
    private let metrosPorTick: Double = 25

    // ── Coordenada destino ──────────────────────────────────────────────────
    private var destino: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: tienda.latitud, longitude: tienda.longitud)
    }

    // ── Coordenada activa (real o simulada) ────────────────────────────────
    private var coordActiva: CLLocationCoordinate2D? {
        return mockCoord
    }

    // ── Computed display ────────────────────────────────────────────────────
    private var haLlegado: Bool { (distancia ?? .infinity) <= umbralLlegada }

    private var distanciaFormateada: String {
        guard let d = distancia else { return "..." }
        return d >= 1000 ? String(format: "%.1f km", d / 1000) : "\(Int(d)) m"
    }

    private var etaFormateado: String {
        guard let d = distancia else { return "--:--" }
        let velMs = 5_000.0 / 3_600.0          // 5 km/h caminando
        let llegada = Date().addingTimeInterval(d / velMs)
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: llegada)
    }

    /// Fracción de progreso 0…1 desde la distancia inicial.
    @State private var distanciaInicial: Double? = nil
    private var progreso: Double {
        guard let ini = distanciaInicial, let d = distancia, ini > 0 else { return 0 }
        return min(1, max(0, 1 - d / ini))
    }

    // MARK: - Body ────────────────────────────────────────────────────────────

    var body: some View {
        ZStack(alignment: .top) {

            // ── Mapa ────────────────────────────────────────────────────────
            Map(position: $cameraPosition) {
                // Pin de la tienda (Osito)
                Annotation(tienda.nombre, coordinate: destino) {
                    VStack(spacing: -4) {
                        Image("OsitoBimbo")
                            .resizable().scaledToFit()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay { Circle().stroke(Color.bimboNavy, lineWidth: 2) }
                            .shadow(radius: 6)
                        Triangle()
                            .fill(Color.bimboNavy)
                            .frame(width: 14, height: 10)
                    }
                }

                // Peatón simulado (forzado para la demo)
                if let mock = mockCoord {
                    Annotation("Tú", coordinate: mock) {
                        ZStack {
                            Circle()
                                .fill(Color.bimboRed.opacity(0.25))
                                .frame(width: 28, height: 28)
                                .modifier(PingModifier())
                            Circle()
                                .fill(Color.bimboRed)
                                .frame(width: 14, height: 14)
                                .overlay { Circle().stroke(.white, lineWidth: 2) }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()

            // ── Tarjeta superior ────────────────────────────────────────────
            topCard
        }
        // ── Panel inferior automático ────────────────────────────────────────
        .sheet(isPresented: .constant(true)) {
            autoStatusPanel
                .presentationDetents([.fraction(0.28), .medium])
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }

        // ── Ciclo de vida ────────────────────────────────────────────────────
        .onAppear {
            centrarCamara()
            iniciarMock()
        }
        .onDisappear {
            detenerMock()
        }
    }

    // MARK: - Subvistas ───────────────────────────────────────────────────────

    private var topCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Próxima parada")
                        .font(.caption).fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.7))
                    Text(tienda.nombre)
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(.bimboNavy)
                }
                Spacer()
                Text(etaFormateado)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.bimboNavy)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.bimboCream))
            }
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse").font(.caption)
                Text(tienda.direccion).font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
            }
            .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16).padding(.top, 56)
    }

    /// Panel inferior totalmente automático: sin botón, solo estado e indicador.
    private var autoStatusPanel: some View {
        VStack(spacing: 16) {
            // Distancia + ETA
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(distanciaFormateada)
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.bimboNavy)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.4), value: distanciaFormateada)
                    Text("Distancia restante")
                        .font(.caption).foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(etaFormateado)
                        .font(.title3).fontWeight(.bold)
                    Text("ETA").font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Barra de progreso animada
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.bimboGray)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(colors: [Color.bimboNavy, Color.bimboRed],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * progreso)
                        .animation(.easeInOut(duration: 0.8), value: progreso)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 24)

            // Estado textual
            HStack(spacing: 8) {
                if haLlegado {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("¡Llegaste! El Osito te saluda...")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.green)
                } else {
                    // Ícono de caminante animado
                    Image(systemName: "figure.walk")
                        .foregroundColor(.bimboNavy)
                        .symbolEffect(.bounce, options: .repeating)
                    Text("Simulando recorrido...")
                        .font(.subheadline).foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Mock walker ─────────────────────────────────────────────────────

    /// Genera puntos de inicio simulados cerca de la tienda para un demo rápido.
    private var mockOrigen: CLLocationCoordinate2D {
        // ~150 m al norte/oeste para que el demo sea muy rápido (pitch)
        CLLocationCoordinate2D(
            latitude:  tienda.latitud  + 0.001,
            longitude: tienda.longitud - 0.001
        )
    }

    /// Inicia el timer de simulación (siempre forzado para el pitch).
    private func iniciarMock() {

        mockCoord = mockOrigen
        mockStep  = 0
        distanciaInicial = distanciaEntre(mockOrigen, destino)
        distancia = distanciaInicial

        // Saludo inicial antes de empezar a caminar
        yaSaludo = true
        agent.voice.hablar("¡Qué onda compa! Vamos a \(tienda.nombre), a darle con todo.")

        mockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                tickMock()
            }
        }
    }

    private func detenerMock() {
        mockTimer?.invalidate()
        mockTimer = nil
    }

    /// Avanza un paso de simulación: interpola hacia el destino.
    private func tickMock() {
        guard var current = mockCoord else { return }

        let d = distanciaEntre(current, destino)

        // Actualizar distancia
        withAnimation(.easeInOut(duration: 0.5)) {
            self.distancia = d
        }
        // Guardar distancia inicial la primera vez
        if distanciaInicial == nil { distanciaInicial = d }

        // Mover hacia destino
        let fraccion = min(1.0, metrosPorTick / max(d, 1))
        current = interpolar(desde: current, hasta: destino, fraccion: fraccion)

        withAnimation(.linear(duration: 0.9)) {
            mockCoord = current
        }

        // Actualizar cámara para seguir al peatón suavemente
        let center = CLLocationCoordinate2D(
            latitude:  (current.latitude  + destino.latitude)  / 2,
            longitude: (current.longitude + destino.longitude) / 2
        )
        let paddedMetros = max(d * 2.5, 200)
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            latitudinalMeters: paddedMetros,
            longitudinalMeters: paddedMetros
        ))

        // Disparar hitos de voz
        procesarHitos(distancia: d)

        // Llegada
        if d <= umbralLlegada && !llegadaEnProceso {
            detenerMock()
            dispararLlegada()
        }
    }

    // MARK: - Lógica compartida ───────────────────────────────────────────────

    private func procesarHitos(distancia d: Double) {
        // Saludo inicial (si por alguna razón no se dio ya)
        if !yaSaludo, d > Double(umbralesAviso.first ?? 100) {
            yaSaludo = true
            agent.voice.hablar("¡Qué onda compa! Vamos a \(tienda.nombre), a darle con todo.")
        }

        // Hitos intermedios
        for umbral in umbralesAviso where d <= Double(umbral) && ultimoUmbralAvisado > umbral {
            ultimoUmbralAvisado = umbral
            agent.voice.hablar("¡Ya casi llegamos, un último esfuerzo!")
            break
        }
    }

    private func dispararLlegada() {
        llegadaEnProceso = true
        Task {
            // Saludo de llegada completo con historial
            await agent.iniciarVisita(tienda: tienda)
            // Dar tiempo al Osito para terminar de hablar
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run { onLlegada() }
        }
    }

    private func centrarCamara() {
        let origen = mockOrigen

        let center = CLLocationCoordinate2D(
            latitude:  (origen.latitude  + destino.latitude)  / 2,
            longitude: (origen.longitude + destino.longitude) / 2
        )
        cameraPosition = .region(MKCoordinateRegion(
            center: center, latitudinalMeters: 1_200, longitudinalMeters: 1_200
        ))
    }

    // MARK: - Geometría ────────────────────────────────────────────────────────

    /// Distancia en metros entre dos coordenadas.
    private func distanciaEntre(_ a: CLLocationCoordinate2D,
                                 _ b: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: a.latitude, longitude: a.longitude)
            .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
    }

    /// Interpolación lineal entre dos coordenadas.
    private func interpolar(desde a: CLLocationCoordinate2D,
                             hasta b: CLLocationCoordinate2D,
                             fraccion t: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude:  a.latitude  + (b.latitude  - a.latitude)  * t,
            longitude: a.longitude + (b.longitude - a.longitude) * t
        )
    }
}

// MARK: - Formas auxiliares ────────────────────────────────────────────────────

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

struct FloatingModifier: ViewModifier {
    @State private var isFloating = false
    func body(content: Content) -> some View {
        content.offset(y: isFloating ? -10 : 10).onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { isFloating = true }
        }
    }
}

struct PingModifier: ViewModifier {
    @State private var isPinging = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPinging ? 2 : 1)
            .opacity(isPinging ? 0 : 0.5)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) { isPinging = true }
            }
    }
}
