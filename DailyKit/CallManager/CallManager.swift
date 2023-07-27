import Foundation
import Combine
import Daily

/// The live implementation of `CallManageable`.
public final class CallManager: CallManageable {
    /// A singleton instance for use in production code.
    public static let live: CallManager = .init()

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

    private let callClient: CallClient
    private let subjects: CallClientSubjects
    private var participantsBuilder: CallParticipants.Builder

    /// A convenience initializer that creates a default Daily `CallClient`.
    public convenience init() {
        self.init(callClient: CallClient())
    }

    /// Designated initializer.
    ///
    /// - Parameter callClient: the Daily `CallClient` instance to use for this manager.
    required init(callClient: CallClient) {
        self.callClient = callClient
        self.participantsBuilder = CallParticipants.Builder(
            local: callClient.participants.local.asCallParticipant
        )
        self.subjects = CallClientSubjects(
            url: callClient.url,
            callState: callClient.callState,
            camera: CallCamera(callClient.inputs.camera),
            microphone: CallMicrophone(callClient.inputs.microphone),
            participants: participantsBuilder.build()
        )

        callClient.delegate = self

        // Apply the defaults to be used before joining a call.
        applyDefaults()
    }

    private func applyDefaults() {
        // Enable the camera and disable the microphone, so users can see themselves in the join screen and
        // join without their microphone enabled. These values may be overridden by room properties after
        // joining.
        callClient.setInputsEnabled([
            .camera: true,
            .microphone: false
        ])

        callClient.setIsPublishing([
            .camera: true,
            .microphone: true
        ])
    }

    // MARK: - Actions

    public func toggleCamera(_ camera: CallCamera) {
        switch camera.video {
        case .muted:
            callClient.setInputsEnabled([.camera: true])
        case .unmuted:
            callClient.setInputsEnabled([.camera: false])
        }
    }

    public func toggleMicrophone(_ microphone: CallMicrophone) {
        switch microphone.audio {
        case .muted:
            callClient.setInputsEnabled([.microphone: true])
        case .unmuted:
            callClient.setInputsEnabled([.microphone: false])
        }
    }

    public func flipCamera(_ camera: CallCamera) {
        switch camera.mode {
        case .user:
            callClient.updateInputs(.set(camera: .set(settings: .set(facingMode: .set(.environment)))))
        case .environment:
            callClient.updateInputs(.set(camera: .set(settings: .set(facingMode: .set(.user)))))
        }
    }

    public func setUsername(_ username: String?) {
        callClient.set(username: username)
    }

    public func join(url: URL) {
        callClient.join(url: url)
        subjects.url.send(url)

        // TODO: Remove this call or replace with a `CallManager` specific call state type.
        // Send a `joining` value, so the UI will immediately transition to the waiting screen.
        subjects.callState.send(.joining)
    }

    public func leave() {
        callClient.leave()
    }
}

// MARK: - CallClientDelegate

extension CallManager: CallClientDelegate {
    public func callClient(
        _ callClient: CallClient,
        callStateUpdated state: CallState
    ) {
        subjects.callState.send(state)

        // Reapply the defaults after leaving a call.
        if case CallState.left = state {
            applyDefaults()
        }
    }

    public func callClient(
        _ callClient: CallClient,
        error: CallClientError
    ) {
        NSLog("\(error)")
    }

    public func callClient(
        _ callClient: CallClient,
        inputsUpdated inputs: InputSettings
    ) {
        subjects.camera.send(CallCamera(inputs.camera))
        subjects.microphone.send(CallMicrophone(inputs.microphone))
    }

    public func callClient(
        _ callClient: CallClient,
        activeSpeakerChanged activeSpeaker: Participant?
    ) {
        participantsBuilder.activeSpeaker = activeSpeaker?.asCallParticipant
        subjects.participants.send(participantsBuilder.build())
    }

    public func callClient(
        _ callClient: CallClient,
        participantJoined participant: Participant
    ) {
        participantsBuilder.handleJoined(participant.asCallParticipant)
        subjects.participants.send(participantsBuilder.build())
    }

    public func callClient(
        _ callClient: CallClient,
        participantLeft participant: Participant,
        withReason reason: ParticipantLeftReason
    ) {
        participantsBuilder.handleLeft(participant.asCallParticipant)
        subjects.participants.send(participantsBuilder.build())
    }

    public func callClient(
        _ callClient: CallClient,
        participantUpdated participant: Participant
    ) {
        participantsBuilder.handleUpdated(participant.asCallParticipant)
        subjects.participants.send(participantsBuilder.build())
    }
}
