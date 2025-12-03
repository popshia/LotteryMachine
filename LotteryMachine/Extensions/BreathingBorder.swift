//
//  Extensions.swift
//  LotteryMachine
//
//  Created by Noah on 2025/12/3.
//
import SwiftUI

struct BreathingBorder: ViewModifier {
    let color: Color
    let cornerRadius: CGFloat
    let lineWidth: CGFloat = 8

    @State private var breathe = false

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        color.opacity(breathe ? 1 : 0.6),
                        lineWidth: lineWidth
                    )
                    .shadow(
                        color: color.opacity(breathe ? 0.5 : 0.15),
                        radius: breathe ? 8 : 3
                    )
                    .scaleEffect(breathe ? 1.02 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true),
                        value: breathe
                    )
            }
            .onAppear {
                breathe = true
            }
    }
}

extension View {
    func breathingBorder(
        color: Color,
        cornerRadius: CGFloat = 10
    ) -> some View {
        modifier(
            BreathingBorder(
                color: color,
                cornerRadius: cornerRadius
            )
        )
    }
}
