//
//  HealthKitService.swift
//  Bimbo
//
//  Created by Azuany Mila Cerón on 5/5/26.
//


//
//  HealthService.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

//
//  HealthKitService.swift
//  Bimbo
//
//  Servicio para integración con HealthKit
//

//
//  HealthKitService.swift
//  Bimbo
//
//  Servicio para integración con HealthKit
//

import Foundation
import HealthKit
import Observation

@Observable
final class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    // Datos publicados (con fallback a valores mock si HealthKit no autoriza)
    var pasosHoy: Int = 7842
    var caloriasQuemadas: Int = 340
    var distanciaKm: Double = 5.2
    var minutosActivos: Int = 45
    var metaPasos: Int = 10000
    
    var autorizado: Bool = false
    
    var progresoMeta: Double {
        min(Double(pasosHoy) / Double(metaPasos), 1.0)
    }
    
    private init() {}
    
    // MARK: - Solicitar autorización
    func solicitarAutorizacion() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit no disponible en este dispositivo")
            return
        }
        
        let tipos: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.appleExerciseTime)
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: tipos)
            autorizado = true
            await cargarDatosHoy()
        } catch {
            print("⚠️ Error de autorización HealthKit: \(error.localizedDescription)")
            // Mantenemos los datos mock como fallback
        }
    }
    
    // MARK: - Cargar datos del día
    func cargarDatosHoy() async {
        await leerPasos()
        await leerCalorias()
        await leerDistancia()
        await leerMinutosActivos()
    }
    
    private func leerPasos() async {
        let tipo = HKQuantityType(.stepCount)
        let valor = await consultarSuma(tipo: tipo, unidad: .count())
        if valor > 0 {
            await MainActor.run { self.pasosHoy = Int(valor) }
        }
    }
    
    private func leerCalorias() async {
        let tipo = HKQuantityType(.activeEnergyBurned)
        let valor = await consultarSuma(tipo: tipo, unidad: .kilocalorie())
        if valor > 0 {
            await MainActor.run { self.caloriasQuemadas = Int(valor) }
        }
    }
    
    private func leerDistancia() async {
        let tipo = HKQuantityType(.distanceWalkingRunning)
        let valor = await consultarSuma(tipo: tipo, unidad: .meterUnit(with: .kilo))
        if valor > 0 {
            await MainActor.run { self.distanciaKm = valor }
        }
    }
    
    private func leerMinutosActivos() async {
        let tipo = HKQuantityType(.appleExerciseTime)
        let valor = await consultarSuma(tipo: tipo, unidad: .minute())
        if valor > 0 {
            await MainActor.run { self.minutosActivos = Int(valor) }
        }
    }
    
    // MARK: - Helper genérico
    private func consultarSuma(tipo: HKQuantityType, unidad: HKUnit) async -> Double {
        let inicioDelDia = Calendar.current.startOfDay(for: Date())
        let predicado = HKQuery.predicateForSamples(withStart: inicioDelDia, end: Date(), options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: tipo,
                quantitySamplePredicate: predicado,
                options: .cumulativeSum
            ) { _, resultado, _ in
                let suma = resultado?.sumQuantity()?.doubleValue(for: unidad) ?? 0
                continuation.resume(returning: suma)
            }
            healthStore.execute(query)
        }
    }
}