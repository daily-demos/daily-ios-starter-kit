import Daily

/// Properties that are published by the ``CallClient``.
public struct CallClientProperty<T>: Equatable, Hashable {
    public static func == (lhs: CallClientProperty<T>, rhs: CallClientProperty<T>) -> Bool {
        lhs.metatype == rhs.metatype
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(metatype))
    }

    /// The metatype of this property.
    let metatype: T.Type
}

extension CallClientProperty where T == Optional<URL> {
    /// The ``URL`` for the current call.
    public static let url = CallClientProperty(metatype: Optional<URL>.self)
}

extension CallClientProperty where T == CallState {
    /// The current ``CallState``.
    public static let callState = CallClientProperty(metatype: CallState.self)
}

extension CallClientProperty where T == CallCamera {
    /// The state of the camera for this device.
    public static let camera = CallClientProperty(metatype: CallCamera.self)
}

extension CallClientProperty where T == CallMicrophone {
    /// The state of the microphone for this device.
    public static let microphone = CallClientProperty(metatype: CallMicrophone.self)
}

extension CallClientProperty where T == CallParticipants {
    /// The participants in the current call.
    public static let participants = CallClientProperty(metatype: CallParticipants.self)
}
