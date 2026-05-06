//
//  UserProfile.swift
//  Bimbo
//
//  Created by Azuany Mila Cerón on 5/5/26.
//


//
//  Modelos.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

//
//  Models.swift
//  Bimbo
//
//  Modelos de datos mockeados para la app
//

import Foundation
import SwiftUI

// MARK: - Usuario
struct UserProfile {
    let nombre: String
    let puesto: String
    let email: String
    let iniciales: String
    
    // Datos mock por defecto
    static let mock = UserProfile(
        nombre: "Carlos Rodriguez",
        puesto: "Vendedor",
        email: "carlos.rodriguez@bimbo.com",
        iniciales: "CR"
    )
}



// MARK: - Pilar de bienestar
struct PilarBienestar: Identifiable {
    let id = UUID()
    let nombre: String
    let porcentaje: Int
    let color: Color
}

// MARK: - Actividad sugerida
struct ActividadSugerida: Identifiable {
    let id = UUID()
    let titulo: String
    let duracionMin: Int
    let pilar: String
    let color: Color
    let icono: String
}

// MARK: - Logro / Curso
struct Curso: Identifiable {
    let id = UUID()
    let titulo: String
    let categoria: String
    let fecha: String
    let duracion: String
    let instructor: String
    let descripcion: String
    let habilidades: [String]
    
    static let mockCursos: [Curso] = [
            Curso(
                titulo: "Liderazgo Consciente",
                categoria: "Desarrollo Personal",
                fecha: "Marzo 2026",
                duracion: "8 horas",
                instructor: "Dr. Carlos Mendoza",
                descripcion: "Aprende a liderar equipos con empatía e inteligencia emocional, fortaleciendo tu capacidad de tomar decisiones bajo presión.",
                habilidades: ["Liderazgo", "Comunicación", "Empatía", "Resiliencia"]
            ),
            Curso(
                titulo: "Manejo del Estrés",
                categoria: "Bienestar Emocional",
                fecha: "Febrero 2026",
                duracion: "4 horas",
                instructor: "Lic. María Torres",
                descripcion: "Técnicas prácticas para identificar y gestionar el estrés laboral mediante mindfulness y respiración consciente.",
                habilidades: ["Mindfulness", "Autoconocimiento", "Respiración"]
            ),
            Curso(
                titulo: "Excel para Negocios",
                categoria: "Habilidades Técnicas",
                fecha: "Mayo 2026",
                duracion: "10 horas",
                instructor: "Dr. Óscar Mendoza",
                descripcion: "Domina el análisis de datos, tablas dinámicas y macros en Excel para optimizar procesos y mejorar la toma de decisiones corporativas.",
                habilidades: ["Análisis de Datos", "Tablas Dinámicas", "Automatización", "Productividad"]
            ),
            Curso(
                titulo: "Finanzas Básicas",
                categoria: "Educación Financiera",
                fecha: "Mayo 2026",
                duracion: "6 horas",
                instructor: "Dra. Camila Jimenez",
                descripcion: "Comprende los fundamentos de contabilidad, elaboración de presupuestos y análisis de estados financieros de forma sencilla y práctica.",
                habilidades: ["Presupuestos", "Contabilidad", "Análisis Financiero", "Planificación"]
            )
        ]
}