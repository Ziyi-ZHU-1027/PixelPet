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

        // Use LazyVGrid instead of Canvas so each cell is a real SwiftUI view
        // that re-renders when @Published canvas changes.
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(cs), spacing: 0), count: size),
            spacing: 0
        ) {
            ForEach(0..<size * size, id: \.self) { idx in
                let x = idx % size
                let y = idx / size
                PixelCell(
                    color: cellColor(x: x, y: y),
                    isEven: (x + y) % 2 == 0
                )
                .frame(width: cs, height: cs)
            }
        }
        .frame(
            width: CGFloat(size) * cs,
            height: CGFloat(size) * cs
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

    private func cellColor(x: Int, y: Int) -> Color? {
        guard let hex = vm.activeCanvas.pixel(x: x, y: y) else { return nil }
        return Color(hex: hex)
    }
}

// MARK: - Single pixel cell

private struct PixelCell: View {
    let color: Color?
    let isEven: Bool

    var body: some View {
        Rectangle()
            .fill(color ?? (isEven ? Color(white: 0.85) : Color(white: 0.95)))
            .border(Color.orange.opacity(0.12), width: 0.5)
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
