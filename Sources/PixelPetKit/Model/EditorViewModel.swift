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
    @Published public var pendingSize: Int? = nil

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
