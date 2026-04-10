# PixelPet Plan 2: 画板编辑器 UI

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现完整的像素画板编辑器窗口，包含工具栏、像素格子画板（透明棋盘格底）、颜色面板、帧管理、宠物列表，以及"做成桌宠"按钮触发命名弹窗。

**Architecture:** SwiftUI 全量实现编辑器 UI。`EditorViewModel` 作为 `@StateObject` 持有 `PixelCanvas`、当前工具、当前颜色、帧状态。`PixelPetApp` 用 SwiftUI `@main` App，打开一个标准 `NSWindow` 承载编辑器。Plan 2 依赖 Plan 1 的 `PixelCanvas`、`PetDefinition`、`PetStore`。

**Tech Stack:** SwiftUI, AppKit (NSWindow), Swift 5.9+, macOS 13+

---

## 文件结构（在 Plan 1 基础上新增/修改）

```
Sources/
├── PixelPetKit/
│   ├── Model/
│   │   └── EditorViewModel.swift      # 编辑器状态（画布、工具、颜色、帧）
│   └── View/
│       ├── EditorView.swift           # 主编辑器三栏布局
│       ├── PixelGridView.swift        # 像素格子画板（透明棋盘格底）
│       ├── ToolbarPanelView.swift     # 左侧工具栏（画笔/橡皮/填充/取色/撤销/重做）
│       ├── RightPanelView.swift       # 右侧面板（尺寸/颜色/调色盘/宠物列表）
│       └── NamePetSheet.swift         # "做成桌宠"命名弹窗
└── PixelPetApp/
    ├── PixelPetApp.swift              # @main SwiftUI App（替换 main.swift）
    └── AppDelegate.swift              # NSApplicationDelegate（窗口配置）
```

---

## Task 1: 替换 App 入口为 SwiftUI @main

**Files:**
- Delete: `Sources/PixelPetApp/main.swift`
- Create: `Sources/PixelPetApp/PixelPetApp.swift`
- Create: `Sources/PixelPetApp/AppDelegate.swift`
- Modify: `Package.swift`

- [ ] **Step 1: 删除旧 main.swift，更新 Package.swift**

```bash
rm /Users/zhuziyi/Desktop/PixelPet/Sources/PixelPetApp/main.swift
```

`Package.swift` — 更新 PixelPetApp target，加入 SwiftUI 和 resources：
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PixelPet",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "PixelPetKit",
            path: "Sources/PixelPetKit"
        ),
        .executableTarget(
            name: "PixelPetApp",
            dependencies: ["PixelPetKit"],
            path: "Sources/PixelPetApp"
        ),
        .testTarget(
            name: "PixelPetKitTests",
            dependencies: ["PixelPetKit"],
            path: "Tests/PixelPetKitTests"
        ),
    ]
)
```

- [ ] **Step 2: 创建 SwiftUI App 入口**

`Sources/PixelPetApp/PixelPetApp.swift`:
```swift
import SwiftUI
import PixelPetKit

@main
struct PixelPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("PixelPet") {
            EditorView()
                .frame(minWidth: 800, minHeight: 560)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
```

- [ ] **Step 3: 创建 AppDelegate**

`Sources/PixelPetApp/AppDelegate.swift`:
```swift
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
```

- [ ] **Step 4: 创建 View 目录和空占位**

```bash
mkdir -p /Users/zhuziyi/Desktop/PixelPet/Sources/PixelPetKit/View
```

`Sources/PixelPetKit/View/EditorView.swift`:
```swift
import SwiftUI

public struct EditorView: View {
    public init() {}
    public var body: some View {
        Text("PixelPet Editor")
    }
}
```

- [ ] **Step 5: 确认编译通过**

```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources/PixelPetApp/ Sources/PixelPetKit/View/
git commit -m "feat: switch to SwiftUI @main app entry"
```

---

## Task 2: EditorViewModel

**Files:**
- Create: `Sources/PixelPetKit/Model/EditorViewModel.swift`

- [ ] **Step 1: 实现 EditorViewModel**

`Sources/PixelPetKit/Model/EditorViewModel.swift`:
```swift
import SwiftUI
import Combine

public enum DrawTool {
    case pen, eraser, fill, eyedropper
}

@MainActor
public final class EditorViewModel: ObservableObject {

    // MARK: - Canvas state
    @Published public var canvas: PixelCanvas
    @Published public var blinkCanvas: PixelCanvas?
    @Published public var activeFrame: FrameTab = .normal

    // MARK: - Tool state
    @Published public var currentTool: DrawTool = .pen
    @Published public var currentHex: String = "#E63946"

    // MARK: - UI state
    @Published public var showNameSheet: Bool = false
    @Published public var pendingSize: Int? = nil      // non-nil = size change confirmation pending

    // MARK: - Undo/Redo
    private var undoStack: [PixelCanvas] = []
    private var redoStack: [PixelCanvas] = []
    private let maxUndoDepth = 50

    // MARK: - Init
    public init(size: Int = 32) {
        self.canvas = PixelCanvas(size: size)
    }

    // MARK: - Frame management

    public enum FrameTab { case normal, blink }

    public func addBlinkFrame() {
        guard blinkCanvas == nil else { return }
        blinkCanvas = PixelCanvas(size: canvas.size)
        activeFrame = .blink
    }

    public var activeCanvas: PixelCanvas {
        get { activeFrame == .blink ? (blinkCanvas ?? canvas) : canvas }
    }

    // MARK: - Drawing

    public func applyTool(x: Int, y: Int) {
        switch currentTool {
        case .pen:
            pushUndo()
            if activeFrame == .blink {
                blinkCanvas?.setPixel(x: x, y: y, hex: currentHex)
            } else {
                canvas.setPixel(x: x, y: y, hex: currentHex)
            }
        case .eraser:
            pushUndo()
            if activeFrame == .blink {
                blinkCanvas?.setPixel(x: x, y: y, hex: nil)
            } else {
                canvas.setPixel(x: x, y: y, hex: nil)
            }
        case .fill:
            pushUndo()
            if activeFrame == .blink {
                blinkCanvas?.fill(x: x, y: y, hex: currentHex)
            } else {
                canvas.fill(x: x, y: y, hex: currentHex)
            }
        case .eyedropper:
            if let picked = activeCanvas.pixel(x: x, y: y) {
                currentHex = picked
            }
            currentTool = .pen
        }
    }

    // MARK: - Canvas size

    public func changeSize(_ newSize: Int) {
        canvas = PixelCanvas(size: newSize)
        blinkCanvas = blinkCanvas != nil ? PixelCanvas(size: newSize) : nil
        undoStack.removeAll()
        redoStack.removeAll()
    }

    // MARK: - Undo / Redo

    public func undo() {
        guard let prev = undoStack.popLast() else { return }
        redoStack.append(canvas)
        canvas = prev
    }

    public func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(canvas)
        canvas = next
    }

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }

    private func pushUndo() {
        undoStack.append(canvas)
        if undoStack.count > maxUndoDepth { undoStack.removeFirst() }
        redoStack.removeAll()
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
git add Sources/PixelPetKit/Model/EditorViewModel.swift
git commit -m "feat: add EditorViewModel with tool/undo/frame management"
```

---

## Task 3: PixelGridView（像素画板）

**Files:**
- Create: `Sources/PixelPetKit/View/PixelGridView.swift`

- [ ] **Step 1: 实现 PixelGridView**

`Sources/PixelPetKit/View/PixelGridView.swift`:
```swift
import SwiftUI

/// The interactive pixel grid. Transparent cells show a checkerboard pattern.
public struct PixelGridView: View {

    @ObservedObject var vm: EditorViewModel

    // Cell size in points based on canvas size
    private var cellSize: CGFloat {
        switch vm.canvas.size {
        case 15: return 26
        case 25: return 21
        default: return 17  // 32
        }
    }

    public init(vm: EditorViewModel) { self.vm = vm }

    public var body: some View {
        let size = vm.activeCanvas.size
        let cs = cellSize

        Canvas { context, _ in
            for y in 0..<size {
                for x in 0..<size {
                    let rect = CGRect(
                        x: CGFloat(x) * cs,
                        y: CGFloat(y) * cs,
                        width: cs,
                        height: cs
                    )
                    if let hex = vm.activeCanvas.pixel(x: x, y: y),
                       let color = Color(hex: hex) {
                        context.fill(Path(rect), with: .color(color))
                    } else {
                        // Checkerboard for transparent
                        let isEven = (x + y) % 2 == 0
                        let checkColor: Color = isEven ? Color(white: 0.85) : Color(white: 0.95)
                        context.fill(Path(rect), with: .color(checkColor))
                    }
                    // Grid line
                    context.stroke(
                        Path(rect),
                        with: .color(Color.orange.opacity(0.12)),
                        lineWidth: 0.5
                    )
                }
            }
        }
        .frame(
            width: CGFloat(vm.activeCanvas.size) * cs,
            height: CGFloat(vm.activeCanvas.size) * cs
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = Int(value.location.x / cs)
                    let y = Int(value.location.y / cs)
                    guard x >= 0, y >= 0,
                          x < vm.activeCanvas.size,
                          y < vm.activeCanvas.size else { return }
                    vm.applyTool(x: x, y: y)
                }
        )
        .simultaneousGesture(
            // Right-click to erase
            TapGesture(count: 1)
                .onEnded { }  // placeholder; actual right-click via NSView overlay
        )
        .overlay(RightClickEraserOverlay(vm: vm, cellSize: cs))
        .cursor(.crosshair)
    }
}

// MARK: - Right-click erase via NSViewRepresentable

private struct RightClickEraserOverlay: NSViewRepresentable {
    let vm: EditorViewModel
    let cellSize: CGFloat

    func makeNSView(context: Context) -> RightClickView {
        RightClickView(vm: vm, cellSize: cellSize)
    }
    func updateNSView(_ nsView: RightClickView, context: Context) {
        nsView.cellSize = cellSize
    }
}

private final class RightClickView: NSView {
    let vm: EditorViewModel
    var cellSize: CGFloat

    init(vm: EditorViewModel, cellSize: CGFloat) {
        self.vm = vm
        self.cellSize = cellSize
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func rightMouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        let x = Int(loc.x / cellSize)
        let y = Int(loc.y / cellSize)
        let size = vm.activeCanvas.size
        guard x >= 0, y >= 0, x < size, y < size else { return }
        Task { @MainActor in
            let prev = vm.currentTool
            vm.currentTool = .eraser
            vm.applyTool(x: x, y: y)
            vm.currentTool = prev
        }
    }
}

// MARK: - Color(hex:) helper

extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str = String(str.dropFirst()) }
        guard str.count == 6 || str.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&value) else { return nil }
        let r, g, b, a: Double
        if str.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8)  & 0xFF) / 255
            b = Double( value        & 0xFF) / 255
            a = 1.0
        } else {
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8)  & 0xFF) / 255
            a = Double( value        & 0xFF) / 255
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Crosshair cursor modifier

private struct CrosshairCursor: ViewModifier {
    func body(content: Content) -> some View {
        content.onHover { inside in
            if inside { NSCursor.crosshair.push() } else { NSCursor.pop() }
        }
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.modifier(CrosshairCursor())
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
git add Sources/PixelPetKit/View/PixelGridView.swift
git commit -m "feat: implement PixelGridView with checkerboard transparency"
```

---

## Task 4: ToolbarPanelView（左侧工具栏）

**Files:**
- Create: `Sources/PixelPetKit/View/ToolbarPanelView.swift`

- [ ] **Step 1: 实现 ToolbarPanelView**

`Sources/PixelPetKit/View/ToolbarPanelView.swift`:
```swift
import SwiftUI

public struct ToolbarPanelView: View {
    @ObservedObject var vm: EditorViewModel

    public init(vm: EditorViewModel) { self.vm = vm }

    public var body: some View {
        VStack(spacing: 8) {
            toolButton(tool: .pen, icon: "pencil")
            toolButton(tool: .eraser, icon: "eraser")
            toolButton(tool: .fill, icon: "paintbucket")
            toolButton(tool: .eyedropper, icon: "eyedropper")

            Divider()
                .frame(width: 36)
                .background(Color.orange.opacity(0.3))
                .padding(.vertical, 2)

            // Undo
            Button {
                vm.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(vm.canUndo ? Color(hex: "#F97316")! : .gray)
            }
            .buttonStyle(ToolButtonStyle(isActive: false))
            .disabled(!vm.canUndo)
            .keyboardShortcut("z", modifiers: .command)

            // Redo
            Button {
                vm.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(vm.canRedo ? Color(hex: "#F97316")! : .gray)
            }
            .buttonStyle(ToolButtonStyle(isActive: false))
            .disabled(!vm.canRedo)
            .keyboardShortcut("z", modifiers: [.command, .shift])

            Spacer()
        }
        .padding(.vertical, 14)
        .frame(width: 60)
        .background(Color(hex: "#FDECD3")!)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color(hex: "#F97316")!),
            alignment: .trailing
        )
    }

    @ViewBuilder
    private func toolButton(tool: DrawTool, icon: String) -> some View {
        Button {
            vm.currentTool = tool
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(vm.currentTool == tool ? .white : Color(hex: "#F97316")!)
        }
        .buttonStyle(ToolButtonStyle(isActive: vm.currentTool == tool))
    }
}

private struct ToolButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 40, height: 40)
            .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#F97316")!, lineWidth: 2.5)
            )
            .shadow(color: Color(hex: "#9A3412")!.opacity(0.5), radius: 0, x: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
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
git add Sources/PixelPetKit/View/ToolbarPanelView.swift
git commit -m "feat: implement left toolbar with tool buttons"
```

---

## Task 5: RightPanelView（右侧面板）

**Files:**
- Create: `Sources/PixelPetKit/View/RightPanelView.swift`

- [ ] **Step 1: 实现 RightPanelView**

`Sources/PixelPetKit/View/RightPanelView.swift`:
```swift
import SwiftUI

public struct RightPanelView: View {
    @ObservedObject var vm: EditorViewModel
    @Binding var pets: [PetDefinition]
    let onSelectPet: (PetDefinition) -> Void

    private let palette: [String] = [
        "#E63946", "#F97316", "#FFD166", "#06D6A0", "#118AB2",
        "#7C6AF7", "#FF6B9D", "#F4A261", "#2A2A2A", "#FFFFFF",
        "#AAAAAA", "#A8DADC", "#457B9D",
    ]

    public init(vm: EditorViewModel,
                pets: Binding<[PetDefinition]>,
                onSelectPet: @escaping (PetDefinition) -> Void) {
        self.vm = vm
        self._pets = pets
        self.onSelectPet = onSelectPet
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                sizeSection
                currentColorSection
                paletteSection
                petListSection
            }
            .padding(14)
        }
        .frame(width: 210)
        .background(Color(hex: "#FDECD3")!)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color(hex: "#F97316")!),
            alignment: .leading
        )
    }

    // MARK: - Size selector

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("画布尺寸")
            HStack(spacing: 5) {
                sizeButton(15)
                sizeButton(25)
                sizeButton(32)
            }
            if vm.pendingSize != nil {
                sizeConfirmBanner
            }
        }
    }

    @ViewBuilder
    private func sizeButton(_ size: Int) -> some View {
        let isActive = vm.canvas.size == size
        Button("\(size)×\(size)") {
            if !isActive { vm.pendingSize = size }
        }
        .font(.custom("Press Start 2P", size: 7))
        .padding(.horizontal, 8).padding(.vertical, 6)
        .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
        .foregroundColor(isActive ? .white : Color(hex: "#F97316")!)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
        .shadow(color: Color(hex: "#9A3412")!.opacity(0.4), radius: 0, x: 2, y: 2)
    }

    private var sizeConfirmBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("切换尺寸会清空画布，确定吗？")
                .font(.custom("VT323", size: 16))
                .foregroundColor(Color(hex: "#9A3412")!)
            HStack(spacing: 6) {
                Button("确定清空") {
                    if let s = vm.pendingSize {
                        vm.changeSize(s)
                        vm.pendingSize = nil
                    }
                }
                .font(.custom("Press Start 2P", size: 7))
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(Color(hex: "#E63946")!)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                Button("取消") { vm.pendingSize = nil }
                    .font(.custom("Press Start 2P", size: 7))
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color(hex: "#FFF7ED")!)
                    .foregroundColor(Color(hex: "#F97316")!)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#F97316")!, lineWidth: 2))
            }
        }
        .padding(8)
        .background(Color(hex: "#FFF3CD")!)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
    }

    // MARK: - Current color

    private var currentColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("当前颜色")
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: vm.currentHex) ?? .clear)
                    .frame(width: 36, height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#9A3412")!, lineWidth: 3))
                    .shadow(color: Color(hex: "#9A3412")!.opacity(0.5), radius: 0, x: 3, y: 3)
                Text(vm.currentHex.uppercased())
                    .font(.custom("VT323", size: 20))
                    .foregroundColor(Color(hex: "#1A1A2E")!)
            }
        }
    }

    // MARK: - Palette

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("调色盘")
            let columns = Array(repeating: GridItem(.fixed(28), spacing: 5), count: 5)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(palette, id: \.self) { hex in
                    swatchButton(hex: hex)
                }
                // Transparent swatch
                Button {
                    vm.currentHex = "transparent"
                } label: {
                    TransparentSwatchView()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.currentHex == "transparent"
                                        ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                        lineWidth: vm.currentHex == "transparent" ? 3 : 2.5)
                        )
                }
                .buttonStyle(.plain)
                // Custom color picker
                ColorPickerButton(selectedHex: $vm.currentHex)
            }
        }
    }

    @ViewBuilder
    private func swatchButton(hex: String) -> some View {
        let isSelected = vm.currentHex == hex
        Button {
            vm.currentHex = hex
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: hex) ?? .clear)
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                lineWidth: isSelected ? 3 : 2.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 0, x: 2, y: 2)
                .scaleEffect(isSelected ? 1.12 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.1), value: isSelected)
    }

    // MARK: - Pet list

    private var petListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("我的宠物")
            if pets.isEmpty {
                Text("还没有宠物，快去画一个！")
                    .font(.custom("VT323", size: 16))
                    .foregroundColor(.secondary)
            } else {
                ForEach(pets) { pet in
                    PetListRow(pet: pet, onTap: { onSelectPet(pet) })
                }
            }
        }
    }

    // MARK: - Section title helper

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.custom("VT323", size: 20))
            .fontWeight(.bold)
            .foregroundColor(Color(hex: "#9A3412")!)
    }
}

// MARK: - Sub-views

private struct PetListRow: View {
    let pet: PetDefinition
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 24, height: 24)
                Text(pet.name)
                    .font(.custom("VT323", size: 20))
                    .foregroundColor(Color(hex: "#1A1A2E")!)
                Spacer()
                Circle()
                    .fill(pet.isVisible ? Color(hex: "#06D6A0")! : Color.gray)
                    .frame(width: 10, height: 10)
                    .shadow(color: pet.isVisible ? Color(hex: "#06D6A0")!.opacity(0.6) : .clear,
                            radius: 3)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Color(hex: "#FFF7ED")!)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
            .shadow(color: Color(hex: "#9A3412")!.opacity(0.4), radius: 0, x: 2, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct TransparentSwatchView: View {
    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 7
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let isEven = (Int(x / tileSize) + Int(y / tileSize)) % 2 == 0
                    context.fill(
                        Path(CGRect(x: x, y: y, width: tileSize, height: tileSize)),
                        with: .color(isEven ? Color(white: 0.75) : .white)
                    )
                    x += tileSize
                }
                y += tileSize
            }
        }
    }
}

private struct ColorPickerButton: View {
    @Binding var selectedHex: String
    @State private var pickerColor: Color = Color(hex: "#F97316") ?? .orange

    var body: some View {
        ColorPicker("", selection: $pickerColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 28, height: 28)
            .onChange(of: pickerColor) { newColor in
                if let hex = newColor.toHex() {
                    selectedHex = hex
                }
            }
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = NSColor(self).usingColorSpace(.sRGB)?.cgColor.components,
              components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
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
git add Sources/PixelPetKit/View/RightPanelView.swift
git commit -m "feat: implement right panel with palette, size selector, pet list"
```

---

## Task 6: NamePetSheet（命名弹窗）

**Files:**
- Create: `Sources/PixelPetKit/View/NamePetSheet.swift`

- [ ] **Step 1: 实现 NamePetSheet**

`Sources/PixelPetKit/View/NamePetSheet.swift`:
```swift
import SwiftUI

public struct NamePetSheet: View {
    @Binding var name: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    public init(name: Binding<String>,
                onConfirm: @escaping () -> Void,
                onCancel: @escaping () -> Void) {
        self._name = name
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("给你的宠物取个名字")
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(Color(hex: "#F97316")!)
                .multilineTextAlignment(.center)

            TextField("未命名宠物", text: $name)
                .font(.custom("VT323", size: 22))
                .textFieldStyle(.roundedBorder)
                .onSubmit { if !name.isEmpty { onConfirm() } }

            HStack(spacing: 12) {
                Button("取消", action: onCancel)
                    .font(.custom("Press Start 2P", size: 8))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color(hex: "#FFF7ED")!)
                    .foregroundColor(Color(hex: "#F97316")!)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))

                Button("做成桌宠 ▶") {
                    if !name.isEmpty { onConfirm() }
                }
                .font(.custom("Press Start 2P", size: 8))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(name.isEmpty ? Color.gray : Color(hex: "#2563EB")!)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
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
git add Sources/PixelPetKit/View/NamePetSheet.swift
git commit -m "feat: implement NamePetSheet for pet naming"
```

---

## Task 7: EditorView（主布局组装）

**Files:**
- Modify: `Sources/PixelPetKit/View/EditorView.swift`

- [ ] **Step 1: 实现完整 EditorView**

`Sources/PixelPetKit/View/EditorView.swift`:
```swift
import SwiftUI

public struct EditorView: View {
    @StateObject private var vm = EditorViewModel(size: 32)
    @State private var pets: [PetDefinition] = []
    @State private var pendingPetName: String = ""
    @State private var showNameSheet = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Title bar row
            titleBar

            // Main three-column layout
            HStack(spacing: 0) {
                ToolbarPanelView(vm: vm)
                canvasArea
                RightPanelView(vm: vm, pets: $pets) { pet in
                    loadPetForEditing(pet)
                }
            }

            // Status bar
            statusBar
        }
        .background(Color(hex: "#FFF7ED")!)
        .sheet(isPresented: $showNameSheet) {
            NamePetSheet(name: $pendingPetName) {
                spawnPet()
                showNameSheet = false
            } onCancel: {
                showNameSheet = false
            }
        }
        .onAppear {
            loadPets()
        }
    }

    // MARK: - Title bar

    private var titleBar: some View {
        HStack {
            Text("✦ PIXELPET")
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(.white)
                .shadow(color: Color(hex: "#9A3412")!, radius: 0, x: 2, y: 2)

            Spacer()

            Button("新建") { vm.changeSize(vm.canvas.size) }
                .font(.custom("Press Start 2P", size: 8))
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.5), lineWidth: 3))

            Button("▶ 做成桌宠") {
                pendingPetName = "未命名宠物 \(pets.count + 1)"
                showNameSheet = true
            }
            .font(.custom("Press Start 2P", size: 8))
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(Color(hex: "#2563EB")!)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#1E3A8A")!, lineWidth: 3))
            .shadow(color: Color(hex: "#1E3A8A")!.opacity(0.6), radius: 0, x: 3, y: 3)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color(hex: "#F97316")!)
        .overlay(Rectangle().frame(height: 4).foregroundColor(Color(hex: "#9A3412")!), alignment: .bottom)
    }

    // MARK: - Canvas area

    private var canvasArea: some View {
        VStack(spacing: 10) {
            // Frame tabs
            HStack(spacing: 6) {
                frameTab(label: "普通帧", isActive: vm.activeFrame == .normal) {
                    vm.activeFrame = .normal
                }
                if vm.blinkCanvas != nil {
                    frameTab(label: "眨眼帧", isActive: vm.activeFrame == .blink) {
                        vm.activeFrame = .blink
                    }
                } else {
                    Button("+ 添加眨眼帧") { vm.addBlinkFrame() }
                        .font(.custom("Press Start 2P", size: 9))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color(hex: "#FFF7ED")!)
                        .foregroundColor(Color(hex: "#F97316")!)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#F97316")!, lineWidth: 3)
                            .opacity(0.65))
                }
            }

            // Pixel grid
            ScrollView([]) {
                PixelGridView(vm: vm)
                    .padding(6)
                    .background(Color(hex: "#FFF7ED")!)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#9A3412")!, lineWidth: 4)
                    )
                    .shadow(color: Color(hex: "#9A3412")!.opacity(0.6), radius: 0, x: 5, y: 5)
                    .padding(6)
            }

            Text("左键画色 · 右键擦除 · 按住拖动连续绘制")
                .font(.custom("VT323", size: 17))
                .foregroundColor(Color(hex: "#F97316")!.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            Color(hex: "#FFF8F0")!
                .overlay(
                    Canvas { ctx, size in
                        let step: CGFloat = 22
                        var x: CGFloat = 0
                        while x < size.width {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) },
                                       with: .color(Color.orange.opacity(0.05)), lineWidth: 1)
                            x += step
                        }
                        var y: CGFloat = 0
                        while y < size.height {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) },
                                       with: .color(Color.orange.opacity(0.05)), lineWidth: 1)
                            y += step
                        }
                    }
                )
        )
    }

    // MARK: - Status bar

    private var statusBar: some View {
        HStack(spacing: 16) {
            Text("\(vm.canvas.size)×\(vm.canvas.size)")
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white.opacity(0.9))
            Text("|").foregroundColor(.white.opacity(0.3))
            Text(toolName(vm.currentTool))
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            let visibleCount = pets.filter { $0.isVisible }.count
            Text("● \(visibleCount) 只宠物在桌面")
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color(hex: "#F97316")!)
        .overlay(Rectangle().frame(height: 3).foregroundColor(Color(hex: "#9A3412")!), alignment: .top)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func frameTab(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(label, action: action)
            .font(.custom("Press Start 2P", size: 9))
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
            .foregroundColor(isActive ? .white : Color(hex: "#F97316")!)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 3))
            .shadow(color: isActive ? Color(hex: "#9A3412")!.opacity(0.5) : .clear, radius: 0, x: 3, y: 3)
    }

    private func toolName(_ tool: DrawTool) -> String {
        switch tool {
        case .pen: return "画笔工具"
        case .eraser: return "橡皮工具"
        case .fill: return "填充工具"
        case .eyedropper: return "取色工具"
        }
    }

    private func loadPets() {
        pets = (try? PetStore.shared.loadAll()) ?? []
    }

    private func loadPetForEditing(_ pet: PetDefinition) {
        let restored = PixelCanvas.from(hexArray: pet.pixels, size: pet.canvasSize)
        vm.canvas = restored
        if let bp = pet.blinkPixels {
            vm.blinkCanvas = PixelCanvas.from(hexArray: bp, size: pet.canvasSize)
        } else {
            vm.blinkCanvas = nil
        }
        vm.activeFrame = .normal
    }

    private func spawnPet() {
        let normalImage = vm.canvas.toNSImage(scale: 8)
        let blinkImage = vm.blinkCanvas?.toNSImage(scale: 8)

        var pet = PetDefinition(
            name: pendingPetName,
            canvasSize: vm.canvas.size,
            pixels: vm.canvas.toHexArray(),
            blinkPixels: vm.blinkCanvas?.toHexArray()
        )

        do {
            try PetStore.shared.save(pet)
            try PetStore.shared.savePNGs(id: pet.id, normal: normalImage, blink: blinkImage)
            loadPets()
            // PetHostManager.shared.spawn(pet) — wired in Plan 3
        } catch {
            print("Failed to save pet: \(error)")
        }
    }
}
```

- [ ] **Step 2: 确认编译**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: 运行 App 验证 UI**

```bash
swift run PixelPetApp
```

Expected: 编辑器窗口打开，三栏布局可见，格子可点击绘制，颜色面板可选色，尺寸切换有确认 banner。

- [ ] **Step 4: Commit**

```bash
git add Sources/PixelPetKit/View/EditorView.swift
git commit -m "feat: assemble complete EditorView with all panels"
```

---

## 完成检查

Plan 2 完成后：
- `swift build` → `Build complete!`
- `swift run PixelPetApp` → 编辑器窗口打开
- 可以画像素画、切换工具、切换颜色、切换尺寸、添加眨眼帧
- 点击"做成桌宠"弹出命名弹窗，确认后保存到磁盘（`~/Library/Application Support/PixelPet/`）
- 宠物列表显示已保存的宠物

**下一步：Plan 3 — 桌面宠物运行时**
