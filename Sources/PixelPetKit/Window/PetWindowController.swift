import AppKit
import SwiftUI

@MainActor
public final class PetWindowController {
    public let window: PetWindow
    public let hostingView: PetHostingView
    public let animator: PetAnimator
    public var pet: PetDefinition

    private var wanderTarget: CGPoint? = nil
    private var wanderTimer: Timer?
    // Hop-driven movement: each jump moves the pet one step toward target
    private let hopStepSize: CGFloat = 40   // px moved per jump
    private var isWaitingToHop = false      // waiting for pause before next hop

    public var windowOrigin: NSPoint {
        window.frame.origin
    }

    public init(pet: PetDefinition, normal: NSImage, blink: NSImage?, position: NSPoint) {
        self.pet = pet

        let displaySize = Self.displaySize(for: pet.canvasSize)
        let panelSize   = Self.panelSize(for: pet.canvasSize)

        animator = PetAnimator(
            normalImage: normal,
            blinkImage: blink,
            panelSize: panelSize
        )
        window = PetWindow(size: panelSize)

        let petView = AnyView(PetView(
            animator: animator,
            onSingleTap: {},
            onDoubleTap: {}
        ))
        hostingView = PetHostingView(rootView: petView)
        hostingView.frame = NSRect(origin: .zero, size: CGSize(width: panelSize, height: panelSize))
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear
        hostingView.spriteSize = pet.canvasSize
        hostingView.displaySize = displaySize
        hostingView.alphaMap = Self.buildAlphaMap(from: normal, spriteSize: pet.canvasSize)

        window.contentView = hostingView
        window.setFrameOrigin(position)

        hostingView.onSingleTap = { [weak self] in self?.animator.triggerJump() }
        hostingView.onDoubleTap = { [weak self] in self?.animator.triggerHearts() }
        hostingView.onDragStateChanged = { [weak self] dragging in
            if dragging { self?.pauseWandering() } else { self?.resumeWandering() }
        }
        hostingView.onRightClick = { [weak self] event in self?.showContextMenu(event: event) }

        if pet.isWandering { startWandering() }
        window.orderFrontRegardless()
    }

    // MARK: - Context menu

    private func showContextMenu(event: NSEvent) {
        NSApp.activate(ignoringOtherApps: true)
        let menu = NSMenu()

        let editItem = NSMenuItem(title: "打开编辑器", action: #selector(openEditor), keyEquivalent: "")
        editItem.target = self
        menu.addItem(editItem)

        let wanderItem = NSMenuItem(
            title: "随机跑动",
            action: #selector(toggleWandering),
            keyEquivalent: ""
        )
        wanderItem.target = self
        wanderItem.state = pet.isWandering ? .on : .off
        menu.addItem(wanderItem)

        menu.addItem(.separator())

        let hideItem = NSMenuItem(title: "隐藏", action: #selector(hidePet), keyEquivalent: "")
        hideItem.target = self
        menu.addItem(hideItem)

        menu.addItem(.separator())

        let deleteItem = NSMenuItem(title: "删除宠物", action: #selector(deletePet), keyEquivalent: "")
        deleteItem.target = self
        menu.addItem(deleteItem)

        NSMenu.popUpContextMenu(menu, with: event, for: hostingView)
    }

    @objc private func openEditor() {
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.post(name: .petDidRequestEditor, object: pet.id)
    }

    @objc private func toggleWandering() {
        pet.isWandering.toggle()
        try? PetStore.shared.update(pet)
        if pet.isWandering { startWandering() } else { stopWandering() }
    }

    @objc private func hidePet() {
        pet.isVisible = false
        try? PetStore.shared.update(pet)
        window.orderOut(nil)
        NotificationCenter.default.post(name: .petDidHide, object: pet.id)
    }

    @objc private func deletePet() {
        let alert = NSAlert()
        alert.messageText = "删除宠物"
        alert.informativeText = "确定要删除「\(pet.name)」吗？此操作不可撤销。"
        alert.addButton(withTitle: "删除")
        alert.addButton(withTitle: "取消")
        alert.alertStyle = .warning
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        try? PetStore.shared.delete(id: pet.id)
        window.orderOut(nil)
        NotificationCenter.default.post(name: .petDidDelete, object: pet.id)
    }

    // MARK: - Wandering

    private func startWandering() {
        // Wire the jump-landed callback so movement is driven by hops
        animator.onJumpLanded = { [weak self] in
            self?.onHopLanded()
        }
        // Kick off the first hop
        scheduleNextHop(delay: 0.3)
    }

    private func stopWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderTarget = nil
        isWaitingToHop = false
        animator.onJumpLanded = nil
    }

    private func pauseWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        isWaitingToHop = false
    }

    private func resumeWandering() {
        if pet.isWandering {
            startWandering()
        }
    }

    /// Called by PetAnimator when a jump animation finishes landing.
    private func onHopLanded() {
        guard pet.isWandering else { return }

        // Save current position
        let origin = window.frame.origin
        pet.lastPositionX = origin.x
        pet.lastPositionY = origin.y

        // Pick a new target if needed
        if wanderTarget == nil {
            wanderTarget = randomTarget()
        }

        guard let target = wanderTarget else { return }
        let current = window.frame.origin
        let dx = target.x - current.x
        let dy = target.y - current.y
        let dist = sqrt(dx * dx + dy * dy)

        if dist < hopStepSize {
            // Close enough — snap to target, pick next one after a pause
            window.setFrameOrigin(target)
            wanderTarget = nil
            scheduleNextHop(delay: Double.random(in: 0.6...1.5))
        } else {
            // Move one hop-step toward target, then wait before next hop
            let nx = current.x + (dx / dist) * hopStepSize
            let ny = current.y + (dy / dist) * hopStepSize
            window.setFrameOrigin(NSPoint(x: nx, y: ny))
            scheduleNextHop(delay: Double.random(in: 0.05...0.15))
        }
    }

    /// Schedule the next jump after a delay (gives a natural pause between hops).
    private func scheduleNextHop(delay: Double) {
        guard pet.isWandering, !isWaitingToHop else { return }
        isWaitingToHop = true
        wanderTimer?.invalidate()
        wanderTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.pet.isWandering else { return }
                self.isWaitingToHop = false
                self.animator.triggerJump()
                // onHopLanded will be called by PetAnimator when jump finishes
            }
        }
        RunLoop.main.add(wanderTimer!, forMode: .common)
    }

    /// Pick a random on-screen target within screen bounds.
    private func randomTarget() -> CGPoint? {
        guard let screen = NSScreen.main else { return nil }
        let f = screen.visibleFrame
        let p = window.frame.size
        let margin: CGFloat = 20
        let maxX = f.maxX - p.width - margin
        let maxY = f.maxY - p.height - margin
        let minX = f.minX + margin
        let minY = f.minY + margin
        guard maxX > minX, maxY > minY else { return nil }
        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }

    public func savePosition() {
        let origin = window.frame.origin
        pet.lastPositionX = origin.x
        pet.lastPositionY = origin.y
        try? PetStore.shared.update(pet)
    }

    public static func displaySize(for canvasSize: Int) -> CGFloat {
        switch canvasSize {
        case 15: return 120
        case 25: return 200
        default: return 256
        }
    }

    public static func panelSize(for canvasSize: Int) -> CGFloat {
        switch canvasSize {
        case 15: return 200
        case 25: return 280
        default: return 320
        }
    }

    private static func buildAlphaMap(from image: NSImage, spriteSize: Int) -> [[Bool]] {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return [] }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: spriteSize * spriteSize * 4)
        guard let context = CGContext(
            data: &pixelData,
            width: spriteSize, height: spriteSize,
            bitsPerComponent: 8, bytesPerRow: spriteSize * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: spriteSize, height: spriteSize))
        var map = [[Bool]](repeating: [Bool](repeating: false, count: spriteSize), count: spriteSize)
        for y in 0..<spriteSize {
            for x in 0..<spriteSize {
                let idx = (y * spriteSize + x) * 4
                map[x][y] = pixelData[idx + 3] > 10
            }
        }
        return map
    }
}

// MARK: - Notification names

extension Notification.Name {
    public static let petDidHide          = Notification.Name("PixelPet.petDidHide")
    public static let petDidDelete        = Notification.Name("PixelPet.petDidDelete")
    public static let petDidRequestEditor = Notification.Name("PixelPet.petDidRequestEditor")
}
