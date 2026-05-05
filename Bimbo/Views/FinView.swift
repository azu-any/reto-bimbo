//
//  FinView.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

import SwiftUI

struct FinView: View {
    let agent: OsitoAgent
    
    var body: some View {
        ZStack {
            Color.bimboCream.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Text("🐻").font(.system(size: 100))
                Text("¡Visita completada!").font(.largeTitle).fontWeight(.bold)
                if !agent.ultimoMensajeOsito.isEmpty {
                    Text(agent.ultimoMensajeOsito)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32).foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
}
