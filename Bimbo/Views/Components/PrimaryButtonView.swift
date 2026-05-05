//
//  PrimaryButtonView.swift
//  Bimbo
//
//  Botón primario reutilizable con variantes de estilo.
//  Soporta estados: primary, outline, success, y deshabilitado.
//

import SwiftUI

/// Variantes visuales del botón.
enum ButtonVariant {
    case primary
    case outline
    case success
}

/// Botón primario de la app con animación de tap y variantes de estilo.
struct PrimaryButtonView: View {
    
    /// Texto del botón.
    let title: String
    
    /// Ícono SF Symbol opcional al final del texto.
    var iconName: String? = nil
    
    /// Variante visual del botón.
    var variant: ButtonVariant = .primary
    
    /// Indica si el botón está deshabilitado.
    var disabled: Bool = false
    
    /// Indica si el botón debe pulsar (animación).
    var pulsating: Bool = false
    
    /// Acción al tocar el botón.
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            if !disabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                Text(title)
                    .fontWeight(.semibold)
                
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: variant == .outline ? 2 : 0)
            )
            .opacity(disabled ? 0.5 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .disabled(disabled)
        .pressEvents(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .modifier(PulsatingModifier(isPulsating: pulsating && !disabled))
    }
    
    // MARK: - Colores por variante
    
    private var backgroundColor: Color {
        switch variant {
        case .primary: return .bimboNavy
        case .outline: return .clear
        case .success: return .green
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary: return .white
        case .outline: return .bimboNavy
        case .success: return .white
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .outline: return .bimboNavy
        default: return .clear
        }
    }
}

// MARK: - Modificador de pulsación

/// Modificador que agrega una animación de pulso al botón.
struct PulsatingModifier: ViewModifier {
    let isPulsating: Bool
    @State private var opacity: Double = 1.0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                if isPulsating {
                    withAnimation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        opacity = 0.7
                    }
                }
            }
    }
}

// MARK: - Helper para detectar eventos de presión

/// Extensión que añade detección de presión/liberación a cualquier View.
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PrimaryButtonView(title: "Continuar", iconName: "chevron.right", action: {})
        PrimaryButtonView(title: "Outline", variant: .outline, action: {})
        PrimaryButtonView(title: "¡Listo!", variant: .success, action: {})
        PrimaryButtonView(title: "Deshabilitado", disabled: true, action: {})
    }
    .padding()
}
