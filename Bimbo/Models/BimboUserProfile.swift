//
//  BimboUserProfile.swift
//  Bimbo
//
//  Created by Azuany Mila Cerón on 5/5/26.
//


//
//  BimboModels.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

//
//  BimboModels.swift
//  Bimbo
//
//  Modelos de datos mockeados para las vistas Splash y Perfil.
//  Usan prefijo "Bimbo" para evitar conflicto con modelos existentes.
//

import Foundation
import SwiftUI

// MARK: - Usuario
struct BimboUserProfile {
    let nombre: String
    let puesto: String
    let email: String
    let iniciales: String
    
    
    static let mock = BimboUserProfile(
        nombre: "Carlos Rodriguez",
        puesto: "Vendedor",
        email: "carlos.rodriguez@bimbo.com",
        iniciales: "CR"
    )
}

// MARK: - Mood
struct BimboMood: Identifiable {
    let id: String
    let label: String
    let emoji: String
    let color: Color
    
    static let opciones: [BimboMood] = [
        BimboMood(id: "feliz", label: "Feliz", emoji: "😊", color: .bmbYellow),
        BimboMood(id: "tranquilo", label: "Tranquilo", emoji: "😌", color: .bmbPilarFisico),
        BimboMood(id: "estresado", label: "Estresado", emoji: "😰", color: .bmbRed),
        BimboMood(id: "cansado", label: "Cansado", emoji: "😴", color: .bmbPilarEmocional),
        BimboMood(id: "motivado", label: "Motivado", emoji: "💪", color: .bmbLightBlue),
        BimboMood(id: "triste", label: "Triste", emoji: "😔", color: .bmbTextSecondary)
    ]
}

// MARK: - Pilar de bienestar
struct BimboPilar: Identifiable {
    let id = UUID()
    let nombre: String
    let porcentaje: Int
    let color: Color
}

// MARK: - Actividad
struct BimboActividad: Identifiable {
    let id = UUID()
    let titulo: String
    let duracionMin: Int
    let pilar: String
    let color: Color
    let icono: String
}

// MARK: - Curso / Logro
struct BimboCurso: Identifiable {
    let id = UUID()
    let titulo: String
    let categoria: String
    let fecha: String
    let duracion: String
    let instructor: String
    let descripcion: String
    let habilidades: [String]
    
    static let mockCursos: [BimboCurso] = [
        BimboCurso(
            titulo: "Liderazgo Consciente",
            categoria: "Desarrollo Personal",
            fecha: "Marzo 2026",
            duracion: "8 horas",
            instructor: "Dr. Carlos Mendoza",
            descripcion: "Aprende a liderar equipos con empatía e inteligencia emocional, fortaleciendo tu capacidad de tomar decisiones bajo presión.",
            habilidades: ["Liderazgo", "Comunicación", "Empatía", "Resiliencia"]
        ),
        BimboCurso(
            titulo: "Manejo del Estrés",
            categoria: "Bienestar Emocional",
            fecha: "Febrero 2026",
            duracion: "4 horas",
            instructor: "Lic. María Torres",
            descripcion: "Técnicas prácticas para identificar y gestionar el estrés laboral mediante mindfulness y respiración consciente.",
            habilidades: ["Mindfulness", "Autoconocimiento", "Respiración"]
        )
    ]
}
