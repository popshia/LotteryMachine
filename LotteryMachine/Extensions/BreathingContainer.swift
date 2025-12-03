//
//  Extensions.swift
//  LotteryMachine
//
//  Created by Noah on 2025/12/3.
//
import SwiftUI

struct BreathingContainer: ViewModifier {
    let backgroundColor: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    let lineWidth: CGFloat = 8

    @State private var breathe = false

    func body(content: Content) -> some View {
        content
            //            .background(
            //                RoundedRectangle(cornerRadius: cornerRadius)
            //                    .fill(backgroundColor.opacity(breathe ? 1 : 0.6))
            //                    .scaleEffect(breathe ? 1.02 : 1)
            //            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        borderColor.opacity(breathe ? 1 : 0.6),
                        lineWidth: lineWidth
                    )
                    .shadow(
                        color: borderColor.opacity(breathe ? 0.5 : 0.15),
                        radius: breathe ? 8 : 3
                    )
                    .scaleEffect(breathe ? 1.02 : 1)
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                ) {
                    breathe = true
                }
            }
    }
}

extension View {
    func breathingContainer(
        backgroundColor: Color,
        borderColor: Color,
        cornerRadius: CGFloat
    ) -> some View {
        modifier(
            BreathingContainer(
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                cornerRadius: cornerRadius
            )
        )
    }
}
