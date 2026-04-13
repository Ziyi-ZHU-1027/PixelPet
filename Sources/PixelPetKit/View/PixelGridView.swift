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
        let size = vm.canvas.size   // use vm.canvas directly so SwiftUI tracks it
        let cs = cellSize
        // Snapshot pixels into a flat array so ForEach id changes trigger re-render
        let pixels = vm.canvas.toHexArray()

        VStack(spacing: 0) {
            ForEach(0..<size, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<size, id: \.self) { x in
                        let hex = y < pixels.count && x < pixels[y].count ? pixels[y][x] : nil
                        PixelCell(
                            color: hex.flatMap { Color(hex: $0) },
                            isEven: (x + y) % 2 == 0
                        )
                        .frame(width: cs, height: cs)
                    }
                }
            }
        }
        .frame(width: CGFloat(size) * cs, height: CGFloat(size) * cs)
        .background(
            // NSView layer handles right-click; sits behind SwiftUI gesture layer
            RightClickHandler(vm: vm, cellSize: cs)
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = Int(value.location.x / cs)
                    let y = Int(value.location.y / cs)
                    guard x >= 0, y >= 0,
                          x < size, y < size else { return }
                    vm.applyTool(x: x, y: y)
                }
                .onEnded { _ in
                    vm.endStroke()
                }
        )
        .onHover { inside in
            if inside { NSCursor.crosshair.push() } else { NSCursor.pop() }
        }
    }
}

// MARK: - Right-click handler
// Uses NSEvent local monitor so coordinate conversion is always accurate.

private struct RightClickHandler: NSViewRepresentable {
    let vm: EditorViewModel
    let cellSize: CGFloat

    func makeNSView(context: Context) -> RightClickNSView {
        let v = RightClickNSView(vm: vm, cellSize: cellSize)
        return v
    }
    func updateNSView(_ nsView: RightClickNSView, context: Context) {
        nsView.cellSize = cellSize
    }
}

private final class RightClickNSView: NSView {
    let vm: EditorViewModel
    var cellSize: CGFloat
    private var monitor: Any?

    init(vm: EditorViewModel, cellSize: CGFloat) {
        self.vm = vm
        self.cellSize = cellSize
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Install local monitor when we have a window
        if window != nil, monitor == nil {
            monitor = NSEvent.addLocalMonitorForEvents(
                matching: [.rightMouseDown, .rightMouseDragged]
            ) { [weak self] event in
                if event.type == .rightMouseDown {
                    self?.handleRightClick(event)
                } else {
                    self?.handleRightDrag(event)
                }
                return event
            }
        } else if window == nil {
            if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
        }
    }

    private func handleRightClick(_ event: NSEvent) {
        eraseAtMouseLocation()
    }

    private func handleRightDrag(_ event: NSEvent) {
        eraseAtMouseLocation()
    }

    private func eraseAtMouseLocation() {
        guard let win = window else { return }
        let winPt = win.convertPoint(fromScreen: NSEvent.mouseLocation)
        let viewPt = convert(winPt, from: nil)
        guard bounds.contains(viewPt) else { return }
        let x = Int(viewPt.x / cellSize)
        let y = Int((bounds.height - viewPt.y) / cellSize)
        let size = vm.canvas.size
        guard x >= 0, y >= 0, x < size, y < size else { return }
        Task { @MainActor in
            let prev = vm.currentTool
            vm.currentTool = .eraser
            vm.applyTool(x: x, y: y)
            vm.currentTool = prev
        }
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
