//
//  VoiceService.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//


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
    
    private var escuchaActiva = false
    
    var transcripcion: String = ""
    var escuchando: Bool = false
    var hablando: Bool = false
    
    private var onFinishCallback: ((String) -> Void)?
    private var completionHandler: (() -> Void)?
    
    // Aquí guardaremos la voz del osito
    private var vozOsito: AVSpeechSynthesisVoice?
    
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
    
    func hablar(_ texto: String, onComplete: (() -> Void)? = nil) {
        if escuchando { detenerEscucha() }
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
        u.rate = 0.45             // Lo hacemos un poco más lento para compensar que es tan agudo
        u.pitchMultiplier = 1   // <--- EL MÁXIMO POSIBLE DE AGUDO es 2
        u.volume = 1.0
        
        
        hablando = true
        completionHandler = onComplete
        synth.speak(u)
    }
    
    func detenerVoz() {
        synth.stopSpeaking(at: .immediate)
        hablando = false
    }
    
    func iniciarEscucha(onFinish: @escaping (String) -> Void) {
        guard !escuchando else { return }
        transcripcion = ""
        onFinishCallback = onFinish
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch { return }
        
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
        
        task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
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
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        escuchando = false
    }
    func iniciarEscuchaPasiva(onWakeWord: @escaping (String) -> Void) {
        guard !escuchaActiva else { return }
        escuchaActiva = true
        cicloEscucha(onWakeWord: onWakeWord)
    }

    private func cicloEscucha(onWakeWord: @escaping (String) -> Void) {
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true

        task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            guard let texto = result?.bestTranscription.formattedString.lowercased() else {
                if error != nil { self.reiniciarCiclo(onWakeWord: onWakeWord) }
                return
            }

            if texto.contains("osito") {
                let pregunta = texto.components(separatedBy: "osito").last?
                    .trimmingCharacters(in: .whitespaces) ?? ""
                if !pregunta.isEmpty {
                    DispatchQueue.main.async { onWakeWord(pregunta) }
                }
                self.reiniciarCiclo(onWakeWord: onWakeWord)
                return
            }

            if error != nil {
                self.reiniciarCiclo(onWakeWord: onWakeWord)
            }
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            let node = audioEngine.inputNode
            let format = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                req.append(buffer)
            }
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("🐻 Error audio pasivo: \(error)")
        }
    }

    private func reiniciarCiclo(onWakeWord: @escaping (String) -> Void) {
        task?.cancel()
        task = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.cicloEscucha(onWakeWord: onWakeWord)
        }
    }
}

extension VoiceService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didFinish u: AVSpeechUtterance) {
        hablando = false
        completionHandler?()
        completionHandler = nil
    }
    func speechSynthesizer(_ s: AVSpeechSynthesizer, didCancel u: AVSpeechUtterance) {
        hablando = false
        completionHandler = nil
    }
}
