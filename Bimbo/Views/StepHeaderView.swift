//
//  StepHeaderView.swift
//  Bimbo
//
//  Created by Martha Heredia Andrade on 05/05/26.
//

// StepHeaderView.swift
import SwiftUI

struct StepHeaderView: View {
    let step: Int
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 0) {
            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.15))
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [Color.bimboRed, Color.bimboRed.opacity(0.75)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * CGFloat(step) / CGFloat(AppStep.totalSteps))
                        .animation(.spring(duration: 0.6), value: step)
                }
            }
            .frame(height: 4)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text("\(step) / \(AppStep.totalSteps)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.bimboRed)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.bimboRed.opacity(0.1)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
}
