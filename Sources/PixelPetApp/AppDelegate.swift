import AppKit
import Sparkle
import PixelPetKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Sparkle updater
    // SUUpdaterController drives the "Check for Updates" menu item.
    // To switch to a Developer ID certificate later, just change the
    // signing identity in build.sh — no code changes needed here.
    private let updaterController: SPUStandardUpdaterController

    override init() {
        // userInitiated: false = check silently in background on launch
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        super.init()
    }

    // MARK: - App lifecycle

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
