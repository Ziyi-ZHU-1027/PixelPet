# PixelPet Plan 1: 项目脚手架 + 数据模型 + 持久化

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 PixelPet 的 Swift Package 项目骨架，实现 PixelCanvas 画布模型、PetDefinition 数据结构和 PetStore 持久化层，能够保存/读取宠物数据到磁盘。

**Architecture:** SPM 单 target `PixelPetKit` 共享库 + `PixelPetApp` 可执行 target。数据层完全独立于 UI，用 `PetStore.shared` 单例管理磁盘读写，`PixelCanvas` 是纯内存模型。

**Tech Stack:** Swift 5.9+, macOS 13+, SwiftUI, AppKit, Swift Package Manager, XCTest

---

## 文件结构

```
PixelPet/
├── Package.swift
├── Sources/
│   ├── PixelPetKit/
│   │   └── Model/
│   │       ├── PixelCanvas.swift      # 画布内存模型（像素数组 + 操作方法）
│   │       ├── PetDefinition.swift    # 宠物完整定义（Codable）
│   │       └── PetStore.swift         # 磁盘持久化（JSON + PNG）
│   └── PixelPetApp/
│       └── main.swift                 # 最小 App 入口（Hello World 占位）
└── Tests/
    └── PixelPetKitTests/
        ├── PixelCanvasTests.swift
        └── PetStoreTests.swift
```

---

## Task 1: 初始化 SPM 项目结构

**Files:**
- Create: `Package.swift`
- Create: `Sources/PixelPetApp/main.swift`
- Create: `Sources/PixelPetKit/Model/PixelCanvas.swift` (空占位)
- Create: `Sources/PixelPetKit/Model/PetDefinition.swift` (空占位)
- Create: `Sources/PixelPetKit/Model/PetStore.swift` (空占位)
- Create: `Tests/PixelPetKitTests/PixelCanvasTests.swift` (空占位)
- Create: `Tests/PixelPetKitTests/PetStoreTests.swift` (空占位)

- [ ] **Step 1: 创建目录结构**

```bash
cd /Users/zhuziyi/Desktop/PixelPet
mkdir -p Sources/PixelPetKit/Model
mkdir -p Sources/PixelPetApp
mkdir -p Tests/PixelPetKitTests
```

- [ ] **Step 2: 写 Package.swift**

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

- [ ] **Step 3: 写最小 App 入口**

`Sources/PixelPetApp/main.swift`:
```swift
import Foundation
print("PixelPet")
```

- [ ] **Step 4: 创建空占位文件**

`Sources/PixelPetKit/Model/PixelCanvas.swift`:
```swift
import Foundation
```

`Sources/PixelPetKit/Model/PetDefinition.swift`:
```swift
import Foundation
```

`Sources/PixelPetKit/Model/PetStore.swift`:
```swift
import Foundation
```

`Tests/PixelPetKitTests/PixelCanvasTests.swift`:
```swift
import XCTest
@testable import PixelPetKit
```

`Tests/PixelPetKitTests/PetStoreTests.swift`:
```swift
import XCTest
@testable import PixelPetKit
```

- [ ] **Step 5: 验证项目能编译**

```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift build
```

Expected: `Build complete!`

- [ ] **Step 6: Commit**

```bash
git add Package.swift Sources/ Tests/
git commit -m "feat: initialize SPM project structure"
```

---

## Task 2: PixelCanvas 数据模型

**Files:**
- Modify: `Sources/PixelPetKit/Model/PixelCanvas.swift`
- Modify: `Tests/PixelPetKitTests/PixelCanvasTests.swift`

- [ ] **Step 1: 写失败测试**

`Tests/PixelPetKitTests/PixelCanvasTests.swift`:
```swift
import XCTest
@testable import PixelPetKit

final class PixelCanvasTests: XCTestCase {

    func test_init_allPixelsTransparent() {
        let canvas = PixelCanvas(size: 15)
        XCTAssertEqual(canvas.size, 15)
        for y in 0..<15 {
            for x in 0..<15 {
                XCTAssertNil(canvas.pixel(x: x, y: y), "pixel (\(x),\(y)) should be nil")
            }
        }
    }

    func test_setPixel_storesHex() {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 3, y: 7, hex: "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 3, y: 7), "#FF0000")
    }

    func test_setPixel_nilClearsPixel() {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        canvas.setPixel(x: 0, y: 0, hex: nil)
        XCTAssertNil(canvas.pixel(x: 0, y: 0))
    }

    func test_clear_resetsAllPixels() {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        canvas.setPixel(x: 14, y: 14, hex: "#00FF00")
        canvas.clear()
        XCTAssertNil(canvas.pixel(x: 0, y: 0))
        XCTAssertNil(canvas.pixel(x: 14, y: 14))
    }

    func test_toHexArray_roundtrip() {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 2, y: 5, hex: "#AABBCC")
        canvas.setPixel(x: 7, y: 7, hex: "#112233")
        let arr = canvas.toHexArray()
        XCTAssertEqual(arr.count, 15)
        XCTAssertEqual(arr[0].count, 15)
        XCTAssertEqual(arr[5][2], "#AABBCC")
        XCTAssertEqual(arr[7][7], "#112233")
        XCTAssertNil(arr[0][0])
    }

    func test_fromHexArray_restoresPixels() {
        var original = PixelCanvas(size: 15)
        original.setPixel(x: 1, y: 3, hex: "#FF6600")
        let arr = original.toHexArray()
        let restored = PixelCanvas.from(hexArray: arr, size: 15)
        XCTAssertEqual(restored.pixel(x: 1, y: 3), "#FF6600")
        XCTAssertNil(restored.pixel(x: 0, y: 0))
    }

    func test_fill_floodFillsConnectedRegion() {
        // 3x3 canvas, all nil, fill center → all become red
        var canvas = PixelCanvas(size: 3)
        canvas.fill(x: 1, y: 1, hex: "#FF0000")
        for y in 0..<3 {
            for x in 0..<3 {
                XCTAssertEqual(canvas.pixel(x: x, y: y), "#FF0000",
                               "pixel (\(x),\(y)) should be red after flood fill")
            }
        }
    }

    func test_fill_doesNotCrossColorBoundary() {
        // 3x3 canvas: top row is blue, rest nil. Fill bottom-left with red.
        var canvas = PixelCanvas(size: 3)
        canvas.setPixel(x: 0, y: 0, hex: "#0000FF")
        canvas.setPixel(x: 1, y: 0, hex: "#0000FF")
        canvas.setPixel(x: 2, y: 0, hex: "#0000FF")
        canvas.fill(x: 0, y: 2, hex: "#FF0000")
        // Bottom row and middle row should be red
        XCTAssertEqual(canvas.pixel(x: 0, y: 2), "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 1, y: 2), "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 2, y: 2), "#FF0000")
        // Top row should remain blue
        XCTAssertEqual(canvas.pixel(x: 0, y: 0), "#0000FF")
        XCTAssertEqual(canvas.pixel(x: 1, y: 0), "#0000FF")
    }
}
```

- [ ] **Step 2: 运行测试，确认失败**

```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift test --filter PixelCanvasTests 2>&1 | head -20
```

Expected: 编译错误 `cannot find type 'PixelCanvas'`

- [ ] **Step 3: 实现 PixelCanvas**

`Sources/PixelPetKit/Model/PixelCanvas.swift`:
```swift
import Foundation

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

    private func inBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && x < size && y >= 0 && y < size
    }
}
```

- [ ] **Step 4: 运行测试，确认全部通过**

```bash
swift test --filter PixelCanvasTests
```

Expected: `Test Suite 'PixelCanvasTests' passed` — 7 tests passed

- [ ] **Step 5: Commit**

```bash
git add Sources/PixelPetKit/Model/PixelCanvas.swift Tests/PixelPetKitTests/PixelCanvasTests.swift
git commit -m "feat: implement PixelCanvas with flood fill"
```

---

## Task 3: PetDefinition 数据结构

**Files:**
- Modify: `Sources/PixelPetKit/Model/PetDefinition.swift`

- [ ] **Step 1: 实现 PetDefinition**

`Sources/PixelPetKit/Model/PetDefinition.swift`:
```swift
import Foundation

public struct PetDefinition: Codable, Identifiable {
    public let id: UUID
    public var name: String
    public var canvasSize: Int          // 15 / 25 / 32
    public var pixels: [[String?]]      // [y][x] → hex, nil = transparent
    public var blinkPixels: [[String?]]? // nil = no blink frame
    public var isWandering: Bool
    public var isVisible: Bool
    public var lastPositionX: Double?
    public var lastPositionY: Double?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        canvasSize: Int,
        pixels: [[String?]],
        blinkPixels: [[String?]]? = nil,
        isWandering: Bool = false,
        isVisible: Bool = true,
        lastPositionX: Double? = nil,
        lastPositionY: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.canvasSize = canvasSize
        self.pixels = pixels
        self.blinkPixels = blinkPixels
        self.isWandering = isWandering
        self.isVisible = isVisible
        self.lastPositionX = lastPositionX
        self.lastPositionY = lastPositionY
        self.createdAt = createdAt
    }
}
```

> Note: `CGPoint` は `Codable` ではないため `Double?` ペアで保存する。

- [ ] **Step 2: 確認コンパイル通過**

```bash
swift build 2>&1 | tail -5
```

Expected: `Build complete!`

- [ ] **Step 3: Commit**

```bash
git add Sources/PixelPetKit/Model/PetDefinition.swift
git commit -m "feat: add PetDefinition Codable struct"
```

---

## Task 4: PetStore 持久化层

**Files:**
- Modify: `Sources/PixelPetKit/Model/PetStore.swift`
- Modify: `Tests/PixelPetKitTests/PetStoreTests.swift`

- [ ] **Step 1: 写失败测试**

`Tests/PixelPetKitTests/PetStoreTests.swift`:
```swift
import XCTest
@testable import PixelPetKit

final class PetStoreTests: XCTestCase {

    var store: PetStore!
    var tempDir: URL!

    override func setUp() {
        super.setUp()
        // Use a temp directory so tests don't pollute ~/Library
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PixelPetTests-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = PetStore(baseURL: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func makePet(name: String = "TestPet", size: Int = 15) -> PetDefinition {
        let pixels = [[String?]](repeating: [String?](repeating: nil, count: size), count: size)
        return PetDefinition(name: name, canvasSize: size, pixels: pixels)
    }

    func test_saveAndLoadAll_roundtrip() throws {
        let pet = makePet(name: "Kitty")
        try store.save(pet)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Kitty")
        XCTAssertEqual(loaded[0].id, pet.id)
    }

    func test_saveMultiple_allLoaded() throws {
        let pet1 = makePet(name: "A")
        let pet2 = makePet(name: "B")
        try store.save(pet1)
        try store.save(pet2)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 2)
        let names = Set(loaded.map { $0.name })
        XCTAssertEqual(names, ["A", "B"])
    }

    func test_save_updatesExisting() throws {
        var pet = makePet(name: "Original")
        try store.save(pet)
        pet.name = "Updated"
        try store.save(pet)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "Updated")
    }

    func test_delete_removesPet() throws {
        let pet = makePet(name: "ToDelete")
        try store.save(pet)
        try store.delete(id: pet.id)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 0)
    }

    func test_delete_createsPetFolder_thenRemovesIt() throws {
        let pet = makePet(name: "FolderTest")
        try store.save(pet)
        let petFolder = tempDir.appendingPathComponent("pets/\(pet.id.uuidString)")
        // folder may or may not exist before PNG save — just check delete cleans up
        try store.delete(id: pet.id)
        XCTAssertFalse(FileManager.default.fileExists(atPath: petFolder.path))
    }

    func test_loadAll_emptyWhenNoFile() throws {
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.count, 0)
    }

    func test_update_changesField() throws {
        var pet = makePet(name: "Wanderer")
        try store.save(pet)
        pet.isWandering = true
        pet.lastPositionX = 100.0
        pet.lastPositionY = 200.0
        try store.update(pet)
        let loaded = try store.loadAll()
        XCTAssertEqual(loaded[0].isWandering, true)
        XCTAssertEqual(loaded[0].lastPositionX, 100.0)
    }
}
```

- [ ] **Step 2: 运行测试，确认失败**

```bash
swift test --filter PetStoreTests 2>&1 | head -20
```

Expected: 编译错误 `cannot find type 'PetStore'`

- [ ] **Step 3: 实现 PetStore**

`Sources/PixelPetKit/Model/PetStore.swift`:
```swift
import Foundation

public final class PetStore {

    private let baseURL: URL
    private var petsJSONURL: URL { baseURL.appendingPathComponent("pets.json") }
    private func petFolderURL(id: UUID) -> URL {
        baseURL.appendingPathComponent("pets/\(id.uuidString)")
    }

    /// Production init: uses ~/Library/Application Support/PixelPet/
    public static let shared: PetStore = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let base = appSupport.appendingPathComponent("PixelPet")
        return PetStore(baseURL: base)
    }()

    /// Designated init — accepts custom baseURL for testing.
    public init(baseURL: URL) {
        self.baseURL = baseURL
        try? FileManager.default.createDirectory(
            at: baseURL, withIntermediateDirectories: true)
    }

    // MARK: - Load

    public func loadAll() throws -> [PetDefinition] {
        guard FileManager.default.fileExists(atPath: petsJSONURL.path) else {
            return []
        }
        let data = try Data(contentsOf: petsJSONURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([PetDefinition].self, from: data)
    }

    // MARK: - Save / Update

    public func save(_ pet: PetDefinition) throws {
        var all = (try? loadAll()) ?? []
        if let idx = all.firstIndex(where: { $0.id == pet.id }) {
            all[idx] = pet
        } else {
            all.append(pet)
        }
        try write(all)
    }

    public func update(_ pet: PetDefinition) throws {
        try save(pet)
    }

    // MARK: - Delete

    public func delete(id: UUID) throws {
        var all = (try? loadAll()) ?? []
        all.removeAll { $0.id == id }
        try write(all)
        let folder = petFolderURL(id: id)
        if FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.removeItem(at: folder)
        }
    }

    // MARK: - PNG helpers

    /// Returns the URL for a pet's normal.png (creates folder if needed).
    public func normalPNGURL(id: UUID) -> URL {
        let folder = petFolderURL(id: id)
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("normal.png")
    }

    /// Returns the URL for a pet's blink.png (creates folder if needed).
    public func blinkPNGURL(id: UUID) -> URL {
        let folder = petFolderURL(id: id)
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("blink.png")
    }

    // MARK: - Private

    private func write(_ pets: [PetDefinition]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(pets)
        try data.write(to: petsJSONURL, options: .atomic)
    }
}
```

- [ ] **Step 4: 运行测试，确认全部通过**

```bash
swift test --filter PetStoreTests
```

Expected: `Test Suite 'PetStoreTests' passed` — 7 tests passed

- [ ] **Step 5: 运行全部测试**

```bash
swift test
```

Expected: 全部通过，无失败

- [ ] **Step 6: Commit**

```bash
git add Sources/PixelPetKit/Model/PetStore.swift Tests/PixelPetKitTests/PetStoreTests.swift
git commit -m "feat: implement PetStore with JSON persistence"
```

---

## Task 5: PixelCanvas → NSImage 渲染

**Files:**
- Modify: `Sources/PixelPetKit/Model/PixelCanvas.swift`
- Modify: `Tests/PixelPetKitTests/PixelCanvasTests.swift`

> Note: `toNSImage` 需要 AppKit，测试在 macOS 上运行所以没问题。

- [ ] **Step 1: 写失败测试**

在 `Tests/PixelPetKitTests/PixelCanvasTests.swift` 末尾追加：

```swift
    func test_toNSImage_correctSize() {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        let image = canvas.toNSImage(scale: 8)
        // 15 * 8 = 120
        XCTAssertEqual(image.size.width, 120)
        XCTAssertEqual(image.size.height, 120)
    }

    func test_toNSImage_transparentPixelHasZeroAlpha() {
        let canvas = PixelCanvas(size: 4)
        // All transparent
        let image = canvas.toNSImage(scale: 4)
        // Sample center pixel of first cell (2,2) — should be transparent
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            XCTFail("Could not get CGImage"); return
        }
        let w = cgImage.width
        let h = cgImage.height
        var pixels = [UInt8](repeating: 0, count: w * h * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &pixels, width: w, height: h,
                                  bitsPerComponent: 8, bytesPerRow: w * 4,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            XCTFail("Could not create CGContext"); return
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        // Alpha channel of pixel (2,2)
        let idx = (2 * w + 2) * 4
        XCTAssertEqual(pixels[idx + 3], 0, "transparent pixel should have alpha=0")
    }
```

- [ ] **Step 2: 运行测试，确认失败**

```bash
swift test --filter PixelCanvasTests 2>&1 | head -20
```

Expected: 编译错误 `value of type 'PixelCanvas' has no member 'toNSImage'`

- [ ] **Step 3: 在 PixelCanvas.swift 中追加 toNSImage**

在 `Sources/PixelPetKit/Model/PixelCanvas.swift` 顶部追加 import，并在末尾追加方法：

文件顶部改为：
```swift
import Foundation
import AppKit
```

在 `PixelCanvas` struct 末尾（`inBounds` 之前）追加：

```swift
    /// Render canvas to NSImage. Each pixel becomes a (scale × scale) block.
    /// Transparent pixels (nil) become fully transparent.
    public func toNSImage(scale: Int = 8) -> NSImage {
        let side = size * scale
        let imageSize = NSSize(width: side, height: side)
        let image = NSImage(size: imageSize)
        image.lockFocus()
        defer { image.unlockFocus() }

        // Clear to transparent
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()

        for y in 0..<size {
            for x in 0..<size {
                guard let hex = pixels[y][x],
                      let color = NSColor(hex: hex) else { continue }
                color.setFill()
                // NSImage coordinate: y=0 is bottom, so flip
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
```

在 `PixelCanvas.swift` 文件末尾（struct 外）追加 NSColor hex 扩展：

```swift
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
```

- [ ] **Step 4: 运行测试，确认全部通过**

```bash
swift test --filter PixelCanvasTests
```

Expected: `Test Suite 'PixelCanvasTests' passed` — 9 tests passed

- [ ] **Step 5: 运行全部测试**

```bash
swift test
```

Expected: 全部通过

- [ ] **Step 6: Commit**

```bash
git add Sources/PixelPetKit/Model/PixelCanvas.swift Tests/PixelPetKitTests/PixelCanvasTests.swift
git commit -m "feat: add PixelCanvas.toNSImage with hex color rendering"
```

---

## Task 6: PetStore PNG 写入

**Files:**
- Modify: `Sources/PixelPetKit/Model/PetStore.swift`
- Modify: `Tests/PixelPetKitTests/PetStoreTests.swift`

- [ ] **Step 1: 写失败测试**

在 `Tests/PixelPetKitTests/PetStoreTests.swift` 末尾追加：

```swift
    func test_savePNGs_writesNormalPNG() throws {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        let image = canvas.toNSImage(scale: 8)

        var pet = makePet(name: "PNGTest")
        try store.save(pet)
        try store.savePNGs(id: pet.id, normal: image, blink: nil)

        let normalURL = store.normalPNGURL(id: pet.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: normalURL.path),
                      "normal.png should exist after savePNGs")
    }

    func test_savePNGs_writesBlinkPNG_whenProvided() throws {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#0000FF")
        let image = canvas.toNSImage(scale: 8)

        let pet = makePet(name: "BlinkTest")
        try store.save(pet)
        try store.savePNGs(id: pet.id, normal: image, blink: image)

        let blinkURL = store.blinkPNGURL(id: pet.id)
        XCTAssertTrue(FileManager.default.fileExists(atPath: blinkURL.path),
                      "blink.png should exist when blink image provided")
    }

    func test_loadImages_returnsNilWhenNoFile() {
        let fakeID = UUID()
        let (normal, blink) = store.loadImages(id: fakeID)
        XCTAssertNil(normal)
        XCTAssertNil(blink)
    }

    func test_loadImages_returnsImagesAfterSave() throws {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        let image = canvas.toNSImage(scale: 8)

        let pet = makePet(name: "LoadTest")
        try store.save(pet)
        try store.savePNGs(id: pet.id, normal: image, blink: nil)

        let (normal, blink) = store.loadImages(id: pet.id)
        XCTAssertNotNil(normal)
        XCTAssertNil(blink)
    }
```

- [ ] **Step 2: 运行测试，确认失败**

```bash
swift test --filter PetStoreTests 2>&1 | head -20
```

Expected: 编译错误 `value of type 'PetStore' has no member 'savePNGs'`

- [ ] **Step 3: 在 PetStore.swift 追加 PNG 方法**

在 `PetStore` class 末尾（`write` 方法之前）追加：

```swift
    // MARK: - PNG read/write

    /// Write rendered NSImages to disk as PNG files.
    public func savePNGs(id: UUID, normal: NSImage, blink: NSImage?) throws {
        try writePNG(normal, to: normalPNGURL(id: id))
        if let blink = blink {
            try writePNG(blink, to: blinkPNGURL(id: id))
        }
    }

    /// Load previously saved PNG images from disk.
    /// Returns (normal, blink) — blink is nil if no blink.png exists.
    public func loadImages(id: UUID) -> (normal: NSImage?, blink: NSImage?) {
        let normalURL = petFolderURL(id: id).appendingPathComponent("normal.png")
        let blinkURL  = petFolderURL(id: id).appendingPathComponent("blink.png")
        let normal = NSImage(contentsOf: normalURL)
        let blink  = NSImage(contentsOf: blinkURL)
        return (normal, blink)
    }

    private func writePNG(_ image: NSImage, to url: URL) throws {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            throw PetStoreError.renderFailed
        }
        try png.write(to: url, options: .atomic)
    }
```

在 `PetStore.swift` 末尾（class 外）追加：

```swift
// MARK: - Errors

public enum PetStoreError: Error {
    case renderFailed
}
```

在 `PetStore.swift` 顶部追加 import：

```swift
import AppKit
```

- [ ] **Step 4: 运行测试，确认全部通过**

```bash
swift test --filter PetStoreTests
```

Expected: `Test Suite 'PetStoreTests' passed` — 11 tests passed

- [ ] **Step 5: 运行全部测试**

```bash
swift test
```

Expected: 全部通过

- [ ] **Step 6: Commit**

```bash
git add Sources/PixelPetKit/Model/PetStore.swift Tests/PixelPetKitTests/PetStoreTests.swift
git commit -m "feat: add PetStore PNG save/load"
```

---

## 完成检查

Plan 1 完成后，你应该能：

```bash
swift test   # 全部通过
swift build  # Build complete!
```

磁盘结构验证（手动）：

```swift
// 在 main.swift 里临时跑一下
import PixelPetKit
var canvas = PixelCanvas(size: 15)
canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
let pet = PetDefinition(name: "Test", canvasSize: 15, pixels: canvas.toHexArray())
try PetStore.shared.save(pet)
print("Saved to:", FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("PixelPet/pets.json").path)
```

---

**下一步：Plan 2 — 画板编辑器 UI**
