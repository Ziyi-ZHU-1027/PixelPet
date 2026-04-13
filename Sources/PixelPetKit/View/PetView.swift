import SwiftUI

public struct PetView: View {
    @ObservedObject public var animator: PetAnimator
    let onSingleTap: () -> Void
    let onDoubleTap: () -> Void

    public init(animator: PetAnimator,
                onSingleTap: @escaping () -> Void,
                onDoubleTap: @escaping () -> Void) {
        self.animator = animator
        self.onSingleTap = onSingleTap
        self.onDoubleTap = onDoubleTap
    }

    public var body: some View {
        let size = animator.panelSize
        ZStack {
            Image(nsImage: animator.currentImage)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
                .offset(y: animator.jumpOffset)

            ForEach(animator.hearts) { heart in
                Text("♥")
                    .font(.system(size: heart.size))
                    .foregroundColor(.pink)
                    .opacity(heart.alpha)
                    .position(x: heart.x, y: heart.y)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: size, height: size)
    }
}
