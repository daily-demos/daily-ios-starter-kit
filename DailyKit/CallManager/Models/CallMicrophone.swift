import Daily
import AVFoundation

/// A microphone being used by the local participant.
public struct CallMicrophone: Equatable {
    /// The mute state of this microphone's audio.
    public let audio: CallMuteState

    /// Whether the audio of this microphone is muted.
    public var isMuted: Bool { audio == .muted }

    /// Makes a microphone.
    ///
    /// - Parameter audio: the mute state of this microphone's audio.
    public init(audio: CallMuteState) {
        self.audio = audio
    }
}

extension CallMicrophone {
    /// Makes a microphone from the specified `MicrophoneInputSettings`.
    ///
    /// - Parameters:
    ///   - settings: the microphone settings.
    ///   - status: the microphone authorization status.
    public init(
        _ settings: MicrophoneInputSettings,
        status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    ) {
        self.audio = CallMuteState(settings, status: status)
    }
}
