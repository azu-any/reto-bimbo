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
            El vendedor Carlos ha llegado a la tienda "\(tienda.nombre)". Esta es la segunda semana consecutiva que la visitan juntos.
            Salúdalo con mucha energía y calidez, usando el tono de un buen amigo o compañero de trabajo ("BimboAmigo"). 
            Menciona a \(tienda.propietario) por su nombre para personalizar el trato. 
            Hazle saber que ya tienes a la mano la información de la visita anterior para ayudarle hoy.
            Si hay algún dato muy importante en el historial (ej. un problema previo o un producto clave como el Gansito), menciónalo sutilmente para mostrar que estás preparado.
            Sé breve, natural y alentador (máximo 2 o 3 frases).
            """
        } else {
            saludoPrompt = """
            El vendedor Carlos acaba de llegar a la tienda "\(tienda.nombre)" por primera vez.
            Dale una bienvenida muy cálida y entusiasta. Usa el tono de un buen compañero ("compa").
            Menciona a \(tienda.propietario) por su nombre.
            Transmítele confianza de que harán un gran equipo en esta visita.
            Sé breve y muy amigable (máximo 2 o 3 frases).
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
        Eres el Osito Bimbo 🐻, el asistente virtual y compañero inseparable de los vendedores de Grupo Bimbo.
        Tu personalidad es sumamente cálida, amigable, empática y muy eficiente. Hablas un español de México coloquial, natural y respetuoso.
        Tu objetivo es hacer sentir al vendedor apoyado y motivado en todo momento. Llámalo "compa" de forma amistosa.
        Tus respuestas deben ser siempre claras, directas y breves (máximo 2 o 3 oraciones), para no quitarle tiempo.

        Actualmente estás acompañando al vendedor en la tienda "\(tienda.nombre)", cuyo propietario(a) es \(tienda.propietario).

        \(seccionHistorial)

        El flujo de trabajo actual (semana \(resumenHistorico.isEmpty ? "1" : "2")):
        1) Llegada/saludo → 2) Bajar pedido del camión → 3) Revisar caducidades en anaquel
        4) Acomodo estratégico → 5) Registrar ventas y pedido inteligente
        6) Confirmación con el tendero → 7) Notas del día → 8) Éxito y despedida

        REGLAS DE ORO:
        - Sé coherente y mantén el contexto de la conversación. No repitas preguntas que ya se respondieron.
        - Sé empático: si hay problemas (como la terminal fallando), muéstrate comprensivo y advierte de forma proactiva.
        - Usa los insights históricos para dar consejos valiosos y personalizados.
        - Si identificas productos caducados o por caducar, menciónalo con tacto pero dejando clara la urgencia para cuidar la calidad Bimbo.
        - Usa las herramientas (tools) disponibles para obtener información real, nunca inventes datos o números.
        - Obligatorio: siempre que llegues al paso de revisar caducidades, usa la herramienta 'calcularProductosPorCaducar'.
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
            print("🚨 ERROR EN OsitoAgent.ejecutarTurno: \(error.localizedDescription)")
            
            // ── FALLBACK AUTOMÁTICO PARA EL PITCH ──
            // Si el modelo de Apple Intelligence no está disponible, usamos estos textos quemados
            // para que la presentación siga fluyendo de manera natural.
            let fallback: String
            
            if entrada.contains("ha llegado a la tienda") || entrada.contains("acaba de llegar a la tienda") {
                let nombreTendero = tienda?.propietario ?? "Lupita"
                fallback = "¡Qué onda Carlos! Llegamos con \(nombreTendero). Ya revisé el historial de la visita anterior, ¡vamos a hacer un gran equipo hoy!"
            } else if entrada.contains("Anotado, compa!") {
                fallback = "¡Anotado, compa! Ya registré todo en el sistema. ¡Vas con mejor ritmo que la semana pasada, a seguirle dando!"
            } else if entrada.contains("has guardado perfectamente su nota") {
                fallback = "¡Listo, compa! Guardé tu nota perfectamente y saqué varias conclusiones. Yo no olvido nada para nuestra próxima visita."
            } else {
                switch pasoActual {
                case .descarga:
                    fallback = "¡Venga compa! A bajar los productos del camión. Recuerda que la semana pasada dejamos buen surtido de Pan Multigrano y Bimbollos, a ver qué tal nos va hoy."
                case .caducidad:
                    fallback = "Ojo aquí Carlos. Ya calculé las caducidades y tenemos el Wonder 100% mediano y las Mini Doraditas próximos a caducar. Hay que retirarlos para cuidar nuestra calidad."
                case .recomendacionIA:
                    fallback = "¡Listo! El modelo de Inteligencia Artificial proyecta una alta demanda para el Pan Multigrano Linaza por temporalidad. ¡Aseguremos buen inventario para no quedarnos cortos!"
                case .confirmacion:
                    fallback = "Compa, pídele a Lupita que revisen las cantidades finales. Y ojo, la vez pasada falló su terminal de cobro, pregúntale si ya sirve."
                case .notas:
                    fallback = "¡Eres un crack Carlos, excelente trabajo! Díctame tus observaciones de hoy para guardarlas en nuestro historial."
                case .exito:
                    fallback = "¡Misión cumplida! Todo guardado. Despídete con una gran sonrisa y vámonos a la que sigue."
                default:
                    fallback = "¡Claro que sí, compa! Vamos excelente."
                }
            }
            
            mensajes.append(MensajeOsito(rol: .osito, texto: fallback))
            ultimoMensajeOsito = fallback
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
                    .map { "\($0.nombre) (\($0.unidades) unidades)" }
                    .joined(separator: ", ")
                await ejecutarTurno("""
                Anima al vendedor mientras baja los productos del camión. 
                Recuérdale con tono de compañero que el pedido de la semana pasada fue: \(resumen). 
                Hazlo sentir respaldado y motivado. Solo usa tu voz, sin usar herramientas (tools) en este momento.
                """)
            } else {
                await ejecutarTurno("Motiva al vendedor con mucha energía para empezar la descarga. Como es la primera visita, recuérdale que es una gran oportunidad para sorprender al cliente. Sé breve y amigable.")
            }

        case .caducidad:
            await ejecutarTurno("""
            Usa la herramienta (tool) 'calcularProductosPorCaducar' con tiendaId=\(tid).
            Luego, de manera clara, amable y profesional, infórmale al vendedor qué productos requieren retiro urgente y cuáles están en precaución (amarillo). 
            Transmite que cuidar la frescura es cuidar nuestra marca.
            """)
            await cargarCaducidad()

//        case .resurtido:
//            // Personalizar tip con base en historial si existe
//            let tipPersonalizado: String
//            if resumenHistorico.contains("nivel de ojos") || resumenHistorico.contains("zona ocular") {
//                tipPersonalizado = """
//                Da un tip de neuromarketing para esta tienda específicamente.
//                Recuerda que la semana pasada se confirmó que los Pingüinos funcionan bien al nivel de los ojos.
//                Refuerza ese insight y agrega uno nuevo sobre colores o agrupación de productos.
//                """
//            } else {
//                tipPersonalizado = "Da un tip de neuromarketing específico: posición, colores y demanda para esta tienda."
//            }
//            await ejecutarTurno(tipPersonalizado)

        case .recomendacionIA:
            await ejecutarTurno("""
            Usa la herramienta 'generarSugerenciasResurtido' con tiendaId=\(tid). Si existe información de la semana pasada, haz una breve comparación positiva para que vea el progreso. Indícale al vendedor brevemente porqué es una buena recomendación"
            """)
            await cargarSugerencias()

        case .confirmacion:
            await ejecutarTurno("""
            Pídele amablemente al vendedor que revise las cantidades finales con Lupita antes de confirmar el pedido.
            Aprovecha para recordarle de forma empática cualquier detalle crítico de visitas anteriores, como problemas conocidos con la terminal de pago, para evitarle contratiempos.
            """)

        case .notas:
            await ejecutarTurno("""
            ¡Felicita al compa por el excelente trabajo hasta ahora!
            Pídele que te dicte sus observaciones del día, explicándole que esto le ayudará a él y a ti a dar un mejor servicio la próxima semana.
            Hazlo sentir escuchado e importante.
            """)

        case .exito:
            await ejecutarTurno("Felicita calurosamente al vendedor Carlos por una visita exitosa. Pídele que se despida de Lupita con una gran sonrisa y confírmale que todas sus notas y trabajo de hoy están a salvo contigo. ¡A por la siguiente tienda!")

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
            await ejecutarTurno("Dile al vendedor con entusiasmo: '¡Anotado, compa! Registré \(conf).' Confírmale si le fue mejor que la semana pasada para subirle el ánimo.")
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
