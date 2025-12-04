//
//  BreathingContainer.swift
//  LotteryMachine
//
//  Created by Noah on 2025/12/3.
//
import SwiftUI

// MARK: - BreathingContainer ViewModifier

/// A `ViewModifier` that adds a breathing animation effect to a view's border.
///
/// This modifier creates a pulsating effect by animating the opacity, shadow, and scale
/// of a rounded rectangle overlay. It's designed to draw attention to a view in a subtle,
/// visually appealing way.
struct BreathingContainer: ViewModifier {
    // MARK: Properties

    /// The background color of the container.
    let backgroundColor: Color

    /// The border color that will be animated.
    let borderColor: Color

    /// The corner radius for the rounded rectangle.
    let cornerRadius: CGFloat

    /// The width of the border.
    let lineWidth: CGFloat = 8

    /// A state variable that toggles to drive the breathing animation.
    @State private var breathe = false

    // MARK: Body

    /// The body of the view modifier.
    ///
    /// This function applies an overlay to the content view. The overlay is a `RoundedRectangle`
    /// with a stroke and shadow that animate based on the `breathe` state.
    /// - Parameter content: The content to which the modifier is applied.
    /// - Returns: A view with the breathing container effect.
    func body(content: Content) -> some View {
        content
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

// MARK: - View Extension

extension View {
    /// Applies a breathing container effect to the view.
    ///
    /// This is a convenience method to make applying the `BreathingContainer` modifier easier.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color of the container.
    ///   - borderColor: The color of the breathing border.
    ///   - cornerRadius: The corner radius for the container's shape.
    /// - Returns: A view modified with the breathing container effect.
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
