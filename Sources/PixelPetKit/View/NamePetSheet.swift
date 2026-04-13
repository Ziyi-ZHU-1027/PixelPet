import SwiftUI

public struct NamePetSheet: View {
    @Binding var name: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    public init(name: Binding<String>,
                onConfirm: @escaping () -> Void,
                onCancel: @escaping () -> Void) {
        self._name = name
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text("给你的宠物取个名字")
                .font(.custom("Press Start 2P", size: 10))
                .foregroundColor(Color(hex: "#F97316")!)
                .multilineTextAlignment(.center)

            TextField("未命名宠物", text: $name)
                .font(.custom("VT323", size: 22))
                .textFieldStyle(.roundedBorder)
                .onSubmit { if !name.isEmpty { onConfirm() } }

            HStack(spacing: 12) {
                Button("取消", action: onCancel)
                    .font(.custom("Press Start 2P", size: 8))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color(hex: "#FFF7ED")!)
                    .foregroundColor(Color(hex: "#F97316")!)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#F97316")!, lineWidth: 2.5))

                Button("做成桌宠 ▶") {
                    if !name.isEmpty { onConfirm() }
                }
                .font(.custom("Press Start 2P", size: 8))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(name.isEmpty ? Color.gray : Color(hex: "#2563EB")!)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}
