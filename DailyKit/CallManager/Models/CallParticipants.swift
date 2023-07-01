import Daily

/// The view of all the visible participants in the call.
public struct CallParticipants: Equatable {
    /// The total number of participants in the call.
    public var count: Int { 1 + remote.count }

    /// The local participant in the call.
    public let local: CallParticipant

    /// All of the remote participants in the call.
    ///
    /// - Note: Iterating over this dictionary should be done with careful consideration of the performance
    /// impact in large calls.
    public let remote: [CallParticipant.ID: CallParticipant]

    /// The participants that can be visible in the UI
    ///
    /// The `Int` keys of this dictionary are ordered based on the following:
    /// - The active speaker.
    /// - Recent speakers with video.
    /// - Recent speakers without video.
    /// - Participants with video who have recently joined the call.
    /// - Participants who have recently joined the call.
    ///
    /// A dictionary is used, so it is possible to have some positions that do not currently have a
    /// participant, which can be useful for some animations. Currently the index primarily represents a
    /// position within the grid layout, but it can be replaced with an enum in the future if UI needs evolve.
    /// One such case might be a different layout with a larger tile for a presentation, which could be
    /// modeled as shown below.
    ///
    /// ```
    /// enum TypeType {
    ///     case presentation
    ///     case grid(Int)
    /// }
    /// ```
    public let visible: [Int: CallParticipant]

    /// Makes a stabilized copy of the newly visible participants.
    ///
    /// Existing participants from the previous value will maintain a stable position in the UI, with new and
    /// existing participants that were displaced by the total number of visible participants decreasing will
    /// be placed in available positions in priority order.
    ///
    /// - Parameter other: the new participants.
    /// - Returns: a stabilized copy of the new participants.
    public func stabilize(_ other: CallParticipants) -> CallParticipants {
        // We need to know the max index to determine which existing participants will be displaced.
        let maxExistingIndex = min(visible.count, other.visible.count) - 1

        // Make a dictionary that can be used to filter and access the newly visible participants.
        let otherParticipantsByID = other.visible
            .reduce(into: [:]) { $0[$1.value.id] = $1.value }

        // Filter the existing participants to remove those that will be displaced and also exist in the newly
        // visible participants.
        let existingParticipantEntries = visible
            .filter { $0.key <= maxExistingIndex }
            .filter { otherParticipantsByID.keys.contains($0.value.id) }
            .compactMapValues { otherParticipantsByID[$0.id] }

        // Make a set to filter existing participants from the newly visible participants.
        let existingParticipantIDs = Set(existingParticipantEntries.values.map(\.id))

        // Make an iterator for the unplaced participants, so they can be placed in new positions not already
        // occupied by existing participants, in priority order. The values from `other.visible` *must* be
        // used because the values in `visible` will be stale when this method is called.
        var unplacedParticipants = (0 ..< other.visible.count)
            .compactMap { other.visible[$0] }
            .filter { existingParticipantIDs.contains($0.id) == false }
            .makeIterator()

        // Collect all participants, placing existing participants by their previous index and using the next
        // participant from the `unplacedParticipants` iterator for indices that are not yet occupied.
        let newVisible = (0 ..< other.visible.count)
            .reduce(into: [:]) { $0[$1] = existingParticipantEntries[$1] ?? unplacedParticipants.next() }

        return CallParticipants(
            local: other.local,
            remote: other.remote,
            visible: newVisible
        )
    }
}
