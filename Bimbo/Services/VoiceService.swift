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
    // Locale con cadena de fallback: es_MX → es-419 → es → device locale
    private static func crearReconocedor() -> SFSpeechRecognizer? {
        let candidatos = ["es_MX", "es-MX", "es-419", "es", Locale.current.identifier]
        for id in candidatos {
            if let r = SFSpeechRecognizer(locale: Locale(identifier: id)), r.isAvailable {
                print("🐻 SFSpeechRecognizer disponible con locale: \(id)")
                return r
            }
        }
        print("🚨 No se encontró ningún reconocedor disponible — usando es_MX sin verificar")
        return SFSpeechRecognizer(locale: Locale(identifier: "es_MX"))
    }
    private let recognizer: SFSpeechRecognizer? = VoiceService.crearReconocedor()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synth = AVSpeechSynthesizer()
    
    var transcripcion: String = ""
    var escuchando: Bool = false
    var hablando: Bool = false
    
    /// Indica si estamos capturando una pregunta o comando activo (tras detectar trigger o por dictado)
    var capturandoComando: Bool = false
    
    private var onFinishCallback: ((String) -> Void)?
    private var completionHandler: (() -> Void)?
    
    /// Temporizador de silencio: para el mic automáticamente tras ~2s sin hablar.
    private var silenceTimer: Timer?
    
    // Aquí guardaremos la voz del osito
    private var vozOsito: AVSpeechSynthesisVoice?
    
    // MARK: - "Oye Osito" (Escucha Continua)
    
    /// Callback when "Oye Osito" is detected. Empty string = just open UI, non-empty = command to process.
    var onOyeOsito: ((String) -> Void)?
    
    /// Whether continuous listening mode is enabled (set to true to keep listening after TTS finishes).
    var escuchaContinuaActiva: Bool = false
    
    /// Timer that auto-restarts recognition every 45s to avoid iOS ~60s session timeout.
    private var oyeOsitoTimer: Timer?
    
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
        if let juan = vocesMexicanas.first(where: { $0.name.contains("Angélica") }) {
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
        u.rate = 0.45             // Velocidad ligeramente más rápida pero controlada
        u.pitchMultiplier = 1.15// <--- Un tono mucho más agudo y tierno (máximo es 2)
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
        capturandoComando = true
        
        configurarAudioParaEscucha()
        iniciarMotorReconocimiento { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcripcion = result.bestTranscription.formattedString
                
                // Reiniciar el temporizador de silencio cada vez que llega texto nuevo
                if !self.transcripcion.isEmpty {
                    self.reiniciarTimerSilencio()
                }
                
                if result.isFinal {
                    self.silenceTimer?.invalidate()
                    self.silenceTimer = nil
                    let final = self.transcripcion
                    self.detenerEscucha()
                    self.capturandoComando = false
                    self.onFinishCallback?(final)
                }
            }
            if error != nil {
                self.silenceTimer?.invalidate()
                self.silenceTimer = nil
                let final = self.transcripcion
                self.detenerEscucha()
                self.capturandoComando = false
                self.onFinishCallback?(final)
            }
        }
    }
    
    /// Reinicia el timer de silencio. Si no llega speech en 2s, para el mic.
    private func reiniciarTimerSilencio() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self else { return }
            guard self.escuchando, self.capturandoComando else { return }
            print("🐻 Silencio detectado — parando mic automáticamente")
            let capturado = self.transcripcion.trimmingCharacters(in: .whitespacesAndNewlines)
            self.detenerEscucha()
            self.capturandoComando = false
            self.onFinishCallback?(capturado)
        }
    }
    
    func detenerEscucha() {
        silenceTimer?.invalidate()
        silenceTimer = nil
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
        // Auto-reinicio cada 45s para evitar timeout del recognizer de iOS (~60s máx)
        oyeOsitoTimer?.invalidate()
        oyeOsitoTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            guard let self = self, self.escuchaContinuaActiva, !self.hablando else { return }
            self.reiniciarEscuchaContinua()
        }
    }
    
    func detenerEscuchaContinua() {
        oyeOsitoTimer?.invalidate()
        oyeOsitoTimer = nil
        escuchaContinuaActiva = false
        detenerEscucha()
    }
    
    private func arrancarEscuchaContinua() {
        // Solo detecta el trigger "Oye Osito".
        // La captura real de la pregunta la maneja el botón PTT del chat.
        guard escuchaContinuaActiva, !hablando, !escuchando else { return }
        
        transcripcion = ""
        notificoApertura = false
        
        configurarAudioParaEscucha()
        iniciarMotorReconocimiento { [weak self] result, error in
            guard let self else { return }
            
            if let result {
                let texto = result.bestTranscription.formattedString.lowercased()
                let triggers = [
                    "oye osito", "oye, osito",
                    "hoy osito", "oye ositos",
                    "oye sito",  "hey osito",
                    "ole osito", "olle osito"
                ]
                
                // Detecta el trigger → notificar UNA sola vez para abrir el chat + activar PTT
                if triggers.first(where: { texto.contains($0) }) != nil, !self.notificoApertura {
                    self.notificoApertura = true
                    print("🐻 ¡Trigger 'Oye Osito' detectado! Notificando...")
                    // Detener escucha: el PTT tomará control cuando el chat abra
                    self.detenerEscucha()
                    DispatchQueue.main.async {
                        self.onOyeOsito?("")  // Vacío = solo abrir UI y activar PTT
                    }
                    return
                }
                
                // isFinal sin trigger → reiniciar para seguir escuchando
                if result.isFinal {
                    let textoFinal = texto
                    guard !textoFinal.isEmpty else {
                        self.reiniciarEscuchaContinua()
                        return
                    }
                    self.reiniciarEscuchaContinua()
                }
            }
            
            if error != nil {
                // Errores transitorios: reiniciar silenciosamente
                self.reiniciarEscuchaContinua()
            }
        }
    }
    
    private func reiniciarEscuchaContinua() {
        detenerEscucha()
        // Delay generoso para que el audio engine se estabilice y evitar bucle de errores
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
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
        req.requiresOnDeviceRecognition = false
        
        // Resetear el engine para que obtenga un formato de hardware válido
        // después del cambio de categoría de audio session.
        audioEngine.reset()
        
        let input = audioEngine.inputNode
        let hwFormat = input.outputFormat(forBus: 0)
        
        // Validar formato. Si sampleRate == 0 el hardware no está listo.
        let recordingFormat: AVAudioFormat
        if hwFormat.sampleRate > 0 && hwFormat.channelCount > 0 {
            recordingFormat = hwFormat
        } else {
            // Fallback: 16 kHz mono, que SFSpeechRecognizer siempre acepta
            print("⚠️ Formato de hardware inválido (sr=\(hwFormat.sampleRate)), usando fallback 16kHz mono")
            guard let fallback = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 1) else {
                print("🚨 No se pudo crear formato de fallback")
                return
            }
            recordingFormat = fallback
        }
        
        input.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            req.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            escuchando = true
        } catch {
            print("🚨 audioEngine.start() falló: \(error)")
            input.removeTap(onBus: 0)
            return
        }
        
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
