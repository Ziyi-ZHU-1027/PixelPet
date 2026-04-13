import SwiftUI

/// The interactive pixel grid. Transparent cells show a checkerboard pattern.
public struct PixelGridView: View {

    @ObservedObject var vm: EditorViewModel

    private var cellSize: CGFloat {
        switch vm.canvas.size {
        case 15: return 26
        case 25: return 21
        default: return 17
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
                        let isEven = (x + y) % 2 == 0
                        let checkColor: Color = isEven ? Color(white: 0.85) : Color(white: 0.95)
                        context.fill(Path(rect), with: .color(checkColor))
                    }
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
        .overlay(RightClickEraserOverlay(vm: vm, cellSize: cs))
        .onHover { inside in
            if inside { NSCursor.crosshair.push() } else { NSCursor.pop() }
        }
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
