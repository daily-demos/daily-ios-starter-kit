import AVFoundation
import Combine
import Daily
import Foundation
import UIKit

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
    private let notificationCenter: NotificationCenter = .default

    /// A convenience initializer that creates a default Daily `CallClient`.
    public convenience init() {
        self.init(callClient: CallClient())
    }

    /// Designated initializer.
    ///
    /// - Parameter callClient: the Daily `CallClient` instance to use for this manager.
    required init(callClient: CallClient) {
        self.callClient = callClient
        self.participantsBuilder = CallParticipants.Builder(callClient)
        self.subjects = CallClientSubjects(
            url: callClient.url,
            callState: callClient.callState,
            camera: CallCamera(callClient.inputs.camera),
            microphone: CallMicrophone(callClient.inputs.microphone),
            participants: participantsBuilder.build()
        )

        callClient.delegate = self

        // Apply the defaults to be used before joining a call.
        Task { await applyDefaults() }

        // Set up observers to manage video publishing when entering the background.
        setupNotificationObservers()
    }

    private func applyDefaults() async {
        // Do not enable the camera unless it's already authorized, so we can refresh the input after
        // requesting authorization.
        let isCameraEnabled = await isAuthorized(for: .video)

        // Enable the camera and disable the microphone, so users can see themselves in the join screen and
        // join without their microphone enabled. These values may be overridden by room properties after
        // joining.
        callClient.setInputsEnabled([
            .camera: isCameraEnabled,
            .microphone: false
        ])

        callClient.setIsPublishing([
            .camera: true,
            .microphone: true
        ])
    }

    // MARK: - Publishing Management

    private func setupNotificationObservers() {
        notificationCenter.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func didEnterBackground() {
        // Disable video publishing in the background because we do not have
        // `isMultitaskingCameraAccessEnabled` enabled.
        // https://developer.apple.com/documentation/avfoundation/avcapturesession/4013227-ismultitaskingcameraaccessenable
        if callClient.publishing.camera.isPublishing {
            callClient.setIsPublishing(.camera, false)
        }
    }

    @objc private func didBecomeActive() {
        // Reenable publishing when returning to the foreground.
        if callClient.publishing.camera.isPublishing == false {
            callClient.setIsPublishing(.camera, true)
        }
    }

    // MARK: - Actions

    public func isAuthorized(for mediaType: AVMediaType) async -> Bool {
        let isAuthorized = await AVCaptureDevice.requestAccess(for: mediaType)

        // Update the input now that authorization has been requested.
        switch mediaType {
        case .audio:
            subjects.microphone.send(CallMicrophone(callClient.inputs.microphone))
        case .video:
            subjects.camera.send(CallCamera(callClient.inputs.camera))
        default:
            fatalError("Expected either audio or video.")
        }

        return isAuthorized
    }

    public func toggleCamera(_ camera: CallCamera) {
        switch camera.video {
        case .muted:
            callClient.setInputsEnabled([.camera: true])
        case .unmuted:
            callClient.setInputsEnabled([.camera: false])
        }
    }

    public func toggleAdaptiveHEVC(_ isAdaptiveHEVCEnabled: Bool) {
        assert([.initialized, .left].contains(callState), "Expected to not be in a video call.")

        if isAdaptiveHEVCEnabled {
            callClient.updatePublishing(.set(
                camera: .set(
                    sendSettings: .set(
                        maxQuality: .set(.high),
                        encodings: .set(.mode(.iOSOptimized))
                    )
                )
            ))
        } else {
            callClient.updatePublishing(.set(
                camera: .set(
                    sendSettings: .fromDefaults
                )
            ))
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
            Task { await applyDefaults() }

            // Recreate the builder to remove any stale participant state.
            participantsBuilder = CallParticipants.Builder(callClient)
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
