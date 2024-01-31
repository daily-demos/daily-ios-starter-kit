import Daily
import SwiftUI

/// A wrapper for `CameraPreviewView` that exposes the video size via a `@Binding`.
struct DailyCameraPreviewView: UIViewRepresentable {
    /// The current size of the video being rendered by this view.
    @Binding private(set) var videoSize: CGSize

    init(videoSize: Binding<CGSize> = .constant(.zero)) {
        self._videoSize = videoSize
    }

    func makeUIView(context: Context) -> CameraPreviewView {
        let cameraPreviewView = CameraPreviewView.preferred
        cameraPreviewView.delegate = context.coordinator
        return cameraPreviewView
    }

    func updateUIView(_ cameraPreviewView: CameraPreviewView, context: Context) {
        context.coordinator.dailyCameraPreviewView = self
    }
}

extension DailyCameraPreviewView {
    final class Coordinator: CameraPreviewViewDelegate {
        fileprivate var dailyCameraPreviewView: DailyCameraPreviewView

        init(_ dailyCameraPreviewView: DailyCameraPreviewView) {
            self.dailyCameraPreviewView = dailyCameraPreviewView
        }

        func cameraPreviewView(_ cameraPreviewView: CameraPreviewView, didChangeVideoSize size: CGSize) {
            // Update the `videoSize` binding with the current `size` value.
            DispatchQueue.main.async {
                self.dailyCameraPreviewView.videoSize = size
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct DailyCameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        DailyCameraPreviewView()
    }
}
#endif
