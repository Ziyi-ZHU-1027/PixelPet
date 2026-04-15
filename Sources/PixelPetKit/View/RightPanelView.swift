import SwiftUI

// MARK: - Perler color data

public struct PerlerColor: Identifiable {
    public let id: String   // e.g. "F2"
    public let hex: String
}

public let perlerSeries: [(letter: String, name: String, colors: [PerlerColor])] = [
    ("A", "黄橙", [
        PerlerColor(id:"A1",hex:"#FAF5CD"),PerlerColor(id:"A2",hex:"#FCFED6"),PerlerColor(id:"A3",hex:"#FCFF92"),
        PerlerColor(id:"A4",hex:"#F7EC5C"),PerlerColor(id:"A5",hex:"#FFE44B"),PerlerColor(id:"A6",hex:"#FDA951"),
        PerlerColor(id:"A7",hex:"#FA8C4F"),PerlerColor(id:"A8",hex:"#F9E045"),PerlerColor(id:"A9",hex:"#F99C5F"),
        PerlerColor(id:"A10",hex:"#F47E36"),PerlerColor(id:"A11",hex:"#FEDB99"),PerlerColor(id:"A12",hex:"#FDA276"),
        PerlerColor(id:"A13",hex:"#FEC667"),PerlerColor(id:"A14",hex:"#F85842"),PerlerColor(id:"A15",hex:"#FBF65E"),
        PerlerColor(id:"A16",hex:"#FEFF97"),PerlerColor(id:"A17",hex:"#FDE173"),PerlerColor(id:"A18",hex:"#FCBF80"),
        PerlerColor(id:"A19",hex:"#FD7E77"),PerlerColor(id:"A20",hex:"#F9D66E"),PerlerColor(id:"A21",hex:"#FAE393"),
        PerlerColor(id:"A22",hex:"#EDF878"),PerlerColor(id:"A23",hex:"#E1C9BD"),PerlerColor(id:"A24",hex:"#F3F6A9"),
        PerlerColor(id:"A25",hex:"#FFD785"),PerlerColor(id:"A26",hex:"#FEC832"),
    ]),
    ("B", "绿", [
        PerlerColor(id:"B1",hex:"#DFF139"),PerlerColor(id:"B2",hex:"#64F343"),PerlerColor(id:"B3",hex:"#9FF685"),
        PerlerColor(id:"B4",hex:"#5FDF34"),PerlerColor(id:"B5",hex:"#39E158"),PerlerColor(id:"B6",hex:"#64D0A4"),
        PerlerColor(id:"B7",hex:"#3FAE7C"),PerlerColor(id:"B8",hex:"#1D9E54"),PerlerColor(id:"B9",hex:"#2A5037"),
        PerlerColor(id:"B10",hex:"#9AD1BA"),PerlerColor(id:"B11",hex:"#627032"),PerlerColor(id:"B12",hex:"#1A6E3D"),
        PerlerColor(id:"B13",hex:"#C8E87D"),PerlerColor(id:"B14",hex:"#ACE84C"),PerlerColor(id:"B15",hex:"#305335"),
        PerlerColor(id:"B16",hex:"#C0ED9C"),PerlerColor(id:"B17",hex:"#9EB33E"),PerlerColor(id:"B18",hex:"#E6ED4F"),
        PerlerColor(id:"B19",hex:"#26B78E"),PerlerColor(id:"B20",hex:"#CAEDCF"),PerlerColor(id:"B21",hex:"#176268"),
        PerlerColor(id:"B22",hex:"#0A4241"),PerlerColor(id:"B23",hex:"#343B1A"),PerlerColor(id:"B24",hex:"#E8FAA6"),
        PerlerColor(id:"B25",hex:"#4E846D"),PerlerColor(id:"B26",hex:"#907C35"),PerlerColor(id:"B27",hex:"#D0E0AF"),
        PerlerColor(id:"B28",hex:"#9EE5BB"),PerlerColor(id:"B29",hex:"#C6DF5F"),PerlerColor(id:"B30",hex:"#E3FBB1"),
        PerlerColor(id:"B31",hex:"#B2E694"),PerlerColor(id:"B32",hex:"#92AD60"),
    ]),
    ("C", "蓝", [
        PerlerColor(id:"C1",hex:"#FFFEE4"),PerlerColor(id:"C2",hex:"#ABF8FE"),PerlerColor(id:"C3",hex:"#9EE0F8"),
        PerlerColor(id:"C4",hex:"#44CDFB"),PerlerColor(id:"C5",hex:"#06ABE3"),PerlerColor(id:"C6",hex:"#54A7E9"),
        PerlerColor(id:"C7",hex:"#3977CC"),PerlerColor(id:"C8",hex:"#0F52BD"),PerlerColor(id:"C9",hex:"#3349C3"),
        PerlerColor(id:"C10",hex:"#3DBBE3"),PerlerColor(id:"C11",hex:"#2ADED3"),PerlerColor(id:"C12",hex:"#1E334E"),
        PerlerColor(id:"C13",hex:"#CDE7FE"),PerlerColor(id:"C14",hex:"#D6FDFC"),PerlerColor(id:"C15",hex:"#21C5C4"),
        PerlerColor(id:"C16",hex:"#1858A2"),PerlerColor(id:"C17",hex:"#02D1F3"),PerlerColor(id:"C18",hex:"#213244"),
        PerlerColor(id:"C19",hex:"#188690"),PerlerColor(id:"C20",hex:"#1A70A9"),PerlerColor(id:"C21",hex:"#BEDDFC"),
        PerlerColor(id:"C22",hex:"#6BB1BB"),PerlerColor(id:"C23",hex:"#C8E2F9"),PerlerColor(id:"C24",hex:"#7EC5F9"),
        PerlerColor(id:"C25",hex:"#A9E8E0"),PerlerColor(id:"C26",hex:"#42ADD1"),PerlerColor(id:"C27",hex:"#D0DEEF"),
        PerlerColor(id:"C28",hex:"#BDCEED"),PerlerColor(id:"C29",hex:"#364A89"),
    ]),
    ("D", "紫", [
        PerlerColor(id:"D1",hex:"#ACB7EF"),PerlerColor(id:"D2",hex:"#868DD3"),PerlerColor(id:"D3",hex:"#3653AF"),
        PerlerColor(id:"D4",hex:"#162C7E"),PerlerColor(id:"D5",hex:"#B34EC6"),PerlerColor(id:"D6",hex:"#B37BDC"),
        PerlerColor(id:"D7",hex:"#8758A9"),PerlerColor(id:"D8",hex:"#E3D2FE"),PerlerColor(id:"D9",hex:"#D6BAF5"),
        PerlerColor(id:"D10",hex:"#301A49"),PerlerColor(id:"D11",hex:"#BCBAE2"),PerlerColor(id:"D12",hex:"#DC99CE"),
        PerlerColor(id:"D13",hex:"#B5038F"),PerlerColor(id:"D14",hex:"#882893"),PerlerColor(id:"D15",hex:"#2F1E8E"),
        PerlerColor(id:"D16",hex:"#E2E4F0"),PerlerColor(id:"D17",hex:"#C7D3F9"),PerlerColor(id:"D18",hex:"#9A64B8"),
        PerlerColor(id:"D19",hex:"#D8C2D9"),PerlerColor(id:"D20",hex:"#9C34AD"),PerlerColor(id:"D21",hex:"#940595"),
        PerlerColor(id:"D22",hex:"#383995"),PerlerColor(id:"D23",hex:"#FADBF8"),PerlerColor(id:"D24",hex:"#768AE1"),
        PerlerColor(id:"D25",hex:"#4950C2"),PerlerColor(id:"D26",hex:"#D6C6EB"),
    ]),
    ("E", "粉红", [
        PerlerColor(id:"E1",hex:"#F6D4CB"),PerlerColor(id:"E2",hex:"#CC1DDD"),PerlerColor(id:"E3",hex:"#F6BDE8"),
        PerlerColor(id:"E4",hex:"#E9639E"),PerlerColor(id:"E5",hex:"#F1559F"),PerlerColor(id:"E6",hex:"#EC4072"),
        PerlerColor(id:"E7",hex:"#C63674"),PerlerColor(id:"E8",hex:"#FDDBE9"),PerlerColor(id:"E9",hex:"#E575C7"),
        PerlerColor(id:"E10",hex:"#D33997"),PerlerColor(id:"E11",hex:"#F7DAD4"),PerlerColor(id:"E12",hex:"#F893BF"),
        PerlerColor(id:"E13",hex:"#B5026A"),PerlerColor(id:"E14",hex:"#FAD4BF"),PerlerColor(id:"E15",hex:"#F5C9CA"),
        PerlerColor(id:"E16",hex:"#FBF4EC"),PerlerColor(id:"E17",hex:"#F7E3EC"),PerlerColor(id:"E18",hex:"#FBCBDB"),
        PerlerColor(id:"E19",hex:"#F6BBD1"),PerlerColor(id:"E20",hex:"#D7C6CE"),PerlerColor(id:"E21",hex:"#C09DA4"),
        PerlerColor(id:"E22",hex:"#B58B9F"),PerlerColor(id:"E23",hex:"#937D8A"),PerlerColor(id:"E24",hex:"#DEBEE5"),
    ]),
    ("F", "红", [
        PerlerColor(id:"F1",hex:"#FF9280"),PerlerColor(id:"F2",hex:"#F73D48"),PerlerColor(id:"F3",hex:"#EF4D3E"),
        PerlerColor(id:"F4",hex:"#F92B40"),PerlerColor(id:"F5",hex:"#E30328"),PerlerColor(id:"F6",hex:"#913635"),
        PerlerColor(id:"F7",hex:"#911932"),PerlerColor(id:"F8",hex:"#BB0126"),PerlerColor(id:"F9",hex:"#E0677A"),
        PerlerColor(id:"F10",hex:"#874628"),PerlerColor(id:"F11",hex:"#6F321D"),PerlerColor(id:"F12",hex:"#F8516D"),
        PerlerColor(id:"F13",hex:"#F45C45"),PerlerColor(id:"F14",hex:"#FCADB2"),PerlerColor(id:"F15",hex:"#D50527"),
        PerlerColor(id:"F16",hex:"#F8C0A9"),PerlerColor(id:"F17",hex:"#E89B7D"),PerlerColor(id:"F18",hex:"#D07E4A"),
        PerlerColor(id:"F19",hex:"#BE454A"),PerlerColor(id:"F20",hex:"#C69495"),PerlerColor(id:"F21",hex:"#F2BBC6"),
        PerlerColor(id:"F22",hex:"#F7C3D0"),PerlerColor(id:"F23",hex:"#EC806D"),PerlerColor(id:"F24",hex:"#E09DAF"),
        PerlerColor(id:"F25",hex:"#E84854"),
    ]),
    ("G", "棕肤", [
        PerlerColor(id:"G1",hex:"#FFE4D3"),PerlerColor(id:"G2",hex:"#FCC6AC"),PerlerColor(id:"G3",hex:"#F1C4A5"),
        PerlerColor(id:"G4",hex:"#DCB387"),PerlerColor(id:"G5",hex:"#E7B34E"),PerlerColor(id:"G6",hex:"#F3A014"),
        PerlerColor(id:"G7",hex:"#98503A"),PerlerColor(id:"G8",hex:"#4B2B1C"),PerlerColor(id:"G9",hex:"#F4B685"),
        PerlerColor(id:"G10",hex:"#DA8C42"),PerlerColor(id:"G11",hex:"#DAC898"),PerlerColor(id:"G12",hex:"#FEC993"),
        PerlerColor(id:"G13",hex:"#B2714B"),PerlerColor(id:"G14",hex:"#8B684C"),PerlerColor(id:"G15",hex:"#F6F8E3"),
        PerlerColor(id:"G16",hex:"#F2D8C1"),PerlerColor(id:"G17",hex:"#79544E"),PerlerColor(id:"G18",hex:"#FFE4D6"),
        PerlerColor(id:"G19",hex:"#DD7D41"),PerlerColor(id:"G20",hex:"#A5452F"),PerlerColor(id:"G21",hex:"#B38561"),
    ]),
    ("H", "黑白灰", [
        PerlerColor(id:"H1",hex:"#FDFBFF"),PerlerColor(id:"H2",hex:"#FEFFFF"),
        PerlerColor(id:"H3",hex:"#B4B4B4"),PerlerColor(id:"H4",hex:"#878787"),PerlerColor(id:"H5",hex:"#464648"),
        PerlerColor(id:"H6",hex:"#2C2C2C"),PerlerColor(id:"H7",hex:"#010101"),PerlerColor(id:"H8",hex:"#E7D6DC"),
        PerlerColor(id:"H9",hex:"#EFEDEE"),PerlerColor(id:"H10",hex:"#ECEAEB"),PerlerColor(id:"H11",hex:"#CDCDCD"),
        PerlerColor(id:"H12",hex:"#FDF6EE"),PerlerColor(id:"H13",hex:"#F4EFD1"),PerlerColor(id:"H14",hex:"#CED7D4"),
        PerlerColor(id:"H15",hex:"#98A6A6"),PerlerColor(id:"H16",hex:"#1B1213"),PerlerColor(id:"H17",hex:"#F0EEEF"),
        PerlerColor(id:"H18",hex:"#FCFFF8"),PerlerColor(id:"H19",hex:"#F2EEE5"),PerlerColor(id:"H20",hex:"#96A09F"),
        PerlerColor(id:"H21",hex:"#F8FBE6"),PerlerColor(id:"H22",hex:"#CACADA"),PerlerColor(id:"H23",hex:"#9B9C94"),
    ]),
    ("M", "灰棕", [
        PerlerColor(id:"M1",hex:"#BBC6B6"),PerlerColor(id:"M2",hex:"#909994"),PerlerColor(id:"M3",hex:"#697E80"),
        PerlerColor(id:"M4",hex:"#E0D4BC"),PerlerColor(id:"M5",hex:"#D0CBAE"),PerlerColor(id:"M6",hex:"#B0AA86"),
        PerlerColor(id:"M7",hex:"#B0A796"),PerlerColor(id:"M8",hex:"#AE8082"),PerlerColor(id:"M9",hex:"#A88764"),
        PerlerColor(id:"M10",hex:"#C6B2BB"),PerlerColor(id:"M11",hex:"#9D7693"),PerlerColor(id:"M12",hex:"#644B51"),
        PerlerColor(id:"M13",hex:"#C79266"),PerlerColor(id:"M14",hex:"#C37463"),PerlerColor(id:"M15",hex:"#747D7A"),
    ]),
]

// MARK: - RightPanelView

public struct RightPanelView: View {
    @ObservedObject var vm: EditorViewModel
    @Binding var pets: [PetDefinition]
    let onSelectPet: (PetDefinition) -> Void
    let onToggleVisible: (PetDefinition) -> Void

    // Normal palette
    private let normalPalette: [String] = [
        "#E63946", "#F97316", "#FFD166", "#06D6A0", "#118AB2",
        "#7C6AF7", "#FF6B9D", "#F4A261", "#2A2A2A", "#FFFFFF",
        "#AAAAAA", "#A8DADC", "#457B9D",
    ]

    // Which perler series is expanded
    @State private var expandedSeries: String? = nil

    public init(vm: EditorViewModel,
                pets: Binding<[PetDefinition]>,
                onSelectPet: @escaping (PetDefinition) -> Void,
                onToggleVisible: @escaping (PetDefinition) -> Void) {
        self.vm = vm
        self._pets = pets
        self.onSelectPet = onSelectPet
        self.onToggleVisible = onToggleVisible
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

    // MARK: - Size selector

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

    // MARK: - Current color + system color picker

    @State private var pickerBinding: Color = Color(hex: "#E63946") ?? .red

    private var currentColorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("当前颜色")
            HStack(spacing: 8) {
                // Color swatch
                RoundedRectangle(cornerRadius: 10)
                    .fill(swatchColor(vm.currentHex))
                    .frame(width: 34, height: 34)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#9A3412")!, lineWidth: 3))
                    .shadow(color: Color(hex: "#9A3412")!.opacity(0.5), radius: 0, x: 3, y: 3)

                // Label
                VStack(alignment: .leading, spacing: 1) {
                    if vm.paletteMode == .perler,
                       let pc = perlerCodeForHex(vm.currentHex) {
                        Text(pc)
                            .font(.custom("VT323", size: 20))
                            .foregroundColor(Color(hex: "#1A1A2E")!)
                            .fontWeight(.bold)
                        Text(vm.currentHex.uppercased())
                            .font(.custom("VT323", size: 13))
                            .foregroundColor(Color(hex: "#9A3412")!).opacity(0.7)
                    } else {
                        Text(vm.currentHex.uppercased())
                            .font(.custom("VT323", size: 20))
                            .foregroundColor(Color(hex: "#1A1A2E")!)
                            .fontWeight(.bold)
                    }
                }

                Spacer()

                // System color picker — opens Apple's native color panel
                ColorPicker("", selection: $pickerBinding, supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 34, height: 34)
                    .onChange(of: pickerBinding) { newColor in
                        if let hex = newColor.toHex() {
                            vm.currentHex = hex
                            vm.recordHistory(hex)
                        }
                    }
            }
        }
        .onAppear {
            // Sync picker to current color on appear
            if let c = Color(hex: vm.currentHex) { pickerBinding = c }
        }
        .onChange(of: vm.currentHex) { newHex in
            // Keep picker in sync when color changes from palette
            if let c = Color(hex: newHex) { pickerBinding = c }
        }
    }

    // MARK: - Palette section

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("调色盘")

            // History row
            if !vm.colorHistory.isEmpty {
                historyRow
            }

            // Mode tabs
            HStack(spacing: 4) {
                modeTab("普通色", mode: .normal)
                modeTab("拼豆色", mode: .perler)
            }

            // Content
            if vm.paletteMode == .normal {
                normalPaletteView
            } else {
                perlerPaletteView
            }
        }
    }

    private var historyRow: some View {
        // 面板可用宽度 = 210 - 14*2 = 182px
        // 8格: 每格 20px + 间距 3px × 7 = 181px，刚好放下
        let columns = Array(repeating: GridItem(.fixed(20), spacing: 3), count: 8)
        return VStack(alignment: .leading, spacing: 4) {
            Text("最近用过")
                .font(.custom("VT323", size: 15))
                .foregroundColor(Color(hex: "#9A3412")!).opacity(0.6)
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(vm.colorHistory, id: \.self) { hex in
                    Button {
                        vm.currentHex = hex
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(swatchColor(hex))
                            .frame(width: 20, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(vm.currentHex == hex ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.1),
                                            lineWidth: vm.currentHex == hex ? 2.5 : 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(hex.uppercased())
                }
                // Empty slots
                ForEach(0..<(8 - vm.colorHistory.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color(hex: "#9A3412")!.opacity(0.2),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                        .frame(width: 20, height: 20)
                }
            }
        }
    }

    @ViewBuilder
    private func modeTab(_ label: String, mode: EditorViewModel.PaletteMode) -> some View {
        let isActive = vm.paletteMode == mode
        Button(label) { vm.paletteMode = mode }
            .font(.custom("Press Start 2P", size: 7))
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
            .foregroundColor(isActive ? .white : Color(hex: "#F97316")!)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#F97316")!, lineWidth: 2))
            .shadow(color: isActive ? Color(hex: "#9A3412")!.opacity(0.4) : .clear, radius: 0, x: 2, y: 2)
    }

    // MARK: - Normal palette

    private var normalPaletteView: some View {
        VStack(alignment: .leading, spacing: 6) {
            let columns = Array(repeating: GridItem(.fixed(28), spacing: 5), count: 5)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(normalPalette, id: \.self) { hex in
                    normalSwatch(hex: hex)
                }
                // Transparent
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
            }
        }
    }

    @ViewBuilder
    private func normalSwatch(hex: String) -> some View {
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
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.1), value: isSelected)
    }

    // MARK: - Perler palette

    private var perlerPaletteView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(perlerSeries, id: \.letter) { series in
                perlerSeriesRow(series)
            }
            // Transparent
            HStack(spacing: 6) {
                Button {
                    vm.currentHex = "transparent"
                } label: {
                    TransparentSwatchView()
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(vm.currentHex == "transparent"
                                        ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                        lineWidth: vm.currentHex == "transparent" ? 2.5 : 1.5)
                        )
                }
                .buttonStyle(.plain)
                Text("透明")
                    .font(.custom("VT323", size: 15))
                    .foregroundColor(Color(hex: "#9A3412")!)
            }
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private func perlerSeriesRow(_ series: (letter: String, name: String, colors: [PerlerColor])) -> some View {
        let isOpen = expandedSeries == series.letter
        VStack(alignment: .leading, spacing: 0) {
            // Header row: letter button + preview dots
            Button {
                withAnimation(.easeOut(duration: 0.15)) {
                    expandedSeries = isOpen ? nil : series.letter
                }
            } label: {
                HStack(spacing: 6) {
                    // Letter badge
                    Text(series.letter)
                        .font(.custom("Press Start 2P", size: 8))
                        .frame(width: 26, height: 26)
                        .background(isOpen ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
                        .foregroundColor(isOpen ? .white : Color(hex: "#F97316")!)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color(hex: "#F97316")!, lineWidth: 2))
                        .shadow(color: Color(hex: "#9A3412")!.opacity(0.3), radius: 0, x: 2, y: 2)

                    // Preview: first 4 colors
                    HStack(spacing: 3) {
                        ForEach(series.colors.prefix(4)) { pc in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: pc.hex) ?? .clear)
                                .frame(width: 14, height: 14)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.1), lineWidth: 1))
                        }
                        if series.colors.count > 4 {
                            Text("+\(series.colors.count - 4)")
                                .font(.custom("VT323", size: 13))
                                .foregroundColor(Color(hex: "#9A3412")!).opacity(0.5)
                        }
                    }

                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)

            // Expanded color grid
            if isOpen {
                FlowLayout(spacing: 4) {
                    ForEach(series.colors) { pc in
                        perlerSwatch(pc)
                    }
                }
                .padding(.leading, 8)
                .padding(.top, 4)
                .padding(.bottom, 6)
                .overlay(
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Color(hex: "#F97316")!.opacity(0.3)),
                    alignment: .leading
                )
            }
        }
    }

    @ViewBuilder
    private func perlerSwatch(_ pc: PerlerColor) -> some View {
        let isSelected = vm.currentHex == pc.hex
        Button {
            vm.currentHex = pc.hex
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: pc.hex) ?? .clear)
                .frame(width: 22, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected ? Color(hex: "#1A1A2E")! : Color.black.opacity(0.12),
                                lineWidth: isSelected ? 2.5 : 1.5)
                )
                .shadow(color: .black.opacity(0.12), radius: 0, x: 1, y: 1)
                .scaleEffect(isSelected ? 1.12 : 1.0)
                .help(pc.id)  // tooltip on hover
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.1), value: isSelected)
    }

    // MARK: - Pet list

    private var petListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("我的宠物")
            if pets.isEmpty {
                Text("还没有宠物，快去画一个！")
                    .font(.custom("VT323", size: 16))
                    .foregroundColor(.secondary)
            } else {
                ForEach(pets) { pet in
                    PetListRow(
                        pet: pet,
                        onTap: { onSelectPet(pet) },
                        onToggleVisible: { onToggleVisible(pet) }
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.custom("VT323", size: 20))
            .fontWeight(.bold)
            .foregroundColor(Color(hex: "#9A3412")!)
    }

    private func swatchColor(_ hex: String) -> Color {
        if hex == "transparent" { return .clear }
        return Color(hex: hex) ?? .clear
    }

    private func perlerCodeForHex(_ hex: String) -> String? {
        for series in perlerSeries {
            if let match = series.colors.first(where: { $0.hex.uppercased() == hex.uppercased() }) {
                return match.id
            }
        }
        return nil
    }
}

// MARK: - FlowLayout (wrapping HStack)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 180
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > maxWidth && x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            rowH = max(rowH, s.height)
            x += s.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            rowH = max(rowH, s.height)
            x += s.width + spacing
        }
    }
}

// MARK: - Sub-views

private struct PetListRow: View {
    let pet: PetDefinition
    let onTap: () -> Void
    let onToggleVisible: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 24, height: 24)
                    Text(pet.name)
                        .font(.custom("VT323", size: 20))
                        .foregroundColor(Color(hex: "#1A1A2E")!)
                    Spacer()
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color(hex: "#FFF7ED")!)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))
                .shadow(color: Color(hex: "#9A3412")!.opacity(0.4), radius: 0, x: 2, y: 2)
            }
            .buttonStyle(.plain)

            Button(action: onToggleVisible) {
                ZStack {
                    Circle()
                        .fill(pet.isVisible ? Color(hex: "#06D6A0")! : Color(hex: "#CCCCCC")!)
                        .frame(width: 22, height: 22)
                        .shadow(color: pet.isVisible ? Color(hex: "#06D6A0")!.opacity(0.5) : .clear, radius: 4)
                    Image(systemName: pet.isVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .help(pet.isVisible ? "点击隐藏宠物" : "点击召唤宠物到桌面")
        }
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
    var onPick: (String) -> Void
    @State private var pickerColor: Color = Color(hex: "#F97316") ?? .orange

    var body: some View {
        ColorPicker("", selection: $pickerColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 28, height: 28)
            .onChange(of: pickerColor) { newColor in
                if let hex = newColor.toHex() {
                    selectedHex = hex
                    onPick(hex)
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
