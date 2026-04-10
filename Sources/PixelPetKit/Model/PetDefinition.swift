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
