import Foundation
import Combine
import Daily

#if DEBUG
/// A fake implementation of `CallManageable` for previews and testing.
public final class FakeCallManager: CallManageable {
    // MARK: - State

    public var url: URL? { subjects.url.value }
    public var callState: CallState { subjects.callState.value }
    public var camera: CallCamera { subjects.camera.value }
    public var microphone: CallMicrophone { subjects.microphone.value }
    public var participants: CallParticipants { subjects.participants.value }

    // MARK: - Publishers

    public func publisher<T>(for property: CallClientProperty<T>) -> AnyPublisher<T, Never> {
        subjects.publisher(for: property)
    }

    // MARK: - Initialization

    private let subjects: CallClientSubjects
    private var participantsBuilder: CallParticipants.Builder

    /// Makes a fake call manager with reasonable defaults.
    public init(
        url: URL? = nil,
        callState: CallState = .initialized,
        camera: CallCamera = .init(video: .unmuted, mode: .user),
        microphone: CallMicrophone = .init(audio: .muted),
        local: CallParticipant = .defaultLocal,
        visible: [CallParticipant] = []
    ) {
        var participantsBuilder = CallParticipants.Builder(local: local)
        visible.forEach { participantsBuilder.handleJoined($0) }

        self.participantsBuilder = participantsBuilder
        self.subjects = CallClientSubjects(
            url: url,
            callState: callState,
            camera: camera,
            microphone: microphone,
            participants: participantsBuilder.build()
        )
    }

    // MARK: - Actions

    public func toggleCamera(_ camera: CallCamera) {
        switch camera.video {
        case .muted:
            self.subjects.camera.send(CallCamera(video: .unmuted, mode: camera.mode))
        case .unmuted:
            self.subjects.camera.send(CallCamera(video: .muted, mode: camera.mode))
        }
    }

    public func toggleAdaptiveHEVC(_ isAdaptiveHEVCEnabled: Bool) {
        // UI state changes before this method is called, so doing nothing here is the happy path.
    }

    public func toggleMicrophone(_ microphone: CallMicrophone) {
        switch microphone.audio {
        case .muted:
            self.subjects.microphone.send(CallMicrophone(audio: .unmuted))
        case .unmuted:
            self.subjects.microphone.send(CallMicrophone(audio: .muted))
        }
    }

    public func flipCamera(_ camera: CallCamera) {
        switch camera.mode {
        case .user:
            self.subjects.camera.send(CallCamera(video: camera.video, mode: .environment))
        case .environment:
            self.subjects.camera.send(CallCamera(video: camera.video, mode: .user))
        }
    }

    public func setUsername(_ username: String?) {
        var local = participantsBuilder.local
        local.username = username ?? CallParticipant.Constants.defaultUsername
        participantsBuilder.handleUpdated(local)

        subjects.participants.send(participantsBuilder.build())
    }

    public func join(url: URL) {
        subjects.callState.send(.joined)
        subjects.url.send(url)
    }

    public func leave() {
        subjects.callState.send(.left)
    }
}
#endif
