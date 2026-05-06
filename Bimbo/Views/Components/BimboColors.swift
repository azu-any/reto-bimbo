//
//  BimboColors.swift
//  Bimbo
//
//  Extensión de Color con los colores corporativos de Bimbo.
//  Define la paleta de colores usada en toda la aplicación.
//

import SwiftUI

extension Color {
    
    // MARK: - Colores Grupo Bimbo (prefijo bmb)
     static let bmbBlue = Color(red: 0/255, green: 61/255, blue: 165/255)        // #003DA5
     static let bmbRed = Color(red: 227/255, green: 24/255, blue: 55/255)        // #E31837
     static let bmbLightBlue = Color(red: 0/255, green: 119/255, blue: 200/255)  // #0077C8
     static let bmbYellow = Color(red: 255/255, green: 209/255, blue: 0/255)     // #FFD100
     
     // MARK: - Pilares de bienestar
     static let bmbPilarEmocional = Color(red: 139/255, green: 92/255, blue: 246/255)  // Morado
     static let bmbPilarFisico = Color(red: 16/255, green: 185/255, blue: 129/255)     // Verde
     static let bmbPilarIntelectual = Color.bmbBlue
     
     // MARK: - Fondos
     static let bmbAppBackground = Color(red: 248/255, green: 250/255, blue: 252/255)
     static let bmbCardBackground = Color.white
     
     // MARK: - Texto
     static let bmbTextPrimary = Color(red: 30/255, green: 41/255, blue: 59/255)
     static let bmbTextSecondary = Color(red: 100/255, green: 116/255, blue: 139/255)
     static let bmbTextTertiary = Color(red: 148/255, green: 163/255, blue: 184/255)
    
//    // MARK: - Colores corporativos Bimbo
//    
//    /// Azul marino Bimbo (#003DA5) - Color primario de marca.
//    static let bimboNavy = Color(red: 0/255, green: 61/255, blue: 165/255)
//    
//    /// Rojo Bimbo (#E32726) - Color de acento/alerta.
//    static let bimboRed = Color(red: 227/255, green: 39/255, blue: 38/255)
//    
//    /// Crema Bimbo (#FFF8F0) - Fondo cálido.
//    static let bimboCream = Color(red: 255/255, green: 248/255, blue: 240/255)
//    
//    /// Gris Bimbo (#E5E7EB) - Bordes y separadores.
//    static let bimboGray = Color(red: 229/255, green: 231/255, blue: 235/255)
}
