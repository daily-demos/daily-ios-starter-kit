import Foundation
import Combine
import Daily

/// Subjects for ``CallClientProperty``s.
final class CallClientSubjects {
    let url: CurrentValueSubject<URL?, Never>
    let callState: CurrentValueSubject<CallState, Never>
    let camera: CurrentValueSubject<CallCamera, Never>
    let microphone: CurrentValueSubject<CallMicrophone, Never>
    let participants: CurrentValueSubject<CallParticipants, Never>

    private var publishers: [AnyHashable: Any] = [:]

    init(
        url: URL?,
        callState: CallState,
        camera: CallCamera,
        microphone: CallMicrophone,
        participants: CallParticipants
    ) {
        self.url = .init(url)
        self.callState = .init(callState)
        self.camera = .init(camera)
        self.microphone = .init(microphone)
        self.participants = .init(participants)

        setupPublishers()
    }

    private func setupPublishers() {
        publishers[CallClientProperty.url] = url.eraseToAnyPublisher()
        publishers[CallClientProperty.callState] = callState.eraseToAnyPublisher()
        publishers[CallClientProperty.camera] = camera.eraseToAnyPublisher()
        publishers[CallClientProperty.microphone] = microphone.eraseToAnyPublisher()
        publishers[CallClientProperty.participants] = participants.eraseToAnyPublisher()
    }

    /// Returns a publisher for the specified property.
    ///
    /// - Parameter property: the property for which to return a publisher.
    /// - Returns: a publisher for the specified property.
    func publisher<T>(for property: CallClientProperty<T>) -> AnyPublisher<T, Never> {
        guard let publisher = publishers[property] as? AnyPublisher<T, Never> else {
            fatalError("Expected a publisher of type AnyPublisher<\(property.metatype), Never>.")
        }

        return publisher
    }
}
