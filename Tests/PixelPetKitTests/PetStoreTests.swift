import XCTest
@testable import PixelPetKit

final class PetStoreTests: XCTestCase {

    var store: PetStore!
    var tempDir: URL!

    override func setUp() {
        super.setUp()
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

    func test_savePNGs_writesNormalPNG() throws {
        var canvas = PixelCanvas(size: 15)
        canvas.setPixel(x: 0, y: 0, hex: "#FF0000")
        let image = canvas.toNSImage(scale: 8)
        let pet = makePet(name: "PNGTest")
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
}
