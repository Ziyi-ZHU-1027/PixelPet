import SwiftUI
import PixelPetKit

@main
struct PixelPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("PixelPet") {
            EditorView()
                .frame(minWidth: 800, minHeight: 560)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
