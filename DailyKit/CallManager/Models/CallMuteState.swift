import Daily
import AVFoundation

/// The mute state of a camera or microphone.
public enum CallMuteState: Equatable {
    /// The media is muted.
    case muted

    /// The media is not muted and playable.
    case unmuted
}

extension CallMuteState {
    /// Makes a mute state from the specified `CameraInputSettings`.
    ///
    /// - Parameters:
    ///   - settings: the camera settings.
    ///   - status: the camera authorization status.
    init(
        _ settings: CameraInputSettings,
        status: AVAuthorizationStatus
    ) {
        switch (settings.isEnabled, status) {
        case (true, .authorized):
            self = .unmuted

        case (_, _):
            self = .muted
        }
    }

    /// Makes a mute state from the specified `MicrophoneInputSettings`.
    ///
    /// - Parameters:
    ///   - settings: the microphone settings.
    ///   - status: the microphone authorization status.
    init(
        _ settings: MicrophoneInputSettings,
        status: AVAuthorizationStatus
    ) {
        switch (settings.isEnabled, status) {
        case (true, .authorized):
            self = .unmuted

        case (_, _):
            self = .muted
        }
    }
}
