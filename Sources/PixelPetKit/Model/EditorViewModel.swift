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
    // Throttle: only push undo snapshot once per gesture stroke
    private var didPushForCurrentStroke = false

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
            pushUndoOnce()
            if activeFrame == .blink {
                // Must reassign the whole optional to trigger @Published notification
                var b = blinkCanvas ?? PixelCanvas(size: canvas.size)
                b.setPixel(x: x, y: y, hex: currentHex)
                blinkCanvas = b
            } else {
                canvas.setPixel(x: x, y: y, hex: currentHex)
            }
        case .eraser:
            pushUndoOnce()
            if activeFrame == .blink {
                var b = blinkCanvas ?? PixelCanvas(size: canvas.size)
                b.setPixel(x: x, y: y, hex: nil)
                blinkCanvas = b
            } else {
                canvas.setPixel(x: x, y: y, hex: nil)
            }
        case .fill:
            pushUndoOnce()
            if activeFrame == .blink {
                var b = blinkCanvas ?? PixelCanvas(size: canvas.size)
                b.fill(x: x, y: y, hex: currentHex)
                blinkCanvas = b
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

    /// Call when a stroke ends (DragGesture.onEnded) to allow next stroke to push undo.
    public func endStroke() {
        didPushForCurrentStroke = false
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

    /// Push undo snapshot only once per stroke (throttled).
    private func pushUndoOnce() {
        guard !didPushForCurrentStroke else { return }
        didPushForCurrentStroke = true
        undoStack.append(canvas)
        if undoStack.count > maxUndoDepth { undoStack.removeFirst() }
        redoStack.removeAll()
    }
}
