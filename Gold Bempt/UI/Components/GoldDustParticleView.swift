import SwiftUI

private struct Particle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var size: Double
    var opacity: Double
    var speed: Double
}

struct GoldDustParticleView: View {
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    let count: Int

    init(count: Int = 30) {
        self.count = count
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(GoldRushTheme.Colors.richGold)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(x: particle.x * geo.size.width,
                                  y: particle.y * geo.size.height)
                }
            }
            .onAppear { startAnimation(in: geo.size) }
            .onDisappear { timer?.invalidate() }
        }
        .allowsHitTesting(false)
    }

    private func startAnimation(in size: CGSize) {
        particles = (0..<count).map { _ in randomParticle() }
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                for i in particles.indices {
                    particles[i].y -= particles[i].speed
                    particles[i].opacity *= 0.995
                    if particles[i].y < 0 || particles[i].opacity < 0.01 {
                        particles[i] = randomParticle()
                    }
                }
            }
        }
    }

    private func randomParticle() -> Particle {
        Particle(
            x: Double.random(in: 0...1),
            y: Double.random(in: 0.5...1.2),
            size: Double.random(in: 2...5),
            opacity: Double.random(in: 0.4...0.9),
            speed: Double.random(in: 0.002...0.008)
        )
    }
}
