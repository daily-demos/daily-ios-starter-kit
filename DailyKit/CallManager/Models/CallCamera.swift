import Daily
import AVFoundation

/// A camera being used by the local participant.
public struct CallCamera: Equatable {
    public enum FacingMode: Equatable {
        /// The camera is facing the user.
        case user

        /// The camera is facing away from the user.
        case environment
    }

    /// The mute state of this camera's video.
    public let video: CallMuteState

    /// The facing mode of this camera.
    public let mode: FacingMode

    /// Whether the video of this camera is muted.
    public var isMuted: Bool { video == .muted }

    /// Makes a camera.
    ///
    /// - Parameters:
    ///   - video: the mute state of this camera's video.
    ///   - mode: the facing mode of this camera.
    public init(video: CallMuteState, mode: FacingMode) {
        self.video = video
        self.mode = mode
    }
}

extension CallCamera.FacingMode {
    /// Makes a facing mode from the specified `CameraInputSettings`.
    ///
    /// - Parameter camera: the `CameraInputSettings` from which to make a facing mode.
    public init(_ camera: CameraInputSettings) {
        switch camera.settings.facingMode {
        case .user:
            self = .user
        case .environment:
            self = .environment
        @unknown default:
            fatalError("Unexpected facing mode: \(camera.settings.facingMode).")
        }
    }
}

extension CallCamera {
    /// Makes a camera from the specified `CameraInputSettings`.
    ///
    /// - Parameters:
    ///   - settings: the camera settings.
    ///   - status: the camera authorization status.
    public init(
        _ settings: CameraInputSettings,
        status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    ) {
        self.video = CallMuteState(settings, status: status)
        self.mode = FacingMode(settings)
    }
}
