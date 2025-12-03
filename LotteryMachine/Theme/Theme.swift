//
//  Theme.swift
//  LotteryMachine
//
//  Created by Noah on 2025/12/3.
//
import SwiftUI

protocol SeasonalTheme {
    func red(for scheme: ColorScheme) -> Color
    func darkRed(for scheme: ColorScheme) -> Color
    var gold: Color { get }
    func background(for scheme: ColorScheme) -> LinearGradient
}

struct ChineseNewYearTheme: SeasonalTheme {
    func red(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 180 / 255, green: 28 / 255, blue: 28 / 255)
            : Color(red: 196 / 255, green: 25 / 255, blue: 24 / 255)
    }

    func darkRed(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 120 / 255, green: 18 / 255, blue: 18 / 255)
            : Color(red: 150 / 255, green: 18 / 255, blue: 18 / 255)
    }

    let gold = Color(red: 234 / 255, green: 181 / 255, blue: 50 / 255)

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

struct GoldShimmer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    let gold: Color

    var body: some View {
        if reduceMotion || scenePhase != .active {
            Color.clear
        } else {
            TimelineView(.animation(minimumInterval: 0.03, paused: false)) { timeline in
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
                .scaleEffect(x: 1.6, y: 1)
                .rotationEffect(.degrees(12))
                .offset(x: CGFloat(t / 8) * 420 - 210)
                .blendMode(.plusLighter)
            }
            .allowsHitTesting(false)
        }
    }
}
