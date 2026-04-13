import SwiftUI

public struct RightPanelView: View {
    @ObservedObject var vm: EditorViewModel
    @Binding var pets: [PetDefinition]
    let onSelectPet: (PetDefinition) -> Void

    private let palette: [String] = [
        "#E63946", "#F97316", "#FFD166", "#06D6A0", "#118AB2",
        "#7C6AF7", "#FF6B9D", "#F4A261", "#2A2A2A", "#FFFFFF",
        "#AAAAAA", "#A8DADC", "#457B9D",
    ]

    public init(vm: EditorViewModel,
                pets: Binding<[PetDefinition]>,
                onSelectPet: @escaping (PetDefinition) -> Void) {
        self.vm = vm
        self._pets = pets
        self.onSelectPet = onSelectPet
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                sizeSection
                currentColorSection
                paletteSection
                petListSection
            }
            .padding(14)
        }
        .frame(width: 210)
        .background(Color(hex: "#FDECD3")!)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color(hex: "#F97316")!),
            alignment: .leading
        )
    }

    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("画布尺寸")
            HStack(spacing: 5) {
                sizeButton(15)
                sizeButton(25)
                sizeButton(32)
            }
            if vm.pendingSize != nil {
                sizeConfirmBanner
            }
        }
    }

    @ViewBuilder
    private func sizeButton(_ size: Int) -> some View {
        let isActive = vm.canvas.size == size
        Button("\(size)×\(size)") {
            if !isActive { vm.pendingSize = size }
        }
        .font(.custom("Press Start 2P", size: 7))
        .padding(.horizontal, 8).padding(.vertical, 6)
        .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
        .foregroundColor(isActive ? .white : Color(hex: "#F97316")!)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
        .shadow(color: Color(hex: "#9A3412")!.opacity(0.4), radius: 0, x: 2, y: 2)
    }

    private var sizeConfirmBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("切换尺寸会清空画布，确定吗？")
                .font(.custom("VT323", size: 16))
                .foregroundColor(Color(hex: "#9A3412")!)
            HStack(spacing: 6) {
                Button("确定清空") {
                    if let s = vm.pendingSize {
                        vm.changeSize(s)
                        vm.pendingSize = nil
                    }
                }
                .font(.custom("Press Start 2P", size: 7))
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(Color(hex: "#E63946")!)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                Button("取消") { vm.pendingSize = nil }
                    .font(.custom("Press Start 2P", size: 7))
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color(hex: "#FFF7ED")!)
                    .foregroundColor(Color(hex: "#F97316")!)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#F97316")!, lineWidth: 2))
            }
        }
        .padding(8)
        .background(Color(hex: "#FFF3CD")!)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
    }

    private var currentColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("当前颜色")
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: vm.currentHex) ?? .clear)
                    .frame(width: 36, height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#9A3412")!, lineWidth: 3))
                    .shadow(color: Color(hex: "#9A3412")!.opacity(0.5), radius: 0, x: 3, y: 3)
                Text(vm.currentHex.uppercased())
                    .font(.custom("VT323", size: 20))
                    .foregroundColor(Color(hex: "#1A1A2E")!)
            }
        }
    }

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("调色盘")
            let columns = Array(repeating: GridItem(.fixed(28), spacing: 5), count: 5)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(palette, id: \.self) { hex in
                    swatchButton(hex: hex)
                }
                Button {
                    vm.currentHex = "transparent"
                } label: {
                    TransparentSwatchView()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.currentHex == "transparent"
                                        ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                        lineWidth: vm.currentHex == "transparent" ? 3 : 2.5)
                        )
                }
                .buttonStyle(.plain)
                ColorPickerButton(selectedHex: $vm.currentHex)
            }
        }
    }

    @ViewBuilder
    private func swatchButton(hex: String) -> some View {
        let isSelected = vm.currentHex == hex
        Button {
            vm.currentHex = hex
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: hex) ?? .clear)
                .frame(width: 28, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                lineWidth: isSelected ? 3 : 2.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 0, x: 2, y: 2)
                .scaleEffect(isSelected ? 1.12 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.1), value: isSelected)
    }

    private var petListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("我的宠物")
            if pets.isEmpty {
                Text("还没有宠物，快去画一个！")
                    .font(.custom("VT323", size: 16))
                    .foregroundColor(.secondary)
            } else {
                ForEach(pets) { pet in
                    PetListRow(pet: pet, onTap: { onSelectPet(pet) })
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.custom("VT323", size: 20))
            .fontWeight(.bold)
            .foregroundColor(Color(hex: "#9A3412")!)
    }
}

private struct PetListRow: View {
    let pet: PetDefinition
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 24, height: 24)
                Text(pet.name)
                    .font(.custom("VT323", size: 20))
                    .foregroundColor(Color(hex: "#1A1A2E")!)
                Spacer()
                Circle()
                    .fill(pet.isVisible ? Color(hex: "#06D6A0")! : Color.gray)
                    .frame(width: 10, height: 10)
                    .shadow(color: pet.isVisible ? Color(hex: "#06D6A0")!.opacity(0.6) : .clear,
                            radius: 3)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Color(hex: "#FFF7ED")!)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
            .shadow(color: Color(hex: "#9A3412")!.opacity(0.4), radius: 0, x: 2, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct TransparentSwatchView: View {
    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 7
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let isEven = (Int(x / tileSize) + Int(y / tileSize)) % 2 == 0
                    context.fill(
                        Path(CGRect(x: x, y: y, width: tileSize, height: tileSize)),
                        with: .color(isEven ? Color(white: 0.75) : .white)
                    )
                    x += tileSize
                }
                y += tileSize
            }
        }
    }
}

private struct ColorPickerButton: View {
    @Binding var selectedHex: String
    @State private var pickerColor: Color = Color(hex: "#F97316") ?? .orange

    var body: some View {
        ColorPicker("", selection: $pickerColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 28, height: 28)
            .onChange(of: pickerColor) { newColor in
                if let hex = newColor.toHex() {
                    selectedHex = hex
                }
            }
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = NSColor(self).usingColorSpace(.sRGB)?.cgColor.components,
              components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
