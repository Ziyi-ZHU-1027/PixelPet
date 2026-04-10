# PixelPet Plan 3: 桌面宠物运行时

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现桌面宠物的完整运行时：透明 NSPanel 浮窗、像素级点击穿透、单击跳跃、双击爱心、眨眼动画、拖拽移动、随机跑动、右键菜单，以及 PetHostManager 统一管理所有活跃宠物。点击"做成桌宠"后宠物立刻出现在桌面。

**Architecture:** 从 DesktopPetKit 直接复制并适配 `PetAnimator`、`PetWindow`（含 `PetHostingView`）、`PetView`。新增 `PetHostManager` 管理所有 `PetWindowController` 实例。`PetWindowController` 适配为从 `PetDefinition` 构建。Plan 3 依赖 Plan 1 和 Plan 2。

**Tech Stack:** SwiftUI, AppKit (NSPanel, NSEvent), Swift 5.9+, macOS 13+

---

## 文件结构（在 Plan 1+2 基础上新增）

```
Sources/PixelPetKit/
├── Model/
│   └── PetAnimator.swift          # 复用 DesktopPetKit，新增双击爱心 + isWandering
├── View/
│   └── PetView.swift              # 复用 DesktopPetKit，适配动态 panel 尺寸
└── Window/
    ├── PetWindow.swift            # 复用 DesktopPetKit（PetWindow + PetHostingView）
    ├── PetWindowController.swift  # 适配：从 PetDefinition 构建，加右键菜单 + 跑动
    └── PetHostManager.swift       # 新增：管理所有活跃宠物窗口
```

---

## Task 1: 复制并适配 PetAnimator

**Files:**
- Create: `Sources/PixelPetKit/Model/PetAnimator.swift`

- [ ] **Step 1: 创建 PetAnimator.swift（适配版）**

`Sources/PixelPetKit/Model/PetAnimator.swift`:
```swift
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
    public let blinkImage: NSImage?          // nil = no blink frame
    public let panelSize: CGFloat            // NSPanel side length

    public private(set) var isJumping = false
    public private(set) var isWandering = false

    private var isBlinking = false
    private var tapCount = 0
    private var timer: Timer?
    private var jumpTick = 0
    private var blinkCountdown = 0
    private var blinkClosedTick = 0

    // Wandering state
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
        // Blink (only if blink frame exists)
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

        // Jump
        if isJumping {
            jumpTick += 1
            jumpOffset = -sin(CGFloat(jumpTick) / 10.0 * .pi) * 50
            if jumpTick >= 10 {
                isJumping = false
                jumpOffset = 0
                jumpTick = 0
            }
        }

        // Resolve image
        if isBlinking, let blink = blinkImage {
            currentImage = blink
        } else {
            currentImage = normalImage
        }

        // Update hearts
        hearts = hearts.compactMap { h in
            var h = h
            h.x += h.vx
            h.y += h.vy
            h.alpha -= 0.006
            h.life -= 1
            return h.life > 0 ? h : nil
        }
    }

    // MARK: - Public triggers

    /// Single tap: jump
    public func triggerJump() {
        guard !isJumping else { return }
        isJumping = true
        jumpTick = 0
    }

    /// Double tap: hearts
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
```

- [ ] **Step 2: 确认编译**

```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: Commit**

```bash
git add Sources/PixelPetKit/Model/PetAnimator.swift
git commit -m "feat: add PetAnimator with blink/jump/hearts/wander support"
```

---

## Task 2: 复制并适配 PetView

**Files:**
- Create: `Sources/PixelPetKit/View/PetView.swift`

- [ ] **Step 1: 创建 PetView.swift**

`Sources/PixelPetKit/View/PetView.swift`:
```swift
import SwiftUI

public struct PetView: View {
    @ObservedObject public var animator: PetAnimator
    let onSingleTap: () -> Void
    let onDoubleTap: () -> Void

    public init(animator: PetAnimator,
                onSingleTap: @escaping () -> Void,
                onDoubleTap: @escaping () -> Void) {
        self.animator = animator
        self.onSingleTap = onSingleTap
        self.onDoubleTap = onDoubleTap
    }

    public var body: some View {
        let size = animator.panelSize
        ZStack {
            Image(nsImage: animator.currentImage)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
                .offset(y: animator.jumpOffset)

            ForEach(animator.hearts) { heart in
                Text("♥")
                    .font(.system(size: heart.size))
                    .foregroundColor(.pink)
                    .opacity(heart.alpha)
                    .position(x: heart.x, y: heart.y)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: size, height: size)
        // Single tap and double tap handled by PetHostingView via NSView
    }
}
```

- [ ] **Step 2: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: Commit**

```bash
git add Sources/PixelPetKit/View/PetView.swift
git commit -m "feat: add PetView for desktop pet rendering"
```

---

## Task 3: 复制并适配 PetWindow + PetHostingView

**Files:**
- Create: `Sources/PixelPetKit/Window/PetWindow.swift`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/zhuziyi/Desktop/PixelPet/Sources/PixelPetKit/Window
```

- [ ] **Step 2: 创建 PetWindow.swift**

`Sources/PixelPetKit/Window/PetWindow.swift`:
```swift
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
        guard isHitOnSprite(point) else { return nil }
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
        // Tap detection
        let now = ProcessInfo.processInfo.systemUptime
        if now - lastTapTime < doubleTapInterval {
            // Double tap
            lastTapTime = 0
            Task { @MainActor in self.onDoubleTap?() }
        } else {
            lastTapTime = now
            // Delay single tap to allow double tap detection
            let tapLocation = mouseDownLocation
            DispatchQueue.main.asyncAfter(deadline: .now() + doubleTapInterval + 0.05) { [weak self] in
                guard let self = self else { return }
                let elapsed = ProcessInfo.processInfo.systemUptime - self.lastTapTime
                if elapsed >= self.doubleTapInterval {
                    Task { @MainActor in self.onSingleTap?() }
                }
            }
        }
        // Forward to SwiftUI for any gesture recognizers
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
        if event.type == .leftMouseDown || event.type == .rightMouseDown {
            let pt = contentView?.convert(event.locationInWindow, from: nil) ?? event.locationInWindow
            if contentView?.hitTest(pt) == nil { return }
        }
        super.sendEvent(event)
    }
}
```

- [ ] **Step 3: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 4: Commit**

```bash
git add Sources/PixelPetKit/Window/PetWindow.swift
git commit -m "feat: add PetWindow and PetHostingView with single/double tap"
```

---

## Task 4: PetWindowController

**Files:**
- Create: `Sources/PixelPetKit/Window/PetWindowController.swift`

- [ ] **Step 1: 创建 PetWindowController.swift**

`Sources/PixelPetKit/Window/PetWindowController.swift`:
```swift
import AppKit
import SwiftUI

@MainActor
public final class PetWindowController {
    public let window: PetWindow
    public let hostingView: PetHostingView
    public let animator: PetAnimator
    public var pet: PetDefinition

    // Wandering state
    private var wanderTarget: CGPoint? = nil
    private var wanderPauseTicks = 0
    private var wanderTimer: Timer?

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
            onSingleTap: {},   // wired below
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

        // Wire interactions
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

        let editItem = NSMenuItem(title: "打开编辑器", action: #selector(NSApplication.activate(_:)), keyEquivalent: "")
        editItem.target = NSApp
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
        guard wanderTimer == nil else { return }
        wanderTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.wanderTick() }
        }
        RunLoop.main.add(wanderTimer!, forMode: .common)
    }

    private func stopWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderTarget = nil
        wanderPauseTicks = 0
    }

    private func pauseWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
    }

    private func resumeWandering() {
        if pet.isWandering { startWandering() }
    }

    private func wanderTick() {
        // Save position every tick
        let origin = window.frame.origin
        pet.lastPositionX = origin.x
        pet.lastPositionY = origin.y
        // Don't write to disk every tick — done on hide/delete/quit

        if wanderPauseTicks > 0 {
            wanderPauseTicks -= 1
            return
        }

        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelSize = window.frame.size

        if wanderTarget == nil {
            // Pick a random target within screen bounds
            let margin: CGFloat = 20
            let maxX = screenFrame.maxX - panelSize.width - margin
            let maxY = screenFrame.maxY - panelSize.height - margin
            let minX = screenFrame.minX + margin
            let minY = screenFrame.minY + margin
            guard maxX > minX, maxY > minY else { return }
            wanderTarget = CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )
        }

        guard let target = wanderTarget else { return }
        let current = window.frame.origin
        let dx = target.x - current.x
        let dy = target.y - current.y
        let dist = sqrt(dx * dx + dy * dy)

        let speed: CGFloat = CGFloat.random(in: 2...4)
        if dist < speed {
            window.setFrameOrigin(target)
            wanderTarget = nil
            // Pause 10–30 ticks (1–3 seconds at 0.1s interval)
            wanderPauseTicks = Int.random(in: 10...30)
            animator.triggerJump()
        } else {
            let nx = current.x + (dx / dist) * speed
            let ny = current.y + (dy / dist) * speed
            window.setFrameOrigin(NSPoint(x: nx, y: ny))
            // Trigger hop every ~15 ticks while moving
            if Int.random(in: 0...14) == 0 { animator.triggerJump() }
        }
    }

    // MARK: - Save position on quit

    public func savePosition() {
        let origin = window.frame.origin
        pet.lastPositionX = origin.x
        pet.lastPositionY = origin.y
        try? PetStore.shared.update(pet)
    }

    // MARK: - Static helpers

    public static func displaySize(for canvasSize: Int) -> CGFloat {
        switch canvasSize {
        case 15: return 120
        case 25: return 200
        default: return 256   // 32
        }
    }

    public static func panelSize(for canvasSize: Int) -> CGFloat {
        switch canvasSize {
        case 15: return 200
        case 25: return 280
        default: return 320   // 32
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
    public static let petDidHide   = Notification.Name("PixelPet.petDidHide")
    public static let petDidDelete = Notification.Name("PixelPet.petDidDelete")
}
```

- [ ] **Step 2: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: Commit**

```bash
git add Sources/PixelPetKit/Window/PetWindowController.swift
git commit -m "feat: add PetWindowController with wander/menu/drag"
```

---

## Task 5: PetHostManager

**Files:**
- Create: `Sources/PixelPetKit/Window/PetHostManager.swift`

- [ ] **Step 1: 创建 PetHostManager.swift**

`Sources/PixelPetKit/Window/PetHostManager.swift`:
```swift
import AppKit

/// Manages all active desktop pet windows. Single process, multiple NSPanels.
@MainActor
public final class PetHostManager {

    public static let shared = PetHostManager()
    private var controllers: [UUID: PetWindowController] = [:]

    private init() {
        // Listen for hide/delete notifications to clean up controllers
        NotificationCenter.default.addObserver(
            forName: .petDidHide, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                if let id = note.object as? UUID {
                    self?.controllers.removeValue(forKey: id)
                }
            }
        }
        NotificationCenter.default.addObserver(
            forName: .petDidDelete, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                if let id = note.object as? UUID {
                    self?.controllers.removeValue(forKey: id)
                }
            }
        }
    }

    /// Spawn a pet window. If already spawned, brings it to front.
    public func spawn(_ pet: PetDefinition) {
        guard controllers[pet.id] == nil else {
            controllers[pet.id]?.window.orderFrontRegardless()
            return
        }

        let (normal, blink) = PetStore.shared.loadImages(id: pet.id)
        guard let normal = normal else {
            print("PetHostManager: missing normal.png for \(pet.name)")
            return
        }

        // Restore last position or center on screen
        let position: NSPoint
        if let lx = pet.lastPositionX, let ly = pet.lastPositionY {
            position = NSPoint(x: lx, y: ly)
        } else {
            let screen = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
            let panelSize = PetWindowController.panelSize(for: pet.canvasSize)
            position = NSPoint(
                x: screen.midX - panelSize / 2,
                y: screen.midY - panelSize / 2
            )
        }

        let controller = PetWindowController(
            pet: pet,
            normal: normal,
            blink: blink,
            position: position
        )
        controllers[pet.id] = controller

        // "Come alive" jump
        controller.animator.triggerJump()
    }

    /// Restore all visible pets on app launch.
    public func restoreAll() {
        let pets = (try? PetStore.shared.loadAll()) ?? []
        for pet in pets where pet.isVisible {
            spawn(pet)
        }
    }

    /// Save all pet positions before quit.
    public func saveAllPositions() {
        for controller in controllers.values {
            controller.savePosition()
        }
    }
}
```

- [ ] **Step 2: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: Commit**

```bash
git add Sources/PixelPetKit/Window/PetHostManager.swift
git commit -m "feat: add PetHostManager for multi-pet window management"
```

---

## Task 6: 接入 EditorView + App 启动恢复

**Files:**
- Modify: `Sources/PixelPetKit/View/EditorView.swift` — `spawnPet()` 接入 PetHostManager
- Modify: `Sources/PixelPetApp/AppDelegate.swift` — 启动时恢复宠物，退出时保存位置

- [ ] **Step 1: 修改 EditorView.spawnPet()**

在 `Sources/PixelPetKit/View/EditorView.swift` 中，找到 `spawnPet()` 方法，将注释行替换为实际调用：

将：
```swift
            // PetHostManager.shared.spawn(pet) — wired in Plan 3
```

替换为：
```swift
            PetHostManager.shared.spawn(pet)
```

- [ ] **Step 2: 修改 AppDelegate**

`Sources/PixelPetApp/AppDelegate.swift`:
```swift
import AppKit
import PixelPetKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Restore all visible pets from last session
        Task { @MainActor in
            PetHostManager.shared.restoreAll()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in
            PetHostManager.shared.saveAllPositions()
        }
    }
}
```

- [ ] **Step 3: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 4: 端到端测试**

```bash
swift run PixelPetApp
```

手动验证步骤：
1. 编辑器窗口打开
2. 在画板上画几个像素（选颜色，点格子）
3. 点击"▶ 做成桌宠"，输入名字，确认
4. 桌面上出现宠物，执行跳跃动画
5. 单击宠物 → 跳跃
6. 双击宠物 → 爱心粒子飘出
7. 拖拽宠物 → 跟随鼠标
8. 右键宠物 → 菜单出现，可开关随机跑动
9. 开启随机跑动 → 宠物开始在屏幕上游走
10. 关闭编辑器窗口 → App 退出，位置保存
11. 重新启动 → 宠物恢复到上次位置

- [ ] **Step 5: Commit**

```bash
git add Sources/PixelPetKit/View/EditorView.swift Sources/PixelPetApp/AppDelegate.swift
git commit -m "feat: wire PetHostManager into editor and app lifecycle"
```

---

## Task 7: build.sh 打包脚本

**Files:**
- Create: `build.sh`

- [ ] **Step 1: 创建 build.sh**

`build.sh`:
```bash
#!/bin/bash
set -e

echo "Building PixelPet..."
swift build -c release

APP_NAME="PixelPet"
APP_DIR="${APP_NAME}.app"
EXECUTABLE=".build/release/PixelPetApp"

# Clean previous build
rm -rf "$APP_DIR"

# Create bundle structure
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$APP_NAME"

# Write Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.pixelpet.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF

# Code sign (ad-hoc)
codesign --force --deep --sign - "$APP_DIR"

echo "Done! Run: open $APP_DIR"
```

- [ ] **Step 2: 赋予执行权限并测试**

```bash
chmod +x /Users/zhuziyi/Desktop/PixelPet/build.sh
cd /Users/zhuziyi/Desktop/PixelPet && bash build.sh
```

Expected: `Done! Run: open PixelPet.app`

- [ ] **Step 3: 运行打包后的 App**

```bash
open /Users/zhuziyi/Desktop/PixelPet/PixelPet.app
```

Expected: App 正常启动，编辑器窗口出现

- [ ] **Step 4: Commit**

```bash
git add build.sh
git commit -m "feat: add build.sh for app bundle packaging"
```

---

## 完成检查

Plan 3 全部完成后：

```bash
swift test   # 全部通过
swift build  # Build complete!
bash build.sh && open PixelPet.app
```

完整功能验证：
- ✅ 画像素画 → 做成桌宠 → 立刻出现在桌面
- ✅ 单击跳跃，双击爱心
- ✅ 有眨眼帧则自动眨眼
- ✅ 拖拽移动
- ✅ 右键菜单（跑动开关/隐藏/删除）
- ✅ 随机跑动
- ✅ 重启后恢复宠物位置
- ✅ 多只宠物同时在桌面，互相独立
