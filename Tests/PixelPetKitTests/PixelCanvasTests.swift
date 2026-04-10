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
        var canvas = PixelCanvas(size: 3)
        canvas.setPixel(x: 0, y: 0, hex: "#0000FF")
        canvas.setPixel(x: 1, y: 0, hex: "#0000FF")
        canvas.setPixel(x: 2, y: 0, hex: "#0000FF")
        canvas.fill(x: 0, y: 2, hex: "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 0, y: 2), "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 1, y: 2), "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 2, y: 2), "#FF0000")
        XCTAssertEqual(canvas.pixel(x: 0, y: 0), "#0000FF")
        XCTAssertEqual(canvas.pixel(x: 1, y: 0), "#0000FF")
    }
}
