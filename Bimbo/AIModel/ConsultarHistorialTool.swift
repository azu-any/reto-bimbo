//
//  OsitoTools.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

// Bimbo/Tools/OsitoTools.swift
// Bimbo/Tools/OsitoTools.swift
// Bimbo/Tools/OsitoTools.swift
import Foundation
import FoundationModels
import SwiftData

// MARK: - Tool 1: Consultar historial (enriquecido con notas e insights)
struct ConsultarHistorialTool: Tool {
    let name = "consultarHistorialTienda"
    let description = "Consulta historial de la tienda: pedido pasado, notas previas e insights accionables del agente."
    
    @Generable
    struct Arguments {
        @Guide(description: "ID numérico de la tienda")
        let tiendaId: Int
    }
    
    @Generable
    struct ItemHistorico {
        let productoId: String
        let nombre: String
        let unidades: Int
    }
    
    @Generable
    struct Resultado {
        let pedidoSemanaPasada: [ItemHistorico]
        let notasRecientes: [String]          // resúmenes IA de NotaVisita
        let insightsAcumulados: [String]      // todos los insights de notas pasadas
        let sentimientoGeneral: String        // positivo / neutro / problemático
        let resumenComportamiento: String
        let nombreTendero: String
        let esSegundaVisitaOMas: Bool
    }
    
    let modelContext: ModelContext
    
    func call(arguments: Arguments) async throws -> Resultado {
        let tid = arguments.tiendaId
        
        // Tienda
        let descT = FetchDescriptor<Tienda>(predicate: #Predicate { $0.id == tid })
        let tienda = try? modelContext.fetch(descT).first
        
        // Visita confirmada más reciente → pedido de semana pasada
        let descV = FetchDescriptor<Visita>(
            predicate: #Predicate { $0.tiendaId == tid && $0.pedidoConfirmado == true },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        let visitas = (try? modelContext.fetch(descV)) ?? []
        let items = visitas.first?.itemsConfirmados.map {
            ItemHistorico(productoId: $0.productoId, nombre: $0.nombreProducto, unidades: $0.unidades)
        } ?? []
        
        // Notas — resúmenes + insights acumulados
        let descN = FetchDescriptor<NotaVisita>(
            predicate: #Predicate { $0.tiendaId == tid },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        let notas = (try? modelContext.fetch(descN)) ?? []
        
        // Resúmenes IA con nombre de vendedor — clave para contexto de traspaso de cuentas
        let resumenes = notas.prefix(5).map { n -> String in
            let texto = n.resumenIA.isEmpty ? String(n.contenidoOriginal.prefix(150)) : n.resumenIA
            let fechaStr = formatFecha(n.fecha)
            return "[\(n.vendedor) – \(fechaStr)]: \(texto)"
        }
        
        // Todos los insights acumulados de las últimas 5 notas (historial completo)
        var todosInsights: [String] = []
        for nota in notas.prefix(5) {
            todosInsights.append(contentsOf: nota.insights)
        }
        
        // Vendedores únicos que han atendido esta tienda
        let vendedoresUnicos = Array(Set(notas.map { $0.vendedor })).sorted()
        
        // Sentimiento predominante (últimas 3 notas)
        let sentimientos = notas.prefix(3).map { $0.sentimiento }
        let sentimientoGeneral: String
        if sentimientos.contains("problemático") {
            sentimientoGeneral = "problemático"
        } else if sentimientos.allSatisfy({ $0 == "positivo" }) {
            sentimientoGeneral = "positivo"
        } else {
            sentimientoGeneral = "neutro"
        }
        
        // Resumen de unidades por producto en pedido semana pasada (para contexto "productos, no cajas")
        let resumenPedido = items.map { "\($0.nombre): \($0.unidades) unidades" }.joined(separator: ", ")
        
        let resumen = """
        Tienda con \(visitas.count) visita(s) previa(s). \
        Atendida por: \(vendedoresUnicos.joined(separator: ", ")). \
        \(notas.count) nota(s) registrada(s). \
        Último pedido: \(resumenPedido.isEmpty ? "sin datos" : resumenPedido).
        """
        
        return Resultado(
            pedidoSemanaPasada: items,
            notasRecientes: Array(resumenes),
            insightsAcumulados: Array(todosInsights.prefix(10)),
            sentimientoGeneral: sentimientoGeneral,
            resumenComportamiento: resumen,
            nombreTendero: tienda?.propietario ?? "el tendero",
            esSegundaVisitaOMas: visitas.count >= 1
        )
    }
    
    private func formatFecha(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

// MARK: - Tool 2: Calcular caducidades
struct CalcularCaducidadTool: Tool {
    let name = "calcularProductosPorCaducar"
    let description = "Calcula qué productos están próximos a caducar basándose en la fecha de entrega y la vida útil del catálogo."
    
    @Generable
    struct Arguments {
        let tiendaId: Int
    }
    
    @Generable
    struct ProductoCaducidad {
        let productoId: String
        let nombre: String
        let diasRestantes: Int
        let urgencia: String        // "alta" (≤3 días), "media" (4-7 días)
        let accionSugerida: String  // "Retirar" o "Marcar oferta"
    }
    
    @Generable
    struct Resultado {
        let productosCaducidad: [ProductoCaducidad]
        let cantidadUrgentes: Int
        let resumen: String
    }
    
    let modelContext: ModelContext
    
    func call(arguments: Arguments) async throws -> Resultado {
        let tid = arguments.tiendaId
        let descV = FetchDescriptor<Visita>(
            predicate: #Predicate { $0.tiendaId == tid && $0.pedidoConfirmado == true },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        let visitas = (try? modelContext.fetch(descV)) ?? []
        guard let ultima = visitas.first else {
            return Resultado(productosCaducidad: [], cantidadUrgentes: 0,
                             resumen: "Primera visita — sin productos en anaquel todavía.")
        }
        
        let descC = FetchDescriptor<ProductoCatalogo>()
        let catalogo = (try? modelContext.fetch(descC)) ?? []
        let mapa = Dictionary(uniqueKeysWithValues: catalogo.map { ($0.productoId, $0.vidaUtilSemanas) })
        
        var resultados: [ProductoCaducidad] = []
        let hoy = Date()
        
        for item in ultima.itemsConfirmados {
            let vidaSemanas = mapa[item.productoId] ?? 2
            let vidaDias = vidaSemanas * 7
            let diasTranscurridos = Calendar.current.dateComponents([.day], from: item.fechaEntrega, to: hoy).day ?? 0
            let restantes = vidaDias - diasTranscurridos
            
            let urgencia: String
            let accion: String
            if restantes <= 3 {
                urgencia = "alta"
                accion = "Retirar"
            } else if restantes <= 7 {
                urgencia = "media"
                accion = "Marcar oferta"
            } else {
                continue   // Producto todavía bien — no se muestra
            }
            
            resultados.append(ProductoCaducidad(
                productoId: item.productoId,
                nombre: item.nombreProducto,
                diasRestantes: max(0, restantes),
                urgencia: urgencia,
                accionSugerida: accion
            ))
        }
        
        let urg = resultados.filter { $0.urgencia == "alta" }.count
        let resumen: String
        switch (urg, resultados.count) {
        case (0, 0):
            resumen = "Todos los productos están en buen estado."
        case (0, let t):
            resumen = "\(t) producto(s) en zona amarilla — considera oferta esta semana."
        default:
            resumen = "¡Alerta! \(urg) producto(s) requieren retiro inmediato del anaquel."
        }
        
        return Resultado(
            productosCaducidad: resultados,
            cantidadUrgentes: urg,
            resumen: resumen
        )
    }
}

// MARK: - Tool 3: Registrar venta
struct RegistrarVentaTool: Tool {
    let name = "registrarVentasSemanales"
    let description = "Registra ventas dictadas por voz del vendedor."
    
    @Generable
    struct Arguments {
        @Guide(description: "Texto dictado por el vendedor")
        let textoVendedor: String
        let tiendaId: Int
    }
    
    @Generable
    struct VentaItem {
        let productoId: String
        let nombre: String
        let unidadesVendidas: Int
    }
    
    @Generable
    struct Resultado {
        let ventasRegistradas: [VentaItem]
        let totalProductos: Int
        let mensajeConfirmacion: String
    }
    
    let modelContext: ModelContext
    let visitaActual: () -> Visita?
    
    func call(arguments: Arguments) async throws -> Resultado {
        let descC = FetchDescriptor<ProductoCatalogo>()
        let catalogo = (try? modelContext.fetch(descC)) ?? []
        let texto = arguments.textoVendedor.lowercased()
        var encontrados: [VentaItem] = []
        
        for producto in catalogo {
            let nombreLower = producto.nombre.lowercased()
            if texto.contains(nombreLower),
               let unidades = extraerNumero(cercaDe: nombreLower, en: texto) {
                encontrados.append(VentaItem(
                    productoId: producto.productoId,
                    nombre: producto.nombre,
                    unidadesVendidas: unidades
                ))
                if let visita = visitaActual() {
                    let venta = ItemVenta(
                        productoId: producto.productoId,
                        nombreProducto: producto.nombre,
                        unidadesVendidas: unidades
                    )
                    modelContext.insert(venta)
                    visita.itemsVendidos.append(venta)
                }
            }
        }
        try? modelContext.save()
        
        return Resultado(
            ventasRegistradas: encontrados,
            totalProductos: encontrados.count,
            mensajeConfirmacion: "Registré \(encontrados.count) productos."
        )
    }
    
    private func extraerNumero(cercaDe palabra: String, en texto: String) -> Int? {
        let escaped = NSRegularExpression.escapedPattern(for: palabra)
        let pattern = "(\\d+)\\s*(?:de\\s+)?\(escaped)|\(escaped)[^\\d]{0,15}(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(texto.startIndex..., in: texto)
        if let match = regex.firstMatch(in: texto, range: range) {
            for i in 1..<match.numberOfRanges {
                if let r = Range(match.range(at: i), in: texto), let n = Int(texto[r]) {
                    return n
                }
            }
        }
        let mapa = ["uno":1,"dos":2,"tres":3,"cuatro":4,"cinco":5,"seis":6,"siete":7,
                    "ocho":8,"nueve":9,"diez":10,"doce":12,"quince":15,"veinte":20]
        for (p, v) in mapa {
            if texto.contains("\(p) \(palabra)") || texto.contains("\(palabra) \(p)") { return v }
        }
        return nil
    }
}

// MARK: - Tool 4: Generar sugerencias (compara con semana anterior)
struct GenerarSugerenciasTool: Tool {
    let name = "generarSugerenciasResurtido"
    let description = "Genera lista de sugerencias para el siguiente pedido, comparando con historial de semana pasada."
    
    @Generable
    struct Arguments {
        let tiendaId: Int
    }
    
    @Generable
    struct Sugerencia {
        let productoId: String
        let nombre: String
        let cantidadSugerida: Int
        let justificacion: String
    }
    
    @Generable
    struct Resultado {
        let sugerencias: [Sugerencia]
        let mensajeResumen: String
    }
    
    let modelContext: ModelContext
    let visitaActual: () -> Visita?
    
    func call(arguments: Arguments) async throws -> Resultado {
        guard let visita = visitaActual() else {
            return Resultado(sugerencias: [], mensajeResumen: "Sin datos de venta aún.")
        }
        
        // Pedido semana pasada para comparar
        // NOTA: #Predicate no puede capturar propiedades de structs directamente —
        // hay que extraer el valor a una variable local primero.
        let tid = arguments.tiendaId
        let descVPrev = FetchDescriptor<Visita>(
            predicate: #Predicate { $0.tiendaId == tid && $0.pedidoConfirmado == true },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        let visitasPrev = (try? modelContext.fetch(descVPrev)) ?? []
        let pedidoPrevMap = Dictionary(
            uniqueKeysWithValues: (visitasPrev.first?.itemsConfirmados ?? [])
                .map { ($0.productoId, $0.unidades) }
        )
        
        let sugerencias = visita.itemsVendidos.map { v -> Sugerencia in
            let vendidas = v.unidadesVendidas
            let pedidoPrev = pedidoPrevMap[v.productoId] ?? vendidas
            let cantidad = max(1, Int(Double(vendidas) * 1.20))
            
            let just: String
            if vendidas > pedidoPrev {
                just = "↑ Vendió más que la semana pasada (\(vendidas) vs \(pedidoPrev) pedidos). Aumento del 20%."
            } else if vendidas > 10 {
                just = "Alta rotación — \(vendidas) unidades. Se sugiere +20% para no quedar corto."
            } else if vendidas > 5 {
                just = "Rotación estable en \(vendidas) unidades. Se mantiene volumen base."
            } else {
                just = "Rotación baja (\(vendidas) u). Cantidad mínima de resurtido."
            }
            return Sugerencia(productoId: v.productoId, nombre: v.nombreProducto,
                              cantidadSugerida: cantidad, justificacion: just)
        }
        
        return Resultado(
            sugerencias: sugerencias,
            mensajeResumen: "\(sugerencias.count) sugerencias generadas con base en ventas y semana anterior."
        )
    }
}

// MARK: - Tool 5: Confirmar pedido
struct ConfirmarPedidoTool: Tool {
    let name = "confirmarPedidoFinal"
    let description = "Confirma el pedido final con cantidades acordadas con el tendero."
    
    @Generable
    struct Arguments {
        let tiendaId: Int
        let items: [ItemConfirmado]
    }
    
    @Generable
    struct ItemConfirmado {
        let productoId: String
        let nombre: String
        let unidades: Int
    }
    
    @Generable
    struct Resultado {
        let confirmado: Bool
        let totalUnidades: Int
        let mensaje: String
    }
    
    let modelContext: ModelContext
    let visitaActual: () -> Visita?
    
    func call(arguments: Arguments) async throws -> Resultado {
        guard let visita = visitaActual() else {
            return Resultado(confirmado: false, totalUnidades: 0, mensaje: "Sin visita activa.")
        }
        let entrega = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        for item in arguments.items {
            let pedido = ItemPedido(productoId: item.productoId, nombreProducto: item.nombre,
                                    unidades: item.unidades, fechaEntrega: entrega)
            modelContext.insert(pedido)
            visita.itemsConfirmados.append(pedido)
        }
        visita.pedidoConfirmado = true
        try? modelContext.save()
        let total = arguments.items.reduce(0) { $0 + $1.unidades }
        return Resultado(confirmado: true, totalUnidades: total,
                         mensaje: "Pedido confirmado: \(total) unidades para entrega en 7 días.")
    }
}

// MARK: - Tool 6: Guardar nota con análisis IA

@Generable
struct AnalisisNota {
    @Guide(description: "Resumen ejecutivo de 2 líneas")
    let resumen: String
    @Guide(description: "Insights accionables para la próxima visita, máximo 4")
    let insights: [String]
    @Guide(description: "Sentimiento: positivo, neutro o problemático")
    let sentimiento: String
}

struct GuardarNotaTool: Tool {
    let name = "guardarNotaDelDia"
    let description = "Guarda la nota del vendedor con resumen IA e insights para futuras visitas."
    
    @Generable
    struct Arguments {
        @Guide(description: "Texto completo de la nota del vendedor")
        let nota: String
        let tiendaId: Int
        let etiquetas: [String]
    }
    
    @Generable
    struct Resultado {
        let resumen: String
        let insights: [String]
        let sentimiento: String
        let mensajeConfirmacion: String
    }
    
    let modelContext: ModelContext
    
    func call(arguments: Arguments) async throws -> Resultado {
        let analizador = LanguageModelSession(instructions: """
        Eres un analizador de notas de campo para vendedores de Grupo Bimbo en México.
        Analiza la nota y genera:
        1. Un resumen ejecutivo de máximo 2 líneas (español México, directo)
        2. Entre 2 y 4 insights accionables para la próxima visita (imperativos: "Verificar...", "Aumentar...", etc.)
        3. Sentimiento general: "positivo" si todo va bien, "problemático" si hay quejas o fallos, "neutro" en otro caso.
        Sé específico y usa información concreta de la nota.
        """)
        
        let analisis: AnalisisNota
        do {
            let r = try await analizador.respond(
                to: "Analiza esta nota de campo: \(arguments.nota)",
                generating: AnalisisNota.self
            )
            analisis = r.content
        } catch {
            // Fallback sin IA
            analisis = AnalisisNota(
                resumen: String(arguments.nota.prefix(120)),
                insights: arguments.etiquetas.isEmpty
                    ? ["Revisar observaciones de esta visita"]
                    : arguments.etiquetas.map { "Seguimiento: \($0)" },
                sentimiento: "neutro"
            )
        }
        
        let nota = NotaVisita(
            fecha: Date(),
            tiendaId: arguments.tiendaId,
            contenidoOriginal: arguments.nota,
            resumenIA: analisis.resumen,
            insights: analisis.insights,
            sentimiento: analisis.sentimiento,
            etiquetas: arguments.etiquetas
        )
        modelContext.insert(nota)
        try? modelContext.save()
        
        return Resultado(
            resumen: analisis.resumen,
            insights: analisis.insights,
            sentimiento: analisis.sentimiento,
            mensajeConfirmacion: "Nota guardada con \(analisis.insights.count) insights para la próxima visita."
        )
    }
}
