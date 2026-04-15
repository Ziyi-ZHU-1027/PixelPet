import Foundation

// MARK: - Built-in pet templates
// These are shown to users on first launch so they can experience the app immediately.

public struct PetTemplate {
    public let name: String
    public let canvasSize: Int
    public let pixels: [[String?]]

    public func toPetDefinition() -> PetDefinition {
        PetDefinition(
            name: name,
            canvasSize: canvasSize,
            pixels: pixels
        )
    }
}

public let builtinTemplates: [PetTemplate] = [
    // 小鸡 (15×15)
    PetTemplate(
        name: "小鸡",
        canvasSize: 15,
        pixels: [
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,"#FFD166","#FFD166","#FFD166",nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,"#FFD166","#FFD166","#FFD166","#FFD166","#FFD166",nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,"#FFD166","#FFD166","#FFD166","#2A2A2A","#F97316","#F97316",nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,"#FFD166","#FFD166","#FFD166","#FFD166","#FFD166",nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,"#FFD166","#FFD166","#FFD166",nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,"#F97316",nil,"#F97316",nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
        ]
    ),

    // 百变怪 (32×32)
    PetTemplate(
        name: "百变怪",
        canvasSize: 32,
        pixels: [
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#000000","#000000",nil,"#000000","#DB97CF","#FBC1DB","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#DB97CF","#FBC1DB","#DB97CF","#000000","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#000000","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#030303","#DB97CF","#2A292B","#DB97CF","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#DB97CF","#DB97CF","#DB97CF","#030303","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#2A292B","#2A292B","#DB97CF","#DB97CF","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#DB97CF","#DB97CF","#DB97CF","#2A292B","#2A292B","#2A292B","#2A292B","#2A292B","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#9963B8","#000000",nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#9963B8","#9963B8","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#DB97CF","#9963B8","#DB97CF","#9963B8","#9963B8","#000000",nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#9963B8","#9963B8","#9963B8","#DB97CF","#9963B8","#9963B8","#DB97CF","#DB97CF","#DB97CF","#9963B8","#9963B8","#9963B8","#9963B8","#2A292B","#000000",nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#9963B8","#2A292B","#000000","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#000000","#2A292B","#9963B8","#2A292B","#9963B8","#9963B8","#9963B8","#9963B8","#2A292B","#000000","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#000000","#000000","#2A292B","#9963B8","#9963B8","#2A292B","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,"#000000","#000000","#000000","#000000",nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
        ]
    ),
]
