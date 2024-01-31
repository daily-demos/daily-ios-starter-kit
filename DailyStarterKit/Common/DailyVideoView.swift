import Daily
import SwiftUI

/// A wrapper for `VideoView` that exposes the video size via a `@Binding`.
struct DailyVideoView: UIViewRepresentable {
    /// The current size of the video being rendered by this view.
    @Binding private(set) var videoSize: CGSize

    private let track: VideoTrack?
    private let videoScaleMode: VideoView.VideoScaleMode

    init(
        track: VideoTrack? = nil,
        videoScaleMode: VideoView.VideoScaleMode = .fill,
        videoSize: Binding<CGSize> = .constant(.zero)
    ) {
        self.track = track
        self.videoScaleMode = videoScaleMode
        self._videoSize = videoSize
    }

    func makeUIView(context: Context) -> VideoView {
        let videoView = VideoView()
        videoView.delegate = context.coordinator
        return videoView
    }

    func updateUIView(_ videoView: VideoView, context: Context) {
        context.coordinator.dailyVideoView = self

        if videoView.track != track {
            videoView.track = track
        }

        if videoView.videoScaleMode != videoScaleMode {
            videoView.videoScaleMode = videoScaleMode
        }
    }
}

extension DailyVideoView {
    final class Coordinator: VideoViewDelegate {
        fileprivate var dailyVideoView: DailyVideoView

        init(_ dailyVideoView: DailyVideoView) {
            self.dailyVideoView = dailyVideoView
        }

        func videoView(_ videoView: VideoView, didChangeVideoSize size: CGSize) {
            // Update the `videoSize` binding with the current `size` value.
            DispatchQueue.main.async {
                self.dailyVideoView.videoSize = size
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#if DEBUG
struct DailyVideoView_Previews: PreviewProvider {
    static var previews: some View {
        DailyVideoView()
    }
}
#endif
