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
            saludoPrompt = """
            El vendedor Carlos llegó a "\(tienda.nombre)" para su SEGUNDA visita (semana 2).
            Salúdalo cálidamente, menciona a \(tienda.nombreTendero) por su nombre,
            y dile que ya tienes listo el historial de la semana pasada.
            Si hay notas relevantes del historial, mencionala de forma natural (ej: el horario, el Gansito, etc).
            Sé breve (2-3 frases). Habla de tú al vendedor como "compa".
            """
        } else {
            saludoPrompt = """
            El vendedor Carlos llegó a "\(tienda.nombre)" por primera vez.
            Salúdalo cálidamente, menciona a \(tienda.nombreTendero) por su nombre.
            Sé breve (2-3 frases). Habla de tú al vendedor como "compa".
            """
        }
        await ejecutarTurno(saludoPrompt)
    }

    // MARK: - Configurar sesión con contexto histórico

    private func configurarSession() {
        guard let tienda else { return }

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
        Eres el Osito Bimbo 🐻, asistente de vendedores de Grupo Bimbo.
        Personalidad cálida, amigable y eficiente. Hablas español de México coloquial.
        Frases cortas (máx 2-3 oraciones). Le dices "compa" al vendedor.

        Estás en "\(tienda.nombre)" con \(tienda.nombreTendero).

        \(seccionHistorial)

        Flujo actual (semana \(resumenHistorico.isEmpty ? "1" : "2")):
        1) Llegada/saludo → 2) Bajar pedido del camión → 3) Revisar caducidades anaquel
        4) Acomodo estratégico → 5) Registrar ventas y pedido inteligente
        6) Confirmación con tendero → 7) Notas del día → 8) Éxito

        REGLAS IMPORTANTES:
        - Mantén contexto entre turnos. No repitas preguntas.
        - Cuando hay productos caducados urgentes, menciónalos con urgencia.
        - Usa los insights de notas previas para dar consejos más personalizados.
        - Si hay notas que mencionan problemas (ej: terminal de pago), adviértelo proactivamente.
        - Usa tools cuando sea necesario. No inventes datos.
        - Siempre que vayas al paso de caducidad, usa la tool calcularProductosPorCaducar.
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

    func ejecutarTurno(_ entrada: String) async {
        guard let session else { return }
        procesando = true
        do {
            let resp = try await session.respond(to: entrada)
            let texto = resp.content
            mensajes.append(MensajeOsito(rol: .osito, texto: texto))
            ultimoMensajeOsito = texto
            voice.hablar(texto)
        } catch {
            let fallback = "Ay compa, déjame pensar tantito..."
            mensajes.append(MensajeOsito(rol: .osito, texto: fallback))
            voice.hablar(fallback)
        }
        procesando = false
    }

    func vendedorDicta(_ texto: String) async {
        guard !texto.isEmpty else { return }
        mensajes.append(MensajeOsito(rol: .vendedor, texto: texto))
        await ejecutarTurno(texto)
    }

    // MARK: - Navegación entre pasos

    func avanzarA(_ paso: AppStep) async {
        pasoActual = paso
        let tid = tienda?.id ?? 0

        switch paso {
        case .descarga:
            let tieneHistorial = !pedidoAnteriorParaDescarga.isEmpty
            if tieneHistorial {
                let resumen = pedidoAnteriorParaDescarga
                    .map { "\($0.nombre) (\($0.unidades) cajas)" }
                    .joined(separator: ", ")
                await ejecutarTurno("""
                Motiva al vendedor a bajar las cajas del camión. El pedido de la semana pasada fue:
                \(resumen). Menciona la cantidad total y anímalo. NO uses tools aquí, solo habla.
                """)
            } else {
                await ejecutarTurno("Motiva al vendedor — es la primera entrega, no hay pedido previo. Breve y animado.")
            }

        case .caducidad:
            await ejecutarTurno("""
            Usa la tool calcularProductosPorCaducar con tiendaId=\(tid).
            Después dile al vendedor qué productos necesitan atención urgente y cuáles están en amarillo.
            Sé directo y claro.
            """)
            await cargarCaducidad()

        case .resurtido:
            // Personalizar tip con base en historial si existe
            let tipPersonalizado: String
            if resumenHistorico.contains("nivel de ojos") || resumenHistorico.contains("zona ocular") {
                tipPersonalizado = """
                Da un tip de neuromarketing para esta tienda específicamente.
                Recuerda que la semana pasada se confirmó que los Pingüinos funcionan bien al nivel de los ojos.
                Refuerza ese insight y agrega uno nuevo sobre colores o agrupación de productos.
                """
            } else {
                tipPersonalizado = "Da un tip de neuromarketing específico: posición, colores y demanda para esta tienda."
            }
            await ejecutarTurno(tipPersonalizado)

        case .recomendacionIA:
            await ejecutarTurno("""
            Pídele al vendedor que dicte qué vendió esta semana.
            Luego usa generarSugerenciasResurtido con tiendaId=\(tid).
            Si hay datos históricos de semana pasada, compara y menciona si algo cambió.
            """)
            await cargarSugerencias()

        case .confirmacion:
            await ejecutarTurno("""
            Pide al vendedor que revise con Lupita las cantidades antes de cerrar el pedido.
            Si hay notas que indicaban problemas con el pago (terminal), recuérdaselo ahora para que lo verifiquen.
            """)

        case .notas:
            await ejecutarTurno("""
            ¡Excelente trabajo compa! Ahora dicta tus observaciones del día para que la próxima visita
            sea aún mejor. Tus notas se guardan y el Osito las recuerda para la siguiente semana.
            """)

        case .exito:
            await ejecutarTurno("Despídete cálidamente de Lupita y felicita al vendedor Carlos por la visita completada. Menciona que las notas ya quedaron guardadas.")

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
            await ejecutarTurno("Registré: \(conf). Confirma brevemente y dile si esto es más o menos que la semana pasada.")
        }
    }

    func procesarNotaFinal(_ texto: String, etiquetas: [String]) async {
        guard let tienda else { return }
        mensajes.append(MensajeOsito(rol: .vendedor, texto: texto))
        let tool = GuardarNotaTool(modelContext: modelContext)
        if let res = try? await tool.call(arguments: .init(nota: texto, tiendaId: tienda.id, etiquetas: etiquetas)) {
            await ejecutarTurno("""
            Guardé la nota con resumen: "\(res.resumen)" y \(res.insights.count) insights.
            Agradece brevemente al vendedor y dile que el Osito recuerda todo para la próxima visita.
            """)
        }
    }
}
