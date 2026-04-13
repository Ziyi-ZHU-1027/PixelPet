import AppKit

/// Manages all active desktop pet windows. Single process, multiple NSPanels.
@MainActor
public final class PetHostManager {

    public static let shared = PetHostManager()
    private var controllers: [UUID: PetWindowController] = [:]

    private init() {
        NotificationCenter.default.addObserver(
            forName: .petDidHide, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                if let id = note.object as? UUID {
                    // window.orderOut already called by PetWindowController.hidePet()
                    self?.controllers.removeValue(forKey: id)
                }
            }
        }
        NotificationCenter.default.addObserver(
            forName: .petDidDelete, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor [weak self] in
                if let id = note.object as? UUID {
                    self?.controllers.removeValue(forKey: id)
                }
            }
        }
    }

    /// Hide a pet window and remove its controller.
    public func hide(id: UUID) {
        if let controller = controllers[id] {
            controller.window.orderOut(nil)
            controllers.removeValue(forKey: id)
        }
    }

    public func spawn(_ pet: PetDefinition) {
        guard controllers[pet.id] == nil else {
            controllers[pet.id]?.window.orderFrontRegardless()
            return
        }

        let (normal, blink) = PetStore.shared.loadImages(id: pet.id)
        guard let normal = normal else {
            print("PetHostManager: missing normal.png for \(pet.name)")
            return
        }

        let position: NSPoint
        if let lx = pet.lastPositionX, let ly = pet.lastPositionY {
            position = NSPoint(x: lx, y: ly)
        } else {
            let screen = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
            let panelSize = PetWindowController.panelSize(for: pet.canvasSize)
            position = NSPoint(
                x: screen.midX - panelSize / 2,
                y: screen.midY - panelSize / 2
            )
        }

        let controller = PetWindowController(
            pet: pet,
            normal: normal,
            blink: blink,
            position: position
        )
        controllers[pet.id] = controller
        controller.animator.triggerJump()
    }

    public func restoreAll() {
        let pets = (try? PetStore.shared.loadAll()) ?? []
        for pet in pets where pet.isVisible {
            spawn(pet)
        }
    }

    public func saveAllPositions() {
        for controller in controllers.values {
            controller.savePosition()
        }
    }
}
