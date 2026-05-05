//
//  BimboApp.swift
//  Bimbo
//
//  Punto de entrada de la aplicación.
//  Configura SwiftData con el modelo Nota para persistencia local
//  y lanza la vista raíz ContentView.
//

import SwiftUI
import SwiftData

@main
struct BimboApp: App {
    
    /// Contenedor de SwiftData para persistencia local de notas.
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Nota.self,
//        ])
//        let modelConfiguration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false
//        )
//        
//        do {
//            return try ModelContainer(
//                for: schema,
//                configurations: [modelConfiguration]
//            )
//        } catch {
//            fatalError("No se pudo crear el ModelContainer: \(error)")
//        }
//    }()
    
    let container: ModelContainer
    
    init() {
        do {
            let newContainer = try ModelContainer(
                for: Tienda.self, ProductoCatalogo.self, Visita.self,
                ItemPedido.self, ItemVenta.self, NotaVisita.self
            )
            self.container = newContainer
            let ctx = newContainer.mainContext
            Task { @MainActor in
                Self.sembrarDatosIniciales(ctx)
            }
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    
    // MARK: - Sembrado
    
    @MainActor
    static func sembrarDatosIniciales(_ ctx: ModelContext) {
        
        // ── 1. Tienda ──────────────────────────────────────────────────────
        let descT = FetchDescriptor<Tienda>()
        let tiendas = (try? ctx.fetch(descT)) ?? []
        if let existing = tiendas.first(where: { $0.id == 15766 }) {
            existing.latitud  = 19.37348
            existing.longitud = -99.18335
        } else {
            ctx.insert(Tienda(
                id: 15766, nombre: "Doña Lupita", direccion: "Av. Reforma 123",
                latitud: 19.37348, longitud: -99.18335, propietario: "Lupita"
            ))
        }
        
        // ── 2. Catálogo ────────────────────────────────────────────────────
        let descP = FetchDescriptor<ProductoCatalogo>()
        if ((try? ctx.fetch(descP).count) ?? 0) == 0 {
            let productos: [(String, String, String, Int, Double)] = [
                ("73", "Pan Multigrano Linaza",  "Pan",        2, 48.0),
                ("41", "Wonder 100% mediano Ext",           "Pastelillo", 3, 12.0),
                ("72", "Mini Doraditas",       "Pastelillo", 2, 25.0),
                // ("BIM004", "Pingüinos",         "Pastelillo", 4, 14.0),
                // ("BIM005", "Mantecadas",        "Pastelillo", 3, 18.0),
                // ("106", "Wonder 100% mediano",         "Pan",        2, 32.0),
                // ("BIM007", "Roles Canela",      "Pastelillo", 2, 22.0)
            ]
            for p in productos {
                ctx.insert(ProductoCatalogo(
                    productoId: p.0, nombre: p.1, categoria: p.2,
                    vidaUtilSemanas: p.3, precio: p.4
                ))
            }
        }
        
        // ── 3. Historial previo — solo si no existe ────────────────────────
        let descVCheck = FetchDescriptor<Visita>(
            predicate: #Predicate { $0.tiendaId == 15766 && $0.pedidoConfirmado == true }
        )
        guard ((try? ctx.fetch(descVCheck)) ?? []).isEmpty else {
            try? ctx.save()
            return
        }
        
        func diasAtras(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
        }
        
        func agregarVisita(diasPasados: Int, pedido: [(String,String,Int)],
                           ventas: [(String,String,Int)], ctx: ModelContext) -> Visita {
            let v = Visita(fecha: diasAtras(diasPasados), tiendaId: 15766)
            ctx.insert(v)
            for (pid, nombre, uni) in pedido {
                let item = ItemPedido(productoId: pid, nombreProducto: nombre,
                                      unidades: uni, fechaEntrega: diasAtras(diasPasados))
                ctx.insert(item)
                v.itemsConfirmados.append(item)
            }
            for (pid, nombre, uni) in ventas {
                let item = ItemVenta(productoId: pid, nombreProducto: nombre, unidadesVendidas: uni)
                ctx.insert(item)
                v.itemsVendidos.append(item)
            }
            v.pedidoConfirmado = true
            return v
        }
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 1 — hace 84 días — Rodrigo Sánchez
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 84,
            pedido: [
                ("73","Pan Multigrano Linaza",8), ("41","Wonder 100% mediano Ext",12),
                ("72","Mini Doraditas",6),      ("106","Wonder 100% mediano",4)
            ],
            ventas: [
                ("73","Pan Multigrano Linaza",6), ("41","Wonder 100% mediano Ext",10),
                ("72","Mini Doraditas",4),      ("106","Wonder 100% mediano",3)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(84), tiendaId: 15766, vendedor: "Rodrigo Sánchez",
            contenidoOriginal: "Primera visita a Doña Lupita. Tienda pequeña pero con buen tráfico matutino. Lupita es amigable pero muy ocupada. Prefiere que lleguemos antes de las 9am. Colocamos los Wonder 100% mediano Ext junto a la caja registradora y se vieron bien. Pan Multigrano Linaza en la parte baja del estante, poca visibilidad.",
            resumenIA: "Primera visita exitosa. Lupita receptiva. Wonder 100% mediano Ext junto a caja. Pan Multigrano Linaza con baja visibilidad — necesita reubicación.",
            insights: [
                "Llegar ANTES de 9am — Lupita tiene pico de clientes después de esa hora",
                "Wonder 100% mediano Ext junto a caja registradora: posición ganadora, mantener siempre",
                "Pan Multigrano Linaza en zona baja — reubicar a nivel de ojos en próxima visita",
                "Tienda con buen tráfico matutino entre 7-9am"
            ],
            sentimiento: "positivo",
            etiquetas: ["Cambio de horario", "Recomendación"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 2 — hace 70 días — Rodrigo Sánchez
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 70,
            pedido: [
                ("73","Pan Multigrano Linaza",10), ("41","Wonder 100% mediano Ext",16),
                ("72","Mini Doraditas",6),          ("106","Wonder 100% mediano",4)
            ],
            ventas: [
                ("73","Pan Multigrano Linaza",7), ("41","Wonder 100% mediano Ext",14),
                ("BIM004","Pingüinos",6),         ("106","Wonder 100% mediano",4)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(70), tiendaId: 15766, vendedor: "Rodrigo Sánchez",
            contenidoOriginal: "Moví el Pan Multigrano Linaza al estante del centro y ya se ve mejor. Lupita contenta con el acomodo. Los Pingüinos quedaron al nivel de los ojos como sugerí y ya hubo venta desde el primer día según ella. Wonder 100% mediano Ext se sigue vendiendo fuerte. Hay una panadería enfrente que le quita clientes de pan de caja los lunes.",
            resumenIA: "Reubicación Pan Multigrano Linaza exitosa. Pingüinos a nivel de ojos confirmados. Wonder 100% mediano Ext líder. Panadería local compite los lunes.",
            insights: [
                "Pingüinos a nivel de ojos — Lupita confirmó ventas desde primer día de acomodo",
                "Panadería enfrente afecta Pan Multigrano Linaza los LUNES — no reponer ese día",
                "Pan Multigrano Linaza reubicado al centro del estante: mejora de visibilidad confirmada",
                "Wonder 100% mediano Ext sigue siendo el producto estrella número uno de esta tienda"
            ],
            sentimiento: "positivo",
            etiquetas: ["Recomendación"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 4 — hace 56 días — Rodrigo Sánchez
        // (semana 3 fue vacaciones, no hubo visita — Lupita quedó sin Wonder 100% mediano Ext)
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 56,
            pedido: [
                ("73","Pan Multigrano Linaza",10), ("41","Wonder 100% mediano Ext",20),
                ("BIM004","Pingüinos",12),                   ("106","Wonder 100% mediano",6)           ],
            ventas: [
                ("73","Pan Multigrano Linaza",6), ("41","Wonder 100% mediano Ext",18),
                ("106","Wonder 100% mediano",5)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(56), tiendaId: 15766, vendedor: "Rodrigo Sánchez",
            contenidoOriginal: "No vine la semana pasada por vacaciones. Lupita algo molesta porque se le acabaron los Wonder 100% mediano Ext. Hay que asegurar que no falten. Introduje Mantecadas y Roles Canela. Las Mantecadas van bien pero los Roles Canela no se mueven — Lupita dice que sus clientes no conocen ese producto. Terminal de pago fallando de nuevo, cobré en efectivo.",
            resumenIA: "Faltante Wonder 100% mediano Ext por ausencia generó molestia. Mantecadas bien recibidas. Roles Canela sin demanda. Terminal con falla recurrente.",
            insights: [
                "NUNCA faltar Wonder 100% mediano Ext — es el producto que más molestia genera si no hay stock",
                "Roles Canela SIN demanda conocida — clientes no conocen el producto en esta zona",
                "Terminal de pago con falla RECURRENTE — llevar efectivo de cambio siempre",
                "Mantecadas bien aceptadas — incluir en mix fijo desde ahora",
                "Si hay ausencia de más de 1 semana, asegurar pedido mínimo de Wonder 100% mediano Ext"
            ],
            sentimiento: "neutro",
            etiquetas: ["Cliente molesto", "Falla pago", "Recomendación"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 6 — hace 42 días — Rodrigo Sánchez
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 42,
            pedido: [
                ("73","Pan Multigrano Linaza",8), ("41","Wonder 100% mediano Ext",24),
                ("72","Mini Doraditas",10),   
                ("106","Wonder 100% mediano",6)
            ],
            ventas: [
                ("73","Pan Multigrano Linaza",5), ("41","Wonder 100% mediano Ext",20),
                ("72","Mini Doraditas",8),   ("106","Wonder 100% mediano",4)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(42), tiendaId: 15766, vendedor: "Rodrigo Sánchez",
            contenidoOriginal: "Visita normal. Lupita preguntó si podemos incluir más productos de temporada en septiembre para Día de Muertos. Las Mini Doraditas tuvieron buena semana porque el hijo de Lupita (Memo) las promovió entre los niños de la escuela cercana. Pedí autorización para poner un exhibidor de Bimbo junto a la puerta de entrada.",
            resumenIA: "Oportunidad Día de Muertos confirmada. Donas impulsadas por escuela. Solicitud de exhibidor en puerta de entrada.",
            insights: [
                "Oportunidad estacional Día de Muertos — Lupita dispuesta a productos de temporada",
                "Mini Doraditas tienen impulso natural por escuela cercana — posicionar cerca de entrada",
                "Solicitar exhibidor en puerta de entrada — Lupita mostró interés en recibirlo",
                "Wonder 100% mediano Ext mantiene liderazgo — nunca bajar de 20 unidades por pedido"
            ],
            sentimiento: "positivo",
            etiquetas: ["Promoción", "Recomendación"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 8 — hace 28 días — Rodrigo Sánchez (ÚLTIMA VISITA)
        // Se enferma justo después — nota de traspaso
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 28,
            pedido: [
                ("73","Pan Multigrano Linaza",8), ("41","Wonder 100% mediano Ext",24),
                ("72","Mini Doraditas",10),     
                ("106","Wonder 100% mediano",6)
            ],
            ventas: [
                ("73","Pan Multigrano Linaza",6), ("41","Wonder 100% mediano Ext",22),
                ("72","Mini Doraditas",9),  
                ("106","Wonder 100% mediano",6)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(28), tiendaId: 15766, vendedor: "Rodrigo Sánchez",
            contenidoOriginal: "Me voy a enfermar probablemente, me siento mal. Esta puede ser mi última visita por un tiempo. Importante para quien me cubra: Lupita SOLO acepta pagos antes de las 9am o en efectivo porque su terminal falla siempre. El Wonder 100% mediano Ext nunca puede faltar. Los Pingüinos al nivel de los ojos. No insistir en Roles Canela, Lupita ya los rechazó varias veces. El hijo de Lupita se llama Memo y a veces ayuda y acepta el pedido si ella no está.",
            resumenIA: "Nota de traspaso por enfermedad de Rodrigo. Instrucciones clave: horario 9am, Wonder 100% mediano Ext crítico, Pingüinos zona ocular, evitar Roles Canela, contacto alterno Memo.",
            insights: [
                "TRASPASO: Rodrigo Sánchez de baja — nueva cuenta para otro vendedor",
                "Horario CRÍTICO: visitar antes de 9am o cobrar en efectivo (terminal falla siempre)",
                "Wonder 100% mediano Ext innegociable — mínimo 20 productos por pedido en todo momento",
                "Contacto alterno: MEMO (hijo de Lupita) acepta pedidos si Lupita no está disponible",
                "NO ofrecer Roles Canela — rechazado explícitamente en múltiples visitas",
                "Pingüinos SIEMPRE al nivel de los ojos — posición más rentable confirmada"
            ],
            sentimiento: "neutro",
            etiquetas: ["Cambio de horario", "Falla pago", "Recomendación"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 9 — hace 14 días — Carlos Mendoza (nueva cuenta)
        // Primera visita del nuevo vendedor apoyándose en historial de Rodrigo
        // ══════════════════════════════════════════════════════════════════
        _ = agregarVisita(
            diasPasados: 14,
            pedido: [
                ("73","Pan Multigrano Linaza",8), ("41","Wonder 100% mediano Ext",24),
                ("72","Mini Doraditas",8),    
                ("106","Wonder 100% mediano",6)
            ],
            ventas: [
                ("73","Pan Multigrano Linaza",5), ("41","Wonder 100% mediano Ext",20),
                ("72","Mini Doraditas",7),     ("106","Wonder 100% mediano",4)
            ],
            ctx: ctx
        )
        ctx.insert(NotaVisita(
            fecha: diasAtras(14), tiendaId: 15766, vendedor: "Carlos Mendoza",
            contenidoOriginal: "Primera visita mía a Doña Lupita. Preguntó por Rodrigo, le expliqué que está enfermo. Se puso algo seria pero fue amable. Llegué a las 8:45am como indicaban los apuntes del anterior vendedor y funcionó perfecto. Terminal falló como siempre, cobré en efectivo. Memo estuvo presente y ayudó a acomodar los productos. Puse los Pingüinos al nivel de los ojos y Lupita lo notó y agradeció que siguiéramos el mismo orden.",
            resumenIA: "Transición exitosa con Carlos. Historial de Rodrigo fue clave para no perder confianza. Horario 8:45am funcionó. Terminal falló, cobro en efectivo. Memo colaborativo.",
            insights: [
                "Transición suave — historial previo fue determinante para ganar confianza de Lupita",
                "Memo (hijo) es aliado importante y colabora con acomodo sin que se le pida",
                "Terminal SIEMPRE falla — cobro en efectivo es la norma en esta tienda",
                "Lupita valora continuidad en el acomodo — reconoció Pingüinos en su lugar correcto"
            ],
            sentimiento: "positivo",
            etiquetas: ["Cambio de horario", "Falla pago"]
        ))
        
        // ══════════════════════════════════════════════════════════════════
        // SEMANA 10 — hace 7 días — Carlos Mendoza (visita más reciente)
        //
        // CADUCIDADES CALCULADAS para la próxima visita (hoy):
        //   73 Pan Multigrano Linaza (vida 14d)  → entregado hace 11d → 3d restantes → ⚠️ URGENTE
        //   106 Wonder 100% mediano (vida 14d)  → entregado hace 11d → 3d restantes → ⚠️ URGENTE
        //   72 Mini Doraditas (vida 14d)→ entregado hace  9d → 5d restantes → 🟡 MEDIA
        //   BIM007 Roles Canela (vida14d)→ entregado hace  8d → 6d restantes → 🟡 MEDIA
        //   41 Wonder 100% mediano Ext (vida 21d)    → entregado hace  7d →14d restantes → ✅ OK
        //   BIM004 Pingüinos (vida 28d)  → entregado hace  7d →21d restantes → ✅ OK
        //   BIM005 Mantecadas (vida 21d) → entregado hace  7d →14d restantes → ✅ OK
        // ══════════════════════════════════════════════════════════════════
        do {
            let v = Visita(fecha: diasAtras(7), tiendaId: 15766)
            ctx.insert(v)
            
            let itemsPedido: [(String, String, Int, Int)] = [
                // (productoId, nombre, cantidad, diasEntregado)
                ("73", "Pan Multigrano Linaza", 10, 11),  // ⚠️ URGENTE al llegar hoy
                ("41", "Wonder 100% mediano Ext",          24,  7),  // ✅ OK
                ("72", "Mini Doraditas",       8,  9),  // 🟡 MEDIA
                ("106", "Wonder 100% mediano",          6, 11),  // ⚠️ URGENTE al llegar hoy
            ]
            for (pid, nombre, uni, diasAntiguedad) in itemsPedido {
                let item = ItemPedido(productoId: pid, nombreProducto: nombre,
                                      unidades: uni, fechaEntrega: diasAtras(diasAntiguedad))
                ctx.insert(item)
                v.itemsConfirmados.append(item)
            }
            
            let ventas: [(String, String, Int)] = [
                ("73","Pan Multigrano Linaza", 4),
                ("41","Wonder 100% mediano Ext",         18),
                ("72","Mini Doraditas",      6),
                ("106","Wonder 100% mediano",         3)
            ]
            for (pid, nombre, uni) in ventas {
                let item = ItemVenta(productoId: pid, nombreProducto: nombre, unidadesVendidas: uni)
                ctx.insert(item)
                v.itemsVendidos.append(item)
            }
            v.pedidoConfirmado = true
            
            ctx.insert(NotaVisita(
                fecha: diasAtras(7), tiendaId: 15766, vendedor: "Carlos Mendoza",
                contenidoOriginal: "Todo bien hoy. Llegué a las 8:30am, Lupita ya estaba lista. Memo nos ayudó a bajar los productos. Lupita pidió que la próxima vez traigamos más Wonder 100% mediano Ext porque dice que se le acaba antes del jueves. También mencionó que quiere probar las Donas de Chocolate si existen. Terminal falló de nuevo, cobro en efectivo como siempre. Noto que el Pan Multigrano Linaza y los Wonder 100% mediano que entregamos llevan ya varios días en el estante — hay que revisarlos en la próxima visita porque podrían estar por caducar.",
                resumenIA: "Visita fluida. Wonder 100% mediano Ext insuficiente (se agota antes del jueves). Demanda de Donas de Chocolate. Pan Multigrano Linaza y Wonder 100% mediano próximos a caducar en siguiente visita.",
                insights: [
                    "Aumentar Wonder 100% mediano Ext a mínimo 28 productos — se agota antes del jueves según Lupita",
                    "Oportunidad: Donas de Chocolate — Lupita preguntó explícitamente por ellas",
                    "⚠️ PAN BIMBO y BIMBOLLOS próximos a caducar — revisar y retirar en esta visita",
                    "Terminal de pago NO se ha reparado — cobro en efectivo es obligatorio aquí",
                    "Hora ideal de llegada: 8:30am — Lupita y Memo listos a esa hora"
                ],
                sentimiento: "positivo",
                etiquetas: ["Recomendación", "Falla pago"]
            ))
        }
        
        try? ctx.save()
    }
}
