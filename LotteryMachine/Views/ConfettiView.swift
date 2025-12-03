//
//  ConfettiView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

/// A view that displays a confetti animation.
struct ConfettiView: View {
    // MARK: - Body

    /// The content and behavior of the view.
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<100) { _ in
                    ConfettiParticle(screenSize: geometry.size)
                }
            }
        }
    }
}

/// A view representing a single particle in the confetti animation.
struct ConfettiParticle: View {
    // MARK: - State

    /// The horizontal position of the particle.
    @State private var x: CGFloat

    /// The vertical position of the particle.
    @State private var y: CGFloat

    /// The rotation angle of the particle.
    @State private var rotation = Angle.degrees(.random(in: 0...360))

    /// The scale of the particle.
    @State private var scale: CGFloat = .random(in: 0.5...1.5)

    /// The opacity of the particle.
    @State private var opacity: Double = 1.0

    /// The theme instance for styling.
    private let theme: SeasonalTheme = ChineseNewYearTheme()

    // MARK: - Properties

    /// The color of the particle, chosen randomly.
    let particleColor: Color

    /// A boolean indicating whether the particle is a circle or a rectangle.
    let isCircle: Bool

    /// The duration of the upward animation.
    let upAnimationDuration = Double.random(in: 1...2)

    /// The size of the screen, used for positioning and animation.
    private let screenSize: CGSize

    /// Initializes a new confetti particle.
    ///
    /// - Parameter screenSize: The size of the screen.
    init(screenSize: CGSize) {
        self.screenSize = screenSize
        _x = State(initialValue: screenSize.width / 2)
        _y = State(initialValue: screenSize.height)

        // Initialize properties that depend on other instance members here.
        self.isCircle = Bool.random()

        // Since `red` depends on ColorScheme, use a fixed red matching the theme’s light color.
        self.particleColor = [theme.red(for: .light), theme.gold].randomElement()!
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isCircle {
                Circle()
                    .fill(particleColor)
            } else {
                Rectangle()
                    .fill(particleColor)
            }
        }
        .frame(width: 10, height: 10)
        .scaleEffect(scale)
        .rotationEffect(rotation)
        .position(x: x, y: y)
        .opacity(opacity)
        .onAppear {
            // Animate the particle moving upwards and spreading out.
            withAnimation(Animation.easeOut(duration: upAnimationDuration)) {
                self.y -= .random(
                    in: screenSize.height * 0.4...screenSize.height * 0.7
                )
                self.x += .random(
                    in: -screenSize.width / 2...screenSize.width / 2
                )
                self.rotation += .degrees(.random(in: -180...180))
            }

            // After the upward animation, animate the particle falling down.
            let downAnimationDuration = upAnimationDuration * 1.5
            withAnimation(
                Animation.easeIn(duration: downAnimationDuration).delay(
                    upAnimationDuration
                )
            ) {
                self.y += screenSize.height + 20 // Fall below the screen to ensure it's hidden.
                self.rotation += .degrees(.random(in: -180...180))
            }

            // Fade out the particle as it falls.
            withAnimation(
                Animation.linear(duration: downAnimationDuration).delay(
                    upAnimationDuration * 1.2
                )
            ) {
                self.opacity = 0
            }
        }
    }
}
