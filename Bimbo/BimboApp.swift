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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Nota.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
