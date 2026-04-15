import SwiftUI

public struct ToolbarPanelView: View {
    @ObservedObject var vm: EditorViewModel

    public init(vm: EditorViewModel) { self.vm = vm }

    public var body: some View {
        VStack(spacing: 8) {
            toolButton(tool: .pen, icon: "pencil")
            toolButton(tool: .eraser, icon: "eraser")
            toolButton(tool: .fill, icon: "paintbucket")
            toolButton(tool: .eyedropper, icon: "eyedropper")

            Divider()
                .frame(width: 36)
                .background(Color.orange.opacity(0.3))
                .padding(.vertical, 2)

            Button {
                vm.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(vm.canUndo ? Color(hex: "#F97316")! : .gray)
            }
            .buttonStyle(ToolButtonStyle(isActive: false))
            .disabled(!vm.canUndo)
            .keyboardShortcut("z", modifiers: .command)

            Button {
                vm.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(vm.canRedo ? Color(hex: "#F97316")! : .gray)
            }
            .buttonStyle(ToolButtonStyle(isActive: false))
            .disabled(!vm.canRedo)
            .keyboardShortcut("z", modifiers: [.command, .shift])

            Spacer()
        }
        .padding(.vertical, 14)
        .frame(width: 60)
        .background(Color(hex: "#FDECD3")!)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(Color(hex: "#F97316")!),
            alignment: .trailing
        )
    }

    @ViewBuilder
    private func toolButton(tool: DrawTool, icon: String) -> some View {
        Button {
            vm.currentTool = tool
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(vm.currentTool == tool ? .white : Color(hex: "#F97316")!)
        }
        .buttonStyle(ToolButtonStyle(isActive: vm.currentTool == tool))
    }
}

private struct ToolButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 40, height: 40)
            .background(isActive ? Color(hex: "#F97316")! : Color(hex: "#FFF7ED")!)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#F97316")!, lineWidth: 2.5)
            )
            .shadow(color: Color(hex: "#9A3412")!.opacity(0.5), radius: 0, x: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
