import Daily

/// A participant in a call.
public struct CallParticipant: Hashable, Identifiable {
    enum Constants {
        /// The default username to use if a participant has not specified their own username.
        static let defaultUsername: String = "Guest"
    }

    /// The identifier of this participant.
    public let id: AnyHashable

    /// The username of this participant.
    ///
    /// - Note: This value should only be mutated in the `CallManager`.
    public internal(set) var username: String

    /// Whether this is the local participant.
    public let isLocal: Bool

    /// Whether this participant has audio available.
    public let hasAudio: Bool

    /// Whether this participant has video available.
    public let hasVideo: Bool

    /// Whether the `videoTrack` of this participant is screen share content.
    public let isSharingScreen: Bool

    /// The current video track for this participant.
    ///
    /// This track can be set on a ``DailyVideoView`` to render video for this participant.
    public let videoTrack: VideoTrack?

    /// The video scale mode to use for this participant.
    ///
    /// Video for the local participant and screen share content uses `fit` to ensure the full frame is
    /// visible. Remote participants who are not screen sharing will use `fill`, which will result in some
    /// of their video frame being cropped to avoid letter or pillar boxing.
    public var videoScaleMode: VideoView.VideoScaleMode { (isSharingScreen || isLocal) ? .fit : .fill }
}

extension CallParticipant {
    /// Makes a call participant from the specified `Participant`.
    ///
    /// - Parameter participant: the `Participant` from which to make a `CallParticpant`.
    init(_ participant: Participant) {
        // Only use the screen track if it is `playable`.
        let screenTrack = participant.media.flatMap { media in
            media.screenVideo.state == .playable ? media.screenVideo.track : nil
        }

        // Only use the camera track if it is `playable`.
        let cameraTrack = participant.media.flatMap { media in
            media.camera.state == .playable ? media.camera.track : nil
        }

        // Prefer screen video when available.
        let videoTrack = screenTrack ?? cameraTrack

        self.id = participant.id
        self.username = participant.info.username ?? Constants.defaultUsername
        self.isLocal = participant.info.isLocal

        // Only indicate this participant has audio if the `microphone` is `playable`.
        self.hasAudio = participant.media?.microphone.state == .playable

        self.videoTrack = videoTrack
        self.hasVideo = videoTrack != nil
        self.isSharingScreen = screenTrack != nil
    }
}

extension Participant {
    /// A copy of this participant as a `CallParticipant`.
    var asCallParticipant: CallParticipant { CallParticipant(self) }
}

#if DEBUG
extension CallParticipant {
    public static let defaultLocal = CallParticipant(isLocal: true)
}

extension CallParticipant {
    /// Makes a `CallParticipant` with reasonable defaults.
    public init(
        id: AnyHashable = AnyHashable(UUID().uuidString),
        username: String? = nil,
        isLocal: Bool = false,
        hasAudio: Bool = false,
        hasVideo: Bool = true,
        isSharingScreen: Bool = false
    ) {
        self.id = id
        self.username = username ?? Constants.defaultUsername
        self.isLocal = isLocal
        self.hasAudio = hasAudio
        self.videoTrack = nil
        self.hasVideo = hasVideo
        self.isSharingScreen = isSharingScreen
    }
}

extension Array where Element == CallParticipant {
    /// Makes the specified number of participants.
    ///
    /// - Parameters:
    ///   - count: the number of participants to make.
    ///   - hasVideo: whether the participants should have video.
    ///   - hasAudio: whether the participants should have audio.
    /// - Returns: an array of participants with the specified properties.
    static func makeParticipants(
        count: Int,
        hasVideo: Bool = false,
        hasAudio: Bool = false
    ) -> [CallParticipant] {
        (0 ... count).map { _ in CallParticipant(isLocal: false, hasAudio: hasAudio, hasVideo: hasVideo) }
    }
}
#endif
