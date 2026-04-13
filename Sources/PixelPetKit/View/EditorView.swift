import SwiftUI

public struct EditorView: View {
    @StateObject private var vm = EditorViewModel(size: 32)
    @State private var pets: [PetDefinition] = []
    @State private var pendingPetName: String = ""
    @State private var showNameSheet = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            titleBar

            HStack(spacing: 0) {
                ToolbarPanelView(vm: vm)
                canvasArea
                RightPanelView(vm: vm, pets: $pets) { pet in
                    loadPetForEditing(pet)
                }
            }

            statusBar
        }
        .background(Color(hex: "#FFF7ED")!)
        .sheet(isPresented: $showNameSheet) {
            NamePetSheet(name: $pendingPetName) {
                spawnPet()
                showNameSheet = false
            } onCancel: {
                showNameSheet = false
            }
        }
        .onAppear {
            loadPets()
        }
    }

    // MARK: - Title bar

    private var titleBar: some View {
        HStack {
            Text("✦ PIXELPET")
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(.white)
                .shadow(color: Color(hex: "#9A3412")!, radius: 0, x: 2, y: 2)

            Spacer()

            Button("新建") { vm.changeSize(vm.canvas.size) }
                .font(.custom("Press Start 2P", size: 8))
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.5), lineWidth: 3))

            Button("▶ 做成桌宠") {
                pendingPetName = "未命名宠物 \(pets.count + 1)"
                showNameSheet = true
            }
            .font(.custom("Press Start 2P", size: 8))
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(Color(hex: "#2563EB")!)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#1E3A8A")!, lineWidth: 3))
            .shadow(color: Color(hex: "#1E3A8A")!.opacity(0.6), radius: 0, x: 3, y: 3)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color(hex: "#F97316")!)
        .overlay(Rectangle().frame(height: 4).foregroundColor(Color(hex: "#9A3412")!), alignment: .bottom)
    }

    // MARK: - Canvas area

    private var canvasArea: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                frameTab(label: "普通帧", isActive: vm.activeFrame == .normal) {
                    vm.activeFrame = .normal
                }
                if vm.blinkCanvas != nil {
                    frameTab(label: "眨眼帧", isActive: vm.activeFrame == .blink) {
                        vm.activeFrame = .blink
                    }
                } else {
                    Button("+ 添加眨眼帧") { vm.addBlinkFrame() }
                        .font(.custom("Press Start 2P", size: 9))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color(hex: "#FFF7ED")!)
                        .foregroundColor(Color(hex: "#F97316")!)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "#F97316")!, lineWidth: 3)
                            .opacity(0.65))
                }
            }

            ScrollView([]) {
                PixelGridView(vm: vm)
                    .padding(6)
                    .background(Color(hex: "#FFF7ED")!)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#9A3412")!, lineWidth: 4)
                    )
                    .shadow(color: Color(hex: "#9A3412")!.opacity(0.6), radius: 0, x: 5, y: 5)
                    .padding(6)
            }

            Text("左键画色 · 右键擦除 · 按住拖动连续绘制")
                .font(.custom("VT323", size: 17))
                .foregroundColor(Color(hex: "#F97316")!.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            Color(hex: "#FFF8F0")!
                .overlay(
                    Canvas { ctx, size in
                        let step: CGFloat = 22
                        var x: CGFloat = 0
                        while x < size.width {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) },
                                       with: .color(Color.orange.opacity(0.05)), lineWidth: 1)
                            x += step
                        }
                        var y: CGFloat = 0
                        while y < size.height {
                            ctx.stroke(Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) },
                                       with: .color(Color.orange.opacity(0.05)), lineWidth: 1)
                            y += step
                        }
                    }
                )
        )
    }

    // MARK: - Status bar

    private var statusBar: some View {
        HStack(spacing: 16) {
            Text("\(vm.canvas.size)×\(vm.canvas.size)")
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white.opacity(0.9))
            Text("|").foregroundColor(.white.opacity(0.3))
            Text(toolName(vm.currentTool))
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            let visibleCount = pets.filter { $0.isVisible }.count
            Text("● \(visibleCount) 只宠物在桌面")
                .font(.custom("VT323", size: 18))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color(hex: "#F97316")!)
        .overlay(Rectangle().frame(height: 3).foregroundColor(Color(hex: "#9A3412")!), alignment: .top)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func frameTab(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(label, action: action)
            .font(.custom("Press Start 2P", size: 9))
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
            .foregroundColor(isActive ? .white : Color(hex: "#F97316")!)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 3))
            .shadow(color: isActive ? Color(hex: "#9A3412")!.opacity(0.5) : .clear, radius: 0, x: 3, y: 3)
    }

    private func toolName(_ tool: DrawTool) -> String {
        switch tool {
        case .pen: return "画笔工具"
        case .eraser: return "橡皮工具"
        case .fill: return "填充工具"
        case .eyedropper: return "取色工具"
        }
    }

    private func loadPets() {
        pets = (try? PetStore.shared.loadAll()) ?? []
    }

    private func loadPetForEditing(_ pet: PetDefinition) {
        let restored = PixelCanvas.from(hexArray: pet.pixels, size: pet.canvasSize)
        vm.canvas = restored
        if let bp = pet.blinkPixels {
            vm.blinkCanvas = PixelCanvas.from(hexArray: bp, size: pet.canvasSize)
        } else {
            vm.blinkCanvas = nil
        }
        vm.activeFrame = .normal
    }

    private func spawnPet() {
        let normalImage = vm.canvas.toNSImage(scale: 8)
        let blinkImage = vm.blinkCanvas?.toNSImage(scale: 8)

        let pet = PetDefinition(
            name: pendingPetName,
            canvasSize: vm.canvas.size,
            pixels: vm.canvas.toHexArray(),
            blinkPixels: vm.blinkCanvas?.toHexArray()
        )

        do {
            try PetStore.shared.save(pet)
            try PetStore.shared.savePNGs(id: pet.id, normal: normalImage, blink: blinkImage)
            loadPets()
            PetHostManager.shared.spawn(pet)
        } catch {
            print("Failed to save pet: \(error)")
        }
    }
}
