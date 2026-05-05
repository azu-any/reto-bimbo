//
//  AudioService.swift
//  Bimbo
//
//  Servicio de audio para el asistente Osito Bimbo.
//  Gestiona la reproducción de mensajes de voz y feedback sonoro.
//  En producción, se conectaría a un servicio de text-to-speech.
//

import SwiftUI
import Foundation
import AVFoundation

/// Servicio que maneja la reproducción de audio del asistente virtual.
@Observable
class AudioService {
    
    /// Indica si se está reproduciendo audio actualmente.
    var isPlaying: Bool = false
    
    /// Indica si el audio está habilitado globalmente.
    var isEnabled: Bool = true
    
    private var synthesizer = AVSpeechSynthesizer()
    
    /// Reproduce un mensaje de voz usando el sintetizador de texto a voz del sistema.
    /// - Parameter mensaje: Texto que el Osito Bimbo "dirá".
    func reproducirMensaje(_ mensaje: String) {
        guard isEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: mensaje)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.1 // Voz ligeramente más aguda para el Osito
        
        isPlaying = true
        synthesizer.speak(utterance)
        
        // Mock: Simula que el audio termina después de unos segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.isPlaying = false
        }
    }
    
    /// Detiene la reproducción de audio actual.
    func detener() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
}
