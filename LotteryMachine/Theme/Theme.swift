//
//  Theme.swift
//  LotteryMachine
//
//  Created by Noah on 2025/12/3.
//
import SwiftUI

// MARK: - SeasonalTheme Protocol

/// A protocol that defines the color scheme for a seasonal theme.
///
/// This protocol ensures that any theme conforming to it will provide the necessary
/// colors and gradients for both light and dark color schemes.
protocol SeasonalTheme {
    /// Returns the primary red color for the specified color scheme.
    /// - Parameter scheme: The current `ColorScheme` (.light or .dark).
    /// - Returns: The primary red `Color`.
    func red(for scheme: ColorScheme) -> Color

    /// Returns a darker shade of red for the specified color scheme.
    /// - Parameter scheme: The current `ColorScheme` (.light or .dark).
    /// - Returns: The dark red `Color`.
    func darkRed(for scheme: ColorScheme) -> Color

    /// The primary gold color for the theme.
    var gold: Color { get }

    /// Returns the background gradient for the specified color scheme.
    /// - Parameter scheme: The current `ColorScheme` (.light or .dark).
    /// - Returns: A `LinearGradient` for the background.
    func background(for scheme: ColorScheme) -> LinearGradient
}

// MARK: - ChineseNewYearTheme

/// A theme inspired by the colors of the Chinese New Year.
///
/// This struct implements the `SeasonalTheme` protocol, providing a specific set of
/// colors for red, dark red, gold, and background gradients suitable for a festive,
/// celebratory atmosphere.
struct ChineseNewYearTheme: SeasonalTheme {
    /// Provides the primary red color, adjusted for light and dark modes.
    func red(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 180 / 255, green: 28 / 255, blue: 28 / 255)
            : Color(red: 196 / 255, green: 25 / 255, blue: 24 / 255)
    }

    /// Provides a darker red color, adjusted for light and dark modes.
    func darkRed(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 120 / 255, green: 18 / 255, blue: 18 / 255)
            : Color(red: 150 / 255, green: 18 / 255, blue: 18 / 255)
    }

    /// A constant gold color used across the theme.
    let gold = Color(red: 234 / 255, green: 181 / 255, blue: 50 / 255)

    /// Provides a background gradient, adjusted for light and dark modes.
    func background(for scheme: ColorScheme) -> LinearGradient {
        scheme == .dark
            ? LinearGradient(
                colors: [
                    Color(red: 32 / 255, green: 18 / 255, blue: 18 / 255),
                    Color(red: 18 / 255, green: 8 / 255, blue: 8 / 255),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [
                    Color(red: 253 / 255, green: 245 / 255, blue: 236 / 255),
                    Color(red: 240 / 255, green: 230 / 255, blue: 215 / 255),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
}

// MARK: - GoldShimmer View

/// A view that creates a shimmering gold effect.
///
/// This view uses a `TimelineView` to create a continuous animation of a gradient,
/// giving the appearance of a subtle, elegant shimmer. The animation is disabled
/// if the user has enabled "Reduce Motion" or if the app is not in the active scene phase.
struct GoldShimmer: View {
    // MARK: Environment
    
    /// An environment property to check if "Reduce Motion" is enabled in accessibility settings.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    /// An environment property to track the current phase of the scene (e.g., active, inactive).
    @Environment(\.scenePhase) private var scenePhase

    // MARK: Properties
    
    /// The gold color to use for the shimmer effect.
    let gold: Color

    // MARK: Body
    
    var body: some View {
        if reduceMotion || scenePhase != .active {
            Color.clear
        } else {
            TimelineView(.animation(minimumInterval: 0.03, paused: false)) { timeline in
                // Calculate a time value to drive the animation, looping every 8 seconds.
                let t = timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 8)

                LinearGradient(
                    colors: [
                        gold.opacity(0.0),
                        gold.opacity(0.25),
                        gold.opacity(0.0),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .scaleEffect(x: 1.6, y: 1) // Stretch the gradient horizontally
                .rotationEffect(.degrees(12)) // Angle the shimmer
                .offset(x: CGFloat(t / 8) * 420 - 210) // Animate the offset
                .blendMode(.plusLighter) // Use a lighter blend mode for a glowing effect
            }
            .allowsHitTesting(false) // The shimmer should not block user interaction
        }
    }
}
