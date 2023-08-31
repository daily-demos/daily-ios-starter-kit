import Daily
import SwiftUI

/// A wrapper for `VideoView` that exposes the video size via a `@Binding`.
struct DailyVideoView: UIViewRepresentable {
    /// The current size of the video being rendered by this view.
    @Binding private(set) var videoSize: CGSize

    var track: VideoTrack?

    var videoScaleMode: VideoView.VideoScaleMode

    private let videoView = VideoView()
    private let isMirrored: Bool

    init(
        track: VideoTrack? = nil,
        videoScaleMode: VideoView.VideoScaleMode = .fill,
        isMirrored: Bool = false,
        videoSize: Binding<CGSize> = .constant(.zero)
    ) {
        self.track = track
        self.videoScaleMode = videoScaleMode
        self.isMirrored = isMirrored
        self._videoSize = videoSize
    }

    func makeUIView(context: Context) -> VideoView {
        videoView.delegate = context.coordinator
        return videoView
    }

    func updateUIView(_ videoView: VideoView, context: Context) {
        videoView.track = track
        videoView.videoScaleMode = videoScaleMode
        videoView.transform = isMirrored ? CGAffineTransform(scaleX: -1, y: 1) : .identity

        // Hide the view if we do not have a track.
        videoView.isHidden = track == nil
    }
}

extension DailyVideoView {
    final class Coordinator: VideoViewDelegate {
        private let dailyVideoView: DailyVideoView

        init(_ dailyVideoView: DailyVideoView) {
            self.dailyVideoView = dailyVideoView
        }

        func videoView(_ videoView: Daily.VideoView, didChangeVideoSize size: CGSize) {
            // Update the `DailyVideoView.videoSize` binding with the current `size` value.
            dailyVideoView.videoSize = size
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
