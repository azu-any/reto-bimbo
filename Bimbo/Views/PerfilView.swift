//
//  PerfilView.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

//
//  PerfilView.swift
//  Bimbo
//
//  Vista de perfil del usuario con anillos de bienestar,
//  pasos de HealthKit, actividades y logros
//

//
//  PerfilView.swift
//  Bimbo
//
//  Vista de perfil con anillos de bienestar, HealthKit
//  y Osito IA flotante con voz de Juan + "Oye Osito"
//

//
//  PerfilView.swift
//  Bimbo
//
//  Vista de perfil con anillos de bienestar, HealthKit
//  y Osito IA flotante con voz de Juan + "Oye Osito"
//

import SwiftUI
import SwiftData
struct PerfilView: View {
    
    @State private var health = HealthKitService.shared
    let agent: OsitoAgent

    private let usuario = BimboUserProfile.mock
    private let pilares: [BimboPilar] = [
        BimboPilar(nombre: "Emocional", porcentaje: 75, color: .bimboRed),
        BimboPilar(nombre: "Físico", porcentaje: 60, color: .green),
        BimboPilar(nombre: "Intelectual", porcentaje: 85, color: .bmbPilarIntelectual)
    ]
    
    private let actividades: [BimboActividad] = [
        BimboActividad(titulo: "Mindfulness", duracionMin: 5, pilar: "Emocional", color: .bmbPilarEmocional, icono: "brain.head.profile"),
        BimboActividad(titulo: "Respiración 4-7-8", duracionMin: 3, pilar: "Físico", color: .bmbPilarFisico, icono: "wind")
    ]
    
    @State private var cursoSeleccionado: BimboCurso?
    
    var body: some View {
        ZStack {
            Color.bmbAppBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header alto y moderno
                    headerView
                    
                    // Contenido con offset hacia arriba para solapar header
                    VStack(spacing: 16) {
                        anillosBienestar
                        actividadesSugeridas
                        tarjetaPasos
                        tarjetaLogros
                        cursosPendientes
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
//                    .offset(y: -30)
                    .background(
                        Color.bmbAppBackground
                            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                            .offset(y: -30)
                    )
                }
            }
            .ignoresSafeArea()
            // Botón flotante del Osito (FAB)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    OsitoFABView(agent: agent)
                        .padding(.bottom, 52)
                }
            }
        }
        .sheet(item: $cursoSeleccionado) { curso in
            BimboCursoDetalleView(curso: curso, voz: agent.voice)
        }
        .task {
            await health.cargarDatosHoy()
        }
    }
    
    // MARK: - Header (moderno y alto, con osito)
    
    
    private var headerView: some View {
        ZStack(alignment: .top) {
            // Fondo azul marino
            Color(red: 10/255, green: 35/255, blue: 90/255)
                .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 0) {
                // Barra superior con botones a la derecha
                HStack {
                    Spacer()
                    Button { } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 10/255, green: 35/255, blue: 90/255))
                                .padding(10)
                                
                           
                        }
                    }
                    Button { } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 10/255, green: 35/255, blue: 90/255))
                            .padding(10)
                           
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                HStack {
                    
                    // Info del usuario alineada a la izquierda estilo Twitter
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(usuario.nombre)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 11))
                            Text(usuario.puesto)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 11))
                            Text(usuario.email)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 2)
                        
                        // Stats fila estilo Twitter
                        HStack(spacing: 18) {
                            statItem(numero: "12", label: "Cursos")
                            statItem(numero: "75%", label: "Bienestar")
                            statItem(numero: "\(health.pasosHoy)", label: "Pasos hoy")
                        }
                        .padding(.top, 12)
                        
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    
                    Spacer()
                    
                    // Avatar grande alineado a la izquierda
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 96, height: 96)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.bmbBlue, Color.bmbLightBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                        
                        Text(usuario.iniciales)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                    .padding(.leading, 20)
                    .padding(.top, 12)
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 58)

        }
        .frame(height: 320)
    }
    
    // MARK: - Stat item estilo Twitter
    private func statItem(numero: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(numero)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    
    // MARK: - Anillos concéntricos estilo Apple Fitness
    
    private var anillosBienestar: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Mi Bienestar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                Spacer()
                Text("META MENSUAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.bmbTextTertiary)
                    .tracking(1)
            }
            
            HStack(spacing: 24) {
                // Anillos concéntricos grandes
                ZStack {
                    // Anillo exterior - Emocional (más grande)
                    AnilloFitness(
                        progreso: Double(pilares[0].porcentaje) / 100,
                        color: pilares[0].color,
                        diametro: 180,
                        grosor: 18
                    )
                    
                    // Anillo medio - Físico
                    AnilloFitness(
                        progreso: Double(pilares[1].porcentaje) / 100,
                        color: pilares[1].color,
                        diametro: 130,
                        grosor: 18
                    )
                    
                    // Anillo interior - Intelectual (más pequeño)
                    AnilloFitness(
                        progreso: Double(pilares[2].porcentaje) / 100,
                        color: pilares[2].color,
                        diametro: 80,
                        grosor: 18
                    )
                }
                .frame(width: 200, height: 200)
                
                // Leyenda con porcentajes a la derecha
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(pilares) { pilar in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(pilar.color)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(pilar.nombre)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.bmbTextPrimary)
                                Text("\(pilar.porcentaje)%")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(pilar.color)
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color.bmbCardBackground)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - Actividades
    
    private var actividadesSugeridas: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Actividades sugeridas")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                Spacer()
                
                Button {
                    leerActividades()
                } label: {
                    Image(systemName: agent.voice.hablando ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .font(.system(size: 14))
                        .foregroundColor(.bmbBlue)
                        .padding(8)
                        .background(Color.bmbBlue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            VStack(spacing: 10) {
                ForEach(actividades) { act in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(act.color.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: act.icono)
                                .foregroundColor(act.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(act.titulo)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.bmbTextPrimary)
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text("\(act.duracionMin) min")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.bmbTextSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.fill")
                            .foregroundColor(act.color)
                            .font(.system(size: 14))
                    }
                    .padding(14)
                    .background(Color.bmbCardBackground)
                    .overlay(
                        Rectangle()
                            .fill(act.color)
                            .frame(width: 4)
                            .cornerRadius(2),
                        alignment: .leading
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
                }
            }
        }
    }
    
    // MARK: - Pasos
    
    private var tarjetaPasos: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.bmbPilarFisico.opacity(0.03))
                        .frame(width: 36, height: 36)
                    Image(systemName: "figure.walk")
                        .foregroundColor(.bmbPilarFisico)
                }
                Text("Actividad Diaria")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                Spacer()
                
               
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(health.pasosHoy)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                Text("/ \(health.metaPasos) pasos")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.bmbTextSecondary)
                Spacer()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.bmbAppBackground)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [.green, .bmbPilarFisico.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * health.progresoMeta, height: 12)
                }
            }
            .frame(height: 12)
            
            Divider()
            
            HStack(spacing: 0) {
                metricaItem(icono: "flame.fill", color: .orange, valor: "\(health.caloriasQuemadas)", unidad: "kcal")
                Divider().frame(height: 40)
                metricaItem(icono: "mappin.and.ellipse", color: .blue, valor: String(format: "%.1f", health.distanciaKm), unidad: "km")
                Divider().frame(height: 40)
                metricaItem(icono: "timer", color: .purple, valor: "\(health.minutosActivos)", unidad: "min")
            }
        }
        .padding(20)
        .background(Color.bmbCardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func metricaItem(icono: String, color: Color, valor: String, unidad: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icono)
                .foregroundColor(color)
                .font(.system(size: 16))
            Text(valor)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.bmbTextPrimary)
            Text(unidad.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.bmbTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Logros

        private var tarjetaLogros: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mis logros")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                    // Dependiendo de tu vista padre, puede que necesites un .padding(.horizontal) aquí
                
                VStack(spacing: 10) {
                    ForEach(Array(BimboCurso.mockCursos.prefix(2))) { curso in
                        Button {
                            cursoSeleccionado = curso
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.bmbBlue.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "rosette")
                                        .foregroundColor(.bmbBlue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(curso.titulo)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.bmbTextPrimary)
                                    Text("\(curso.categoria) • \(curso.fecha)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.bmbTextSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.bmbTextTertiary)
                            }
                            .padding(14)
                            .background(Color.bmbCardBackground)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
                        }
                    }
                }
            }
        }

        // MARK: - Cursos Pendientes (Carrusel Horizontal tipo IG Stories)
    // MARK: - Cursos Pendientes (Carrusel Horizontal tipo IG Stories)
            private var cursosPendientes: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cursos pendientes")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.bmbTextPrimary)
                        .padding(.horizontal) // Alineado con el resto del contenido
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Usamos .suffix(2) para tomar solo los últimos 2 cursos del arreglo
                            ForEach(Array(BimboCurso.mockCursos.suffix(2))) { curso in
                                Button {
                                    cursoSeleccionado = curso
                                } label: {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Parte superior con ícono/imagen de fondo
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.bmbBlue.opacity(0.1))
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(.bmbBlue)
                                        }
                                        .frame(height: 80)
                                        .cornerRadius(12)
                                        
                                        // Título del curso (máximo 2 líneas)
                                        Text(curso.titulo)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.bmbTextPrimary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer(minLength: 0)
                                        
                                        // Botón de acción simulado
                                        HStack {
                                            Text("Continuar")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.bmbBlue)
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.bmbBlue)
                                        }
                                    }
                                    .padding(12)
                                    // Dimensiones fijas para que todas las tarjetas se vean iguales
                                    .frame(width: 140, height: 180)
                                    .background(Color.bmbCardBackground)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                                }
                            }
                        }
                        // Damos padding a los lados para que el scroll empiece con un margen
                        // pero fluya hasta el borde de la pantalla
                        .padding(.horizontal)
                        .padding(.bottom, 10) // Espacio extra para que no se corte la sombra
                    }
                }
            }

     
    // MARK: - Botón flotante del Osito
    
    private func leerActividades() {
        if agent.voice.hablando {
            agent.voice.detenerVoz()
            return
        }
        let texto = "Te sugiero estas actividades: \(actividades.map { "\($0.titulo) de \($0.duracionMin) minutos" }.joined(separator: ", y "))."
        agent.voice.hablar(texto)
    }
}

// MARK: - Anillo estilo Apple Fitness
struct AnilloFitness: View {
    let progreso: Double  // 0.0 a 1.0
    let color: Color
    let diametro: CGFloat
    let grosor: CGFloat
    
    @State private var animar = false
    
    var body: some View {
        ZStack {
            // Track (fondo del anillo)
            Circle()
                .stroke(color.opacity(0.2), lineWidth: grosor)
                .frame(width: diametro, height: diametro)
            
            // Progreso con gradiente
            Circle()
                .trim(from: 0, to: animar ? CGFloat(progreso) : 0)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.7), color, color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * progreso)
                    ),
                    style: StrokeStyle(lineWidth: grosor, lineCap: .round)
                )
                .frame(width: diametro, height: diametro)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.4), value: animar)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 0)
        }
        .onAppear { animar = true }
    }
}

// MARK: - Detalle del curso
struct BimboCursoDetalleView: View {
    let curso: BimboCurso
    let voz: VoiceService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bmbBlue.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: "rosette")
                        .font(.system(size: 24))
                        .foregroundColor(.bmbBlue)
                }
                
                Text(curso.categoria.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.bmbAppBackground)
                    .foregroundColor(.bmbTextSecondary)
                    .cornerRadius(12)
                
                Text(curso.titulo)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.bmbTextPrimary)
                
                HStack(spacing: 16) {
                    Label(curso.duracion, systemImage: "clock")
                    Label(curso.instructor, systemImage: "person")
                }
                .font(.system(size: 13))
                .foregroundColor(.bmbTextSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Descripción")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.bmbTextPrimary)
                        Spacer()
                        Button {
                            if voz.hablando { voz.detenerVoz() }
                            else { voz.hablar(curso.descripcion) }
                        } label: {
                            Image(systemName: voz.hablando ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .foregroundColor(.bmbBlue)
                        }
                    }
                    Text(curso.descripcion)
                        .font(.system(size: 14))
                        .foregroundColor(.bmbTextSecondary)
                        .lineSpacing(4)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Habilidades adquiridas")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.bmbTextPrimary)
                    
                    BimboFlowLayout(spacing: 8) {
                        ForEach(curso.habilidades, id: \.self) { skill in
                            Text(skill)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.bmbBlue.opacity(0.1))
                                .foregroundColor(.bmbBlue)
                                .cornerRadius(10)
                        }
                    }
                }
                
                PrimaryButtonView(title: "Ver Certificado", action: { dismiss() })
                .padding(.top, 8)
            }
            .padding(24)
        }
        .presentationDragIndicator(.visible)
    }
}

// MARK: - BimboFlowLayout helper
struct BimboFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth {
                totalHeight += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        return CGSize(width: maxWidth, height: totalHeight + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - RoundedCorner helper para esquinas redondeadas selectivas
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Tienda.self, Visita.self, Nota.self, configurations: config)
    PerfilView(agent: OsitoAgent(modelContext: container.mainContext, voice: VoiceService()))
        .modelContainer(container)
}
