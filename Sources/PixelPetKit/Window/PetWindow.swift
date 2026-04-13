import AppKit
import SwiftUI

// MARK: - PetHostingView

public final class PetHostingView: NSHostingView<AnyView> {
    public var alphaMap: [[Bool]] = []
    public var spriteSize: Int = 32
    public var displaySize: CGFloat = 256
    public var onSingleTap: (() -> Void)?
    public var onDoubleTap: (() -> Void)?
    public var onDragStateChanged: ((Bool) -> Void)?
    public var onRightClick: ((NSEvent) -> Void)?

    private var mouseDownLocation: NSPoint = .zero
    private var isDragging = false
    private var lastTapTime: TimeInterval = 0
    private let doubleTapInterval: TimeInterval = 0.3

    public func isHitOnSprite(_ point: NSPoint) -> Bool {
        guard !alphaMap.isEmpty else { return false }
        let scale = CGFloat(spriteSize) / displaySize
        let px = Int(point.x * scale)
        let py = spriteSize - 1 - Int(point.y * scale)
        guard px >= 0, px < spriteSize, py >= 0, py < spriteSize else { return false }
        return alphaMap[px][py]
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        // Accept clicks anywhere in the panel bounding box.
        // Pixel-perfect hit testing is too strict for user-drawn sprites
        // (most of the canvas may be transparent).
        return super.hitTest(point)
    }

    public override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
        isDragging = false
    }

    public override func mouseDragged(with event: NSEvent) {
        let loc = event.locationInWindow
        let dx = abs(loc.x - mouseDownLocation.x)
        let dy = abs(loc.y - mouseDownLocation.y)
        if dx > 2 || dy > 2 {
            if !isDragging {
                isDragging = true
                onDragStateChanged?(true)
                window?.orderFrontRegardless()
            }
            window?.performDrag(with: event)
        }
    }

    public override func mouseUp(with event: NSEvent) {
        if isDragging {
            isDragging = false
            onDragStateChanged?(false)
            return
        }
        let now = ProcessInfo.processInfo.systemUptime
        if now - lastTapTime < doubleTapInterval {
            lastTapTime = 0
            Task { @MainActor in self.onDoubleTap?() }
        } else {
            lastTapTime = now
            DispatchQueue.main.asyncAfter(deadline: .now() + doubleTapInterval + 0.05) { [weak self] in
                guard let self = self else { return }
                let elapsed = ProcessInfo.processInfo.systemUptime - self.lastTapTime
                if elapsed >= self.doubleTapInterval {
                    Task { @MainActor in self.onSingleTap?() }
                }
            }
        }
        guard let wn = window?.windowNumber, wn != 0 else { return }
        guard let down = NSEvent.mouseEvent(
            with: .leftMouseDown, location: mouseDownLocation,
            modifierFlags: [], timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: wn, context: nil, eventNumber: 0, clickCount: 1, pressure: 1
        ) else { return }
        super.mouseDown(with: down)
        super.mouseUp(with: event)
    }

    public override func rightMouseDown(with event: NSEvent) {
        onRightClick?(event)
    }
}

// MARK: - PetWindow

public final class PetWindow: NSPanel {
    public init(size: CGFloat) {
        super.init(
            contentRect: NSRect(origin: .zero, size: CGSize(width: size, height: size)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        isMovableByWindowBackground = false
        hasShadow = false
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
        ignoresMouseEvents = false
    }

    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { false }

    public override func sendEvent(_ event: NSEvent) {
        super.sendEvent(event)
    }
}
