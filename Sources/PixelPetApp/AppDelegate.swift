import AppKit
import PixelPetKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            PetHostManager.shared.restoreAll()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in
            PetHostManager.shared.saveAllPositions()
        }
    }
}
