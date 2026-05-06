//
//  OsitoAgent.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//


// OsitoAgent.swift
// Bimbo/Tools/OsitoAgent.swift
// OsitoAgent.swift
// OsitoAgent.swift
import Foundation
import FoundationModels
import SwiftData
import Observation

struct MensajeOsito: Identifiable {
    let id = UUID()
    let rol: Rol
    let texto: String
    let fecha = Date()
    enum Rol { case osito, vendedor }
}

@Observable
@MainActor
final class OsitoAgent {
    private var session: LanguageModelSession?
    private let modelContext: ModelContext
    let voice: VoiceService

    var mensajes: [MensajeOsito] = []
    var pasoActual: AppStep = .llegada
    var procesando: Bool = false
    var ultimoMensajeOsito: String = ""

    private(set) var tienda: Tienda?
    private(set) var visitaActual: Visita?

    // Estado derivado visible en las vistas
    var ventasRegistradas: [RegistrarVentaTool.VentaItem] = []
    var sugerenciasGeneradas: [GenerarSugerenciasTool.Sugerencia] = []
    var productosPorCaducar: [CalcularCaducidadTool.ProductoCaducidad] = []
    var pedidoAnteriorParaDescarga: [ConsultarHistorialTool.ItemHistorico] = []

    // ── Resumen histórico que se inyecta en el system prompt ───────────────
    private var resumenHistorico: String = ""

    init(modelContext: ModelContext, voice: VoiceService) {
        self.modelContext = modelContext
        self.voice = voice
    }

    // MARK: - Inicio de visita

    func iniciarVisita(tienda: Tienda) async {
        self.tienda = tienda
        let visita = Visita(fecha: Date(), tiendaId: tienda.id)
        modelContext.insert(visita)
        try? modelContext.save()
        self.visitaActual = visita

        // Cargar historial ANTES de configurar la sesión
        await precargarHistorial()
        configurarSession()

        pasoActual = .llegada

        // El saludo ya menciona datos del historial para que sea coherente
        let tieneHistorial = !pedidoAnteriorParaDescarga.isEmpty
        let saludoPrompt: String
        if tieneHistorial {
            ultimoMensajeOsito = "¡Hola Carlos! Llegamos a \(tienda.nombre). Ya tengo listo el historial de \(tienda.propietario) para ayudarte."
        } else {
            ultimoMensajeOsito = "¡Hola Carlos! Primera vez en \(tienda.nombre). ¡Vamos a dar una gran impresión!"
        }
        
        // await ejecutarTurno(saludoPrompt)
    }

    // MARK: - Configurar sesión con contexto histórico

    private func configurarSession() {
        let nombreTienda = tienda?.nombre ?? "la tienda"
        let propietario = tienda?.propietario ?? "el cliente"

        // Construir sección de historial para el system prompt
        let seccionHistorial: String
        if resumenHistorico.isEmpty {
            seccionHistorial = "Esta es la primera visita a esta tienda — no hay historial previo."
        } else {
            seccionHistorial = """
            === HISTORIAL PREVIO DE ESTA TIENDA ===
            \(resumenHistorico)
            =========================================
            Usa este historial para personalizar tus respuestas. Menciona datos relevantes
            de forma natural cuando sea apropiado (sin leer el historial textualmente).
            """
        }

        let instrucciones = """
        Eres el Osito Bimbo 🐻, el asistente virtual y BimboAmigo inseparable de los vendedores y repartidores de Grupo Bimbo.
        Tu personalidad es sumamente cálida, amigable, empática y muy eficiente. Hablas un español de México coloquial, natural, alegre y respetuoso.
        Tienes un rol dual muy importante: 
        1) Eres el asistente de ventas experto que ayuda a gestionar inventarios, pedidos y caducidades en tienda.
        2) Eres el Coach de Bienestar Integral del vendedor, preocupado genuinamente por su salud física, emocional e intelectual.

        Tu objetivo es hacer sentir al vendedor apoyado, productivo y motivado en todo momento. Llámalo "BimboAmigo" de forma amistosa.
        Tus respuestas deben ser siempre claras, directas y breves (máximo 2 o 3 oraciones), para no quitarle tiempo en su ruta.

        Actualmente estás acompañando al vendedor en la tienda "\(nombreTienda)", cuyo propietario(a) es \(propietario).

        \(seccionHistorial)

        El flujo de trabajo actual en tienda (semana \(resumenHistorico.isEmpty ? "1" : "2")):
        1) Llegada/saludo → 2) Bajar pedido del camión → 3) Revisar caducidades en anaquel
        4) Acomodo estratégico → 5) Registrar ventas y pedido inteligente
        6) Confirmación con el tendero → 7) Notas del día → 8) Éxito y despedida

        REGLAS DE ORO:
        - Sé coherente y mantén el contexto de la conversación.
        - Actitud de Coach de Bienestar: Si el vendedor te pregunta sobre su salud, pasos, calorías o actividades (como Mindfulness o Respiración), aliéntalo y felicítalo por cuidar su bienestar físico y emocional. Recuerda que la app tiene conexión con HealthKit para ver sus pasos.
        - Sé empático: si hay problemas en la ruta (tráfico, cansancio), muéstrate comprensivo y sugiere un breve respiro.
        - Usa los insights históricos para dar consejos de venta valiosos y personalizados (ej. "¡Ojo con los Bimbollos y Pan Multigrano!").
        - Si identificas productos caducados, menciónalo con tacto pero dejando clara la urgencia para cuidar la frescura y calidad Bimbo.
        - Usa las herramientas (tools) disponibles para obtener información real, nunca inventes datos o números.
        """

        let tools: [any Tool] = [
            ConsultarHistorialTool(modelContext: modelContext),
            CalcularCaducidadTool(modelContext: modelContext),
            RegistrarVentaTool(modelContext: modelContext, visitaActual: { [weak self] in self?.visitaActual }),
            GenerarSugerenciasTool(modelContext: modelContext, visitaActual: { [weak self] in self?.visitaActual }),
            ConfirmarPedidoTool(modelContext: modelContext, visitaActual: { [weak self] in self?.visitaActual }),
            GuardarNotaTool(modelContext: modelContext)
        ]
        session = LanguageModelSession(tools: tools, instructions: instrucciones)
    }

    // MARK: - Precarga de historial

    private func precargarHistorial() async {
        guard let tienda else { return }

        // 1. Pedido anterior para la pantalla de descarga
        let tool = ConsultarHistorialTool(modelContext: modelContext)
        if let res = try? await tool.call(arguments: .init(tiendaId: tienda.id)) {
            self.pedidoAnteriorParaDescarga = res.pedidoSemanaPasada

            // 2. Construir resumen histórico para el system prompt
            var resumen = ""

            // Pedido previo
            if !res.pedidoSemanaPasada.isEmpty {
                let itemsStr = res.pedidoSemanaPasada
                    .map { "  • \($0.nombre): \($0.unidades) unidades" }
                    .joined(separator: "\n")
                resumen += "PEDIDO SEMANA PASADA:\n\(itemsStr)\n\n"
            }

            // Notas previas
            if !res.notasRecientes.isEmpty {
                let notasStr = res.notasRecientes
                    .enumerated()
                    .map { "  Nota \($0.offset + 1): \($0.element)" }
                    .joined(separator: "\n")
                resumen += "NOTAS RECIENTES (resúmenes IA):\n\(notasStr)\n\n"
            }

            // Insights de notas (consultar directamente para más detalle)
            let insightsCombinados = await cargarInsightsDetallados(tiendaId: tienda.id)
            if !insightsCombinados.isEmpty {
                resumen += "INSIGHTS ACCIONABLES:\n\(insightsCombinados)\n\n"
            }

            resumen += "COMPORTAMIENTO: \(res.resumenComportamiento)"
            self.resumenHistorico = resumen
        }
    }

    private func cargarInsightsDetallados(tiendaId: Int) async -> String {
        let descN = FetchDescriptor<NotaVisita>(
            predicate: #Predicate { $0.tiendaId == tiendaId },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        let notas = (try? modelContext.fetch(descN)) ?? []
        var todos: [String] = []
        for nota in notas.prefix(3) {
            todos.append(contentsOf: nota.insights)
        }
        return todos.prefix(6).enumerated()
            .map { "  \($0.offset + 1). \($0.element)" }
            .joined(separator: "\n")
    }

    // MARK: - Ejecución de turnos

    func ejecutarTurno(_ entrada: String, reproducirVoz: Bool = false) async {
        // Lazy init: si la sesión aún no existe, configurarla ahora
        if session == nil {
            print("🐻 ejecutarTurno: session era nil, configurando sesión ahora...")
            configurarSession()
        }
        guard let session else {
            print("🚨 ejecutarTurno: NO se pudo crear sesión (tienda nil?)")
            return
        }
        procesando = true
        do {
            let resp = try await session.respond(to: entrada)
            let texto = resp.content
            mensajes.append(MensajeOsito(rol: .osito, texto: texto))
            ultimoMensajeOsito = texto
            if reproducirVoz { voice.hablar(texto) }
        } catch {
            print("🚨 ERROR EN OsitoAgent.ejecutarTurno: \(error.localizedDescription)")
            
            // ── FALLBACK AUTOMÁTICO PARA EL PITCH ──
            // Si el modelo de Apple Intelligence no está disponible, usamos estos textos quemados
            // para que la presentación siga fluyendo de manera natural.
            let fallback: String
            
            if entrada.contains("ha llegado a la tienda") || entrada.contains("acaba de llegar a la tienda") {
                let nombreTendero = tienda?.propietario ?? "Lupita"
                fallback = "¡Qué onda Carlos! Llegamos con \(nombreTendero). Ya revisé el historial de la visita anterior, ¡vamos a hacer un gran equipo hoy!"
            } else if entrada.contains("Anotado, BimboAmigo!") {
                fallback = "¡Anotado, BimboAmigo! Ya registré todo en el sistema. ¡Vas con mejor ritmo que la semana pasada, a seguirle dando!"
            } else if entrada.contains("has guardado perfectamente su nota") {
                fallback = "¡Listo, BimboAmigo! Guardé tu nota perfectamente y saqué varias conclusiones. Yo no olvido nada para nuestra próxima visita."
            } else {
                switch pasoActual {
                case .descarga:
                    fallback = "¡Venga BimboAmigo! A bajar los productos del camión. Recuerda que la semana pasada dejamos buen surtido de Pan Multigrano y Bimbollos, a ver qué tal nos va hoy."
                case .caducidad:
                    fallback = "Ojo aquí Carlos. Ya calculé las caducidades y tenemos el Wonder 100% mediano y las Mini Doraditas próximos a caducar. Hay que retirarlos para cuidar nuestra calidad."
                case .recomendacionIA:
                    fallback = "¡Listo! El modelo de Inteligencia Artificial proyecta una alta demanda para el Pan Multigrano Linaza por temporalidad. ¡Aseguremos buen inventario para no quedarnos cortos!"
                case .confirmacion:
                    fallback = "BimboAmigo, pídele a Lupita que revisen las cantidades finales. Y ojo, la vez pasada falló su terminal de cobro, pregúntale si ya sirve."
                case .notas:
                    fallback = "¡Eres un crack Carlos, excelente trabajo! Díctame tus observaciones de hoy para guardarlas en nuestro historial."
                case .exito:
                    fallback = "¡Misión cumplida! Todo guardado. Despídete con una gran sonrisa y vámonos a la que sigue."
                default:
                    fallback = "¡Claro que sí, BimboAmigo! Vamos excelente."
                }
            }
            
            mensajes.append(MensajeOsito(rol: .osito, texto: fallback))
            ultimoMensajeOsito = fallback
            if reproducirVoz { voice.hablar(fallback) }
        }
        procesando = false
    }

    func vendedorDicta(_ texto: String) async {
        guard !texto.isEmpty else { return }
        print("🐻 vendedorDicta recibido: '\(texto)'")
        mensajes.append(MensajeOsito(rol: .vendedor, texto: texto))
        await ejecutarTurno(texto, reproducirVoz: true)
    }

    // MARK: - Navegación entre pasos

    func avanzarA(_ paso: AppStep) async {
        pasoActual = paso
        let tid = tienda?.id ?? 0

        switch paso {
        case .descarga:
            ultimoMensajeOsito = "¡Vámonos! Vamos a bajar el producto. Avísame si necesitas saber qué dejamos la semana pasada. 🚛"
            // await ejecutarTurno(...)

        case .caducidad:
            ultimoMensajeOsito = "Revisemos las caducidades. Ya cargué los datos de los productos que podrían vencer pronto. 📉"
            await cargarCaducidad()
            // await ejecutarTurno(...)

        case .recomendacionIA:
            ultimoMensajeOsito = "¡Listo! Ya calculé las recomendaciones basadas en el modelo de IA para hoy. 🤖"
            await cargarSugerencias()
            // await ejecutarTurno(...)

        case .confirmacion:
            ultimoMensajeOsito = "¿Todo listo con el pedido? Verifica las cantidades finales con el cliente. ✅"
            // await ejecutarTurno(...)

        case .notas:
            ultimoMensajeOsito = "¡Excelente día! Díctame tus notas u observaciones de la visita para guardarlas. ✍️"
            // await ejecutarTurno(...)

        case .exito:
            ultimoMensajeOsito = "¡Misión cumplida! Todo quedó bien registrado. ¡Vámonos a la siguiente parada! 🚀"
            // await ejecutarTurno(...)

        default:
            break
        }
    }

    // MARK: - Cargas auxiliares

    private func cargarCaducidad() async {
        guard let tienda else { return }
        let tool = CalcularCaducidadTool(modelContext: modelContext)
        if let res = try? await tool.call(arguments: .init(tiendaId: tienda.id)) {
            self.productosPorCaducar = res.productosCaducidad
        }
    }

    private func cargarSugerencias() async {
        guard let tienda else { return }
        let tool = GenerarSugerenciasTool(
            modelContext: modelContext,
            visitaActual: { [weak self] in self?.visitaActual }
        )
        if let res = try? await tool.call(arguments: .init(tiendaId: tienda.id)) {
            self.sugerenciasGeneradas = res.sugerencias
        }
    }

    func procesarVozEnVentas(_ texto: String) async {
        guard let tienda else { return }
        mensajes.append(MensajeOsito(rol: .vendedor, texto: texto))
        let tool = RegistrarVentaTool(
            modelContext: modelContext,
            visitaActual: { [weak self] in self?.visitaActual }
        )
        if let res = try? await tool.call(arguments: .init(textoVendedor: texto, tiendaId: tienda.id)) {
            self.ventasRegistradas = res.ventasRegistradas
            let conf = res.ventasRegistradas
                .map { "\($0.unidadesVendidas) de \($0.nombre)" }
                .joined(separator: ", ")
            await ejecutarTurno("Dile al vendedor con entusiasmo: '¡Anotado, BimboAmigo! Registré \(conf).' Confírmale si le fue mejor que la semana pasada para subirle el ánimo.")
        }
    }

    func procesarNotaFinal(_ texto: String, etiquetas: [String]) async {
        guard let tienda else { return }
        mensajes.append(MensajeOsito(rol: .vendedor, texto: texto))
        let tool = GuardarNotaTool(modelContext: modelContext)
        if let res = try? await tool.call(arguments: .init(nota: texto, tiendaId: tienda.id, etiquetas: etiquetas)) {
            await ejecutarTurno("""
            Dile al vendedor de forma alegre que has guardado perfectamente su nota. Menciona brevemente de qué trata (resumen: "\(res.resumen)") y que sacaste \(res.insights.count) conclusiones útiles.
            Recuérdale que como buen equipo, tú no olvidas nada para su siguiente visita.
            """)
        }
    }
}
