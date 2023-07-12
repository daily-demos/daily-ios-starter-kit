import Foundation
import Combine
import Daily

@MainActor
/// The source of truth for call state and interface to the Daily `CallClient`.
public protocol CallManageable {
    // MARK: - State

    /// The url of the current call.
    var url: URL? { get }

    /// The current `CallState` value.
    var callState: CallState { get }

    /// The current `CallCamera` value.
    var camera: CallCamera { get }

    /// The current `CallMicrophone` value.
    var microphone: CallMicrophone { get }

    /// The current `CallParticipants` value.
    var participants: CallParticipants { get }

    // MARK: - Publishers

    /// Returns a publisher for the specified property.
    ///
    /// - Parameter property: the property for which to return a publisher.
    /// - Returns: a publisher for the specified property.
    func publisher<T>(for property: CallClientProperty<T>) -> AnyPublisher<T, Never>

    // MARK: - Actions

    /// Toggles the mute state of the camera.
    ///
    /// - Parameter camera: the current `CallCamera` value.
    func toggleCamera(_ camera: CallCamera)

    /// Toggles the mute state of the microphone.
    ///
    /// - Parameter microphone: the current `CallMicrophone` value.
    func toggleMicrophone(_ microphone: CallMicrophone)

    /// Flips the camera between `user` and `environment` facing modes.
    ///
    /// - Parameter mode: the current `CallCamera` value.
    func flipCamera(_ mode: CallCamera)

    /// Sets the username to the specified value.
    ///
    /// - Parameter username: the value to set the `username` to.
    func setUsername(_ username: String?)

    /// Joins a call with the specified url.
    ///
    /// - Parameter url: the url of the call to join.
    func join(url: URL)

    /// Leaves the current call.
    func leave()
}
