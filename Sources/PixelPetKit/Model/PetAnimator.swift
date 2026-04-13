import AppKit

public struct HeartParticle: Identifiable {
    public let id = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var vx: CGFloat
    public var vy: CGFloat
    public var alpha: CGFloat
    public var size: CGFloat
    public var life: Int
}

@MainActor
public final class PetAnimator: ObservableObject {
    @Published public var jumpOffset: CGFloat = 0
    @Published public var hearts: [HeartParticle] = []
    @Published public var currentImage: NSImage

    public let normalImage: NSImage
    public let blinkImage: NSImage?
    public let panelSize: CGFloat

    public private(set) var isJumping = false
    public private(set) var isWandering = false

    private var isBlinking = false
    private var tapCount = 0
    private var timer: Timer?
    private var jumpTick = 0
    private var blinkCountdown = 0
    private var blinkClosedTick = 0

    public var wanderTarget: CGPoint? = nil
    public var wanderPauseTicks = 0

    public init(normalImage: NSImage, blinkImage: NSImage?, panelSize: CGFloat) {
        self.normalImage = normalImage
        self.blinkImage = blinkImage
        self.panelSize = panelSize
        self.currentImage = normalImage
        self.blinkCountdown = Self.randomBlinkInterval()
        startLoop()
    }

    private static func randomBlinkInterval() -> Int { Int.random(in: 120...300) }

    private func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.onTick() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func onTick() {
        if blinkImage != nil {
            if !isBlinking {
                blinkCountdown -= 1
                if blinkCountdown <= 0 {
                    isBlinking = true
                    blinkClosedTick = 0
                }
            } else {
                blinkClosedTick += 1
                if blinkClosedTick >= 3 {
                    isBlinking = false
                    blinkCountdown = Self.randomBlinkInterval()
                }
            }
        }

        if isJumping {
            jumpTick += 1
            jumpOffset = -sin(CGFloat(jumpTick) / 10.0 * .pi) * 50
            if jumpTick >= 10 {
                isJumping = false
                jumpOffset = 0
                jumpTick = 0
            }
        }

        if isBlinking, let blink = blinkImage {
            currentImage = blink
        } else {
            currentImage = normalImage
        }

        hearts = hearts.compactMap { h in
            var h = h
            h.x += h.vx
            h.y += h.vy
            h.alpha -= 0.006
            h.life -= 1
            return h.life > 0 ? h : nil
        }
    }

    public func triggerJump() {
        guard !isJumping else { return }
        isJumping = true
        jumpTick = 0
    }

    public func triggerHearts() {
        for _ in 0..<5 {
            hearts.append(HeartParticle(
                x: CGFloat.random(in: panelSize * 0.25...panelSize * 0.75),
                y: CGFloat.random(in: panelSize * 0.2...panelSize * 0.6),
                vx: CGFloat.random(in: -1.5...1.5),
                vy: -CGFloat.random(in: 1.5...3.0),
                alpha: 1.0,
                size: CGFloat.random(in: 16...28),
                life: Int.random(in: 150...200)
            ))
        }
    }

    public func setWandering(_ on: Bool) {
        isWandering = on
        if !on { wanderTarget = nil }
    }
}
