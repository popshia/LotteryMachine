//
//  ConfettiView.swift
//  LotteryMachine
//
//  Created by Noah on 2025/11/21.
//

import SwiftUI

struct ConfettiView: View {
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

struct ConfettiParticle: View {
    @State private var x: CGFloat
    @State private var y: CGFloat
    @State private var rotation = Angle.degrees(.random(in: 0...360))
    @State private var scale: CGFloat = .random(in: 0.5...1.5)
    @State private var opacity: Double = 1.0

    let particleColor: Color = [
        .red, .green, .blue, .yellow, .pink, .purple, .orange,
    ].randomElement()!
    let isCircle: Bool = Bool.random()
    let upAnimationDuration = Double.random(in: 1...2)

    private let screenSize: CGSize

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        _x = State(initialValue: screenSize.width / 2)
        _y = State(initialValue: screenSize.height)
    }

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
            // Animate upwards and outwards
            withAnimation(Animation.easeOut(duration: upAnimationDuration)) {
                self.y -= .random(
                    in: screenSize.height * 0.4...screenSize.height * 0.7
                )
                self.x += .random(
                    in: -screenSize.width / 2...screenSize.width / 2
                )
                self.rotation += .degrees(.random(in: -180...180))
            }

            // Animate falling down after reaching the peak
            let downAnimationDuration = upAnimationDuration * 1.5
            withAnimation(
                Animation.easeIn(duration: downAnimationDuration).delay(
                    upAnimationDuration
                )
            ) {
                self.y += screenSize.height + 20  // Fall below the screen
                self.rotation += .degrees(.random(in: -180...180))
            }

            // Fade out towards the end of the fall
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
