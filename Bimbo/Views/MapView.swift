//
//  MapView.swift
//  Bimbo
//
//  Vista del mapa que guía al vendedor a la siguiente tienda.
//  Muestra un mapa simulado con la posición actual y destino,
//  distancia restante, ETA y un botón que se activa al llegar.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    let agent: OsitoAgent
    let tienda: Tienda
    let location: LocationService
    let onLlegada: () -> Void
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var distancia: Double? = nil
    @State private var ultimoUmbralAvisado: Int = .max  // para que el Osito no repita avisos
    @State private var yaSaludo: Bool = false
    
    /// Distancia en metros para considerar "llegado"
    private let umbralLlegada: Double = 130
    
    /// Umbrales en los que el Osito da pistas (en metros)
    private let umbralesAviso = [500, 200, 100, 50]
    
    private var coordenadaTienda: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: tienda.latitud, longitude: tienda.longitud)
    }
    
    var body: some View {
        ZStack {
            // MARK: - Mapa real con MapKit
            Map(position: $cameraPosition) {
                // Marcador de la tienda
                Annotation(tienda.nombre, coordinate: coordenadaTienda) {
                    VStack(spacing: -4) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48, height: 48)
                            .shadow(radius: 6)
                            .overlay(Circle().stroke(Color.bimboNavy, lineWidth: 2))
                            .overlay(Text("🐻").font(.title))
                        Triangle()
                            .fill(Color.bimboNavy)
                            .frame(width: 16, height: 12)
                    }
                }
                
                // Posición del usuario
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topCard
                Spacer()
                bottomSheet
            }
        }
        .onAppear {
            location.solicitarPermisos()
            ajustarCamara()
        }
        .onChange(of: location.ubicacionActual) { _, _ in
            actualizarDistancia()
        }
    }
    
    // MARK: - Tarjeta superior
    
    private var topCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Próxima parada").font(.caption).foregroundColor(.gray).fontWeight(.medium)
                    Text(tienda.nombre).font(.title2).fontWeight(.bold).foregroundColor(.bimboNavy)
                }
                Spacer()
                if let etaStr = etaFormateado {
                    Text(etaStr)
                        .font(.subheadline).fontWeight(.bold).foregroundColor(.bimboNavy)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(Color.bimboCream))
                }
            }
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse").font(.caption)
                Text(tienda.direccion).font(.subheadline)
            }
            .foregroundColor(.gray)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.08), radius: 8, y: 4))
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }
    
    // MARK: - Panel inferior
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 48, height: 6)
                .padding(.top, 12).padding(.bottom, 24)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(distanciaFormateada)
                            .font(.largeTitle).fontWeight(.bold).foregroundColor(.bimboNavy)
                        Text(unidadDistancia)
                            .font(.body).foregroundColor(.gray).fontWeight(.medium)
                    }
                    Text("Distancia restante").font(.caption).foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(etaFormateado ?? "--:--")
                        .font(.title3).fontWeight(.bold).foregroundColor(.primary)
                    Text("ETA").font(.caption).foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24).padding(.bottom, 24)
            
            // Botón principal de llegada (se activa cuando GPS detecta cercanía)
            PrimaryButtonView(
                title: haLlegado ? "Llegué a la tienda" : "En camino...",
                iconName: "location.fill",
                disabled: !haLlegado,
                pulsating: haLlegado,
                action: dispararLlegada
            )
            .padding(.horizontal, 24)
            
            // 🔧 BOTÓN DEMO — fuerza la llegada sin GPS
            Button {
                dispararLlegada()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "hammer.fill")
                    Text("Demo: simular llegada")
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 16)
            
            HStack {
                OsitoFABView(agent: agent)
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            location.solicitarPermisos()
            location.iniciarSeguimiento()   // ← agregar esta línea
            ajustarCamara()
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 16, y: -8)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func dispararLlegada() {
        Task {
            await agent.iniciarVisita(tienda: tienda)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run { onLlegada() }
        }
    }
    
    // MARK: - Cálculos
    
    private var haLlegado: Bool {
        guard let d = distancia else { return false }
        return d <= umbralLlegada
    }
    
    private var distanciaFormateada: String {
        guard let d = distancia else { return "--" }
        if d >= 1000 {
            return String(format: "%.1f", d / 1000)
        }
        return "\(Int(d))"
    }
    
    private var unidadDistancia: String {
        guard let d = distancia else { return "m" }
        return d >= 1000 ? "km" : "m"
    }
    
    private var etaFormateado: String? {
        guard let d = distancia else { return nil }
        // Asume velocidad promedio caminando+conduciendo de ruta urbana: ~25 km/h
        let velocidadMs = 25_000.0 / 3600.0  // ≈ 6.94 m/s
        let segundos = d / velocidadMs
        let llegada = Date().addingTimeInterval(segundos)
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: llegada)
    }
    
    // MARK: - Lógica del Osito durante el trayecto
    
    private func actualizarDistancia() {
        guard let d = location.distanciaA(latitud: tienda.latitud, longitud: tienda.longitud) else { return }
        self.distancia = d
        
        // Saludo inicial al empezar el trayecto
        if !yaSaludo, d > umbralLlegada {
            yaSaludo = true
            Task {
                await agent.ejecutarTurno("""
                El vendedor inició la ruta hacia "\(tienda.nombre)".
                La distancia es de \(Int(d)) metros. Anímalo brevemente y dile que lo guías.
                NO uses tools, solo motiva (1-2 frases).
                """)
            }
            return
        }
        
        // Avisos por umbrales (solo una vez cada uno, decreciendo)
        for umbral in umbralesAviso where d <= Double(umbral) && ultimoUmbralAvisado > umbral {
            ultimoUmbralAvisado = umbral
            Task {
                await agent.ejecutarTurno("""
                El vendedor está a \(umbral) metros de la tienda "\(tienda.nombre)".
                Dale un aviso breve y motivacional (1 frase). NO uses tools.
                """)
            }
            break
        }
        
        // Llegada — dispara la rutina del Osito
        if haLlegado && ultimoUmbralAvisado != 0 {
            ultimoUmbralAvisado = 0
            Task {
                // Inicia la visita formalmente — esto activa consultarHistorialTienda
                await agent.iniciarVisita(tienda: tienda)
                // Pequeña espera para que termine de hablar antes de transicionar
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run { onLlegada() }
            }
        }
    }
    
    private func ajustarCamara() {
        let region = MKCoordinateRegion(
            center: coordenadaTienda,
            latitudinalMeters: 800,
            longitudinalMeters: 800
        )
        cameraPosition = .region(region)
    }
}
