import Foundation
import AppKit

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

    public func normalPNGURL(id: UUID) -> URL {
        let folder = petFolderURL(id: id)
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("normal.png")
    }

    public func blinkPNGURL(id: UUID) -> URL {
        let folder = petFolderURL(id: id)
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("blink.png")
    }

    // MARK: - PNG read/write

    public func savePNGs(id: UUID, normal: NSImage, blink: NSImage?) throws {
        try writePNG(normal, to: normalPNGURL(id: id))
        if let blink = blink {
            try writePNG(blink, to: blinkPNGURL(id: id))
        }
    }

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

    // MARK: - Private

    private func write(_ pets: [PetDefinition]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(pets)
        try data.write(to: petsJSONURL, options: .atomic)
    }
}

// MARK: - Errors

public enum PetStoreError: Error {
    case renderFailed
}
