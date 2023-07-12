import Daily

/// `VideoTrack` needs to be `Hashable` to use synthesized conformance for `CallParticipant`.
extension VideoTrack: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isEnabled)
    }
}
