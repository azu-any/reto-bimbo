// Bimbo/Services/VoiceService.swift
//
//  VoiceService.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import Foundation
import Speech
import AVFoundation
import Observation

@Observable
final class VoiceService: NSObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es_MX"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synth = AVSpeechSynthesizer()
    
    var transcripcion: String = ""
    var escuchando: Bool = false
    var hablando: Bool = false
    
    private var onFinishCallback: ((String) -> Void)?
    private var completionHandler: (() -> Void)?
    
    // Aquí guardaremos la voz del osito
    private var vozOsito: AVSpeechSynthesisVoice?
    
    // MARK: - "Oye Osito" (Escucha Continua)
    
    /// Callback when "Oye Osito" is detected. Empty string = just open UI, non-empty = command to process.
    var onOyeOsito: ((String) -> Void)?
    
    /// Whether continuous listening mode is enabled (set to true to keep listening after TTS finishes).
    var escuchaContinuaActiva: Bool = false
    
    /// Internal flag to track if we already notified the UI to open (prevents double-fire).
    private var notificoApertura: Bool = false
    
    override init() {
        super.init()
        synth.delegate = self
        
        // 1. Al arrancar, filtramos solo las voces de México
        let vocesMexicanas = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "es-MX" }
        
        // 2. DEBUG: Imprimir en consola para ver qué voces están disponibles en tu dispositivo físico
        print("🐻 VOCES DE MÉXICO INSTALADAS:")
        for voz in vocesMexicanas {
            print("- Nombre: \(voz.name) | ID: \(voz.identifier)")
        }
        
        // 3. Buscar a Juan de forma flexible
        if let juan = vocesMexicanas.first(where: { $0.name.contains("Juan") }) {
            self.vozOsito = juan
            print("✅ ¡Se encontró a Juan! Usando: \(juan.name)")
        } else {
            // Fallback si no encuentra a Juan
            self.vozOsito = AVSpeechSynthesisVoice(language: "es-MX")
            print("⚠️ No se encontró a Juan. Usando voz por defecto: \(self.vozOsito?.name ?? "Desconocida")")
        }
    }
    
    func solicitarPermisos() async -> Bool {
        let speech = await withCheckedContinuation { c in
            SFSpeechRecognizer.requestAuthorization { c.resume(returning: $0) }
        }
        let mic = await AVAudioApplication.requestRecordPermission()
        return speech == .authorized && mic
    }
    
    // MARK: - TTS (Hablar)
    
    func hablar(_ texto: String, onComplete: (() -> Void)? = nil) {
        // 1. Stop any active listening FIRST so the mic doesn't steal the audio
        if escuchando { detenerEscucha() }
        
        // 2. Configure audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("Audio session error: \(error)") }
        
        let u = AVSpeechUtterance(string: texto)
        
        // Asignar la voz que encontramos en el init
        if let voz = vozOsito {
            u.voice = voz
        }
        
        // ¡LA MAGIA DEL OSITO AL MÁXIMO! 🐻🎈
        u.rate = 0.5             // Velocidad ligeramente más rápida pero controlada
        u.pitchMultiplier = 1.6   // <--- Un tono mucho más agudo y tierno (máximo es 2)
        u.volume = 1.0
        
        hablando = true
        completionHandler = onComplete
        synth.speak(u)
    }
    
    func detenerVoz() {
        synth.stopSpeaking(at: .immediate)
        hablando = false
    }
    
    // MARK: - Escucha Puntual (para dictado de notas, etc.)
    
    func iniciarEscucha(onFinish: @escaping (String) -> Void) {
        guard !escuchando, !hablando else { return }
        transcripcion = ""
        onFinishCallback = onFinish
        
        configurarAudioParaEscucha()
        iniciarMotorReconocimiento { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcripcion = result.bestTranscription.formattedString
                if result.isFinal {
                    let final = self.transcripcion
                    self.detenerEscucha()
                    self.onFinishCallback?(final)
                }
            }
            if error != nil {
                let final = self.transcripcion
                self.detenerEscucha()
                self.onFinishCallback?(final)
            }
        }
    }
    
    func detenerEscucha() {
        guard escuchando else { return }
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        escuchando = false
    }
    
    // MARK: - Escucha Continua ("Oye Osito")
    
    func iniciarEscuchaContinua() {
        escuchaContinuaActiva = true
        arrancarEscuchaContinua()
    }
    
    func detenerEscuchaContinua() {
        escuchaContinuaActiva = false
        detenerEscucha()
    }
    
    private func arrancarEscuchaContinua() {
        // Don't start if we're speaking or already listening
        guard escuchaContinuaActiva, !hablando, !escuchando else { return }
        
        transcripcion = ""
        notificoApertura = false
        
        configurarAudioParaEscucha()
        iniciarMotorReconocimiento { [weak self] result, error in
            guard let self else { return }
            
            if let result {
                let texto = result.bestTranscription.formattedString.lowercased()
                let triggers = ["oye osito", "oye, osito", "hoy osito", "olle osito"]
                
                // Detecta la palabra clave → abre la UI de inmediato (una sola vez)
                if triggers.first(where: { texto.contains($0) }) != nil, !self.notificoApertura {
                    self.notificoApertura = true
                    DispatchQueue.main.async {
                        self.onOyeOsito?("") // String vacío = solo abrir UI
                    }
                }
                
                // Cuando el usuario termina de hablar, extraemos el comando
                if result.isFinal {
                    if let trigger = triggers.first(where: { texto.contains($0) }) {
                        // Extraer lo que viene DESPUÉS del trigger
                        let parts = texto.components(separatedBy: trigger)
                        let comando = parts.dropFirst()
                            .joined(separator: " ")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        self.detenerEscucha()
                        DispatchQueue.main.async {
                            if !comando.isEmpty {
                                self.onOyeOsito?(comando)
                            }
                        }
                        // Don't restart here — the agent will call hablar(),
                        // and the delegate will restart after TTS finishes.
                    } else {
                        // No trigger found, just restart listening
                        self.reiniciarEscuchaContinua()
                    }
                }
            }
            
            if error != nil {
                self.reiniciarEscuchaContinua()
            }
        }
    }
    
    private func reiniciarEscuchaContinua() {
        detenerEscucha()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.arrancarEscuchaContinua()
        }
    }
    
    // MARK: - Helpers
    
    private func configurarAudioParaEscucha() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.duckOthers, .allowBluetooth, .defaultToSpeaker]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("🚨 Audio session error (escucha): \(error)")
        }
    }
    
    private func iniciarMotorReconocimiento(handler: @escaping (SFSpeechRecognitionResult?, Error?) -> Void) {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let req = request else { return }
        req.shouldReportPartialResults = true
        
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            req.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        escuchando = true
        
        task = recognizer?.recognitionTask(with: req, resultHandler: handler)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) {
        hablando = false
        completionHandler?()
        completionHandler = nil
        // After TTS finishes, resume continuous listening if it was active
        if escuchaContinuaActiva {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.arrancarEscuchaContinua()
            }
        }
    }
    
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel u: AVSpeechUtterance) {
        hablando = false
        completionHandler = nil
        if escuchaContinuaActiva {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.arrancarEscuchaContinua()
            }
        }
    }
}
