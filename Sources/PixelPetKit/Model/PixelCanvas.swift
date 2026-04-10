import Foundation
import AppKit

/// In-memory pixel canvas. pixels[y][x] = hex string or nil (transparent).
public struct PixelCanvas {
    public let size: Int
    // storage: [y][x]
    private var pixels: [[String?]]

    public init(size: Int) {
        self.size = size
        self.pixels = [[String?]](
            repeating: [String?](repeating: nil, count: size),
            count: size
        )
    }

    public func pixel(x: Int, y: Int) -> String? {
        guard inBounds(x: x, y: y) else { return nil }
        return pixels[y][x]
    }

    public mutating func setPixel(x: Int, y: Int, hex: String?) {
        guard inBounds(x: x, y: y) else { return }
        pixels[y][x] = hex
    }

    public mutating func clear() {
        pixels = [[String?]](
            repeating: [String?](repeating: nil, count: size),
            count: size
        )
    }

    /// Flood-fill from (x,y) with hex color. nil fills nil-connected regions.
    public mutating func fill(x: Int, y: Int, hex: String?) {
        guard inBounds(x: x, y: y) else { return }
        let target = pixels[y][x]
        if target == hex { return }
        var queue = [(Int, Int)]()
        queue.append((x, y))
        while !queue.isEmpty {
            let (cx, cy) = queue.removeFirst()
            guard inBounds(x: cx, y: cy) else { continue }
            guard pixels[cy][cx] == target else { continue }
            pixels[cy][cx] = hex
            queue.append((cx + 1, cy))
            queue.append((cx - 1, cy))
            queue.append((cx, cy + 1))
            queue.append((cx, cy - 1))
        }
    }

    /// Serialize to [y][x] hex array for JSON storage.
    public func toHexArray() -> [[String?]] {
        return pixels
    }

    /// Deserialize from [y][x] hex array.
    public static func from(hexArray: [[String?]], size: Int) -> PixelCanvas {
        var canvas = PixelCanvas(size: size)
        for y in 0..<min(size, hexArray.count) {
            for x in 0..<min(size, hexArray[y].count) {
                canvas.pixels[y][x] = hexArray[y][x]
            }
        }
        return canvas
    }

    /// Render canvas to NSImage. Each pixel becomes a (scale × scale) block.
    /// Transparent pixels (nil) become fully transparent.
    public func toNSImage(scale: Int = 8) -> NSImage {
        let side = size * scale
        let imageSize = NSSize(width: side, height: side)
        let image = NSImage(size: imageSize)
        image.lockFocus()
        defer { image.unlockFocus() }

        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()

        for y in 0..<size {
            for x in 0..<size {
                guard let hex = pixels[y][x],
                      let color = NSColor(hex: hex) else { continue }
                color.setFill()
                let rect = NSRect(
                    x: x * scale,
                    y: (size - 1 - y) * scale,
                    width: scale,
                    height: scale
                )
                rect.fill()
            }
        }
        return image
    }

    private func inBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && x < size && y >= 0 && y < size
    }
}

// MARK: - NSColor hex helper

extension NSColor {
    /// Initialize from a "#RRGGBB" or "#RRGGBBAA" hex string.
    convenience init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str = String(str.dropFirst()) }
        guard str.count == 6 || str.count == 8 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: str).scanHexInt64(&value) else { return nil }
        let r, g, b, a: CGFloat
        if str.count == 6 {
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >> 8)  & 0xFF) / 255
            b = CGFloat( value        & 0xFF) / 255
            a = 1.0
        } else {
            r = CGFloat((value >> 24) & 0xFF) / 255
            g = CGFloat((value >> 16) & 0xFF) / 255
            b = CGFloat((value >> 8)  & 0xFF) / 255
            a = CGFloat( value        & 0xFF) / 255
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
