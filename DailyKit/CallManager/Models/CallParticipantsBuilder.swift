import Daily
import UIKit

extension CallParticipants {
    /// A builder that makes `CallParticipants` values.
    struct Builder: Equatable {
        enum Constants {
            private static let device: UIDevice = .current

            /// The limit for the maximum number of participants to be shown in the UI.
            static func visibleParticipantLimit(
                for idiom: UIUserInterfaceIdiom = device.userInterfaceIdiom
            ) -> Int {
                idiom == .pad ? 12 : 6
            }
        }

        /// The local participant.
        private(set) var local: CallParticipant

        private let limit: Int

        /// Makes a builder using the specified values.
        ///
        /// - Parameters:
        ///   - local: the local participant.
        ///   - limit: the limit for the maximum number of participants to be shown in the UI.
        init(local: CallParticipant, limit: Int = Constants.visibleParticipantLimit()) {
            self.local = local
            self.limit = limit
        }

        /// All remote participants in the call.
        private(set) var remote: [CallParticipant.ID: CallParticipant] = [:]

        /// A limited number of speakers, ordered by speaking recency.
        private(set) var speakerOrder: [CallParticipant.ID] = []

        /// A limited number of participants, ordered by join recency.
        private(set) var joinOrder: [CallParticipant.ID] = []

        /// The active speaker.
        var activeSpeaker: CallParticipant? {
            didSet {
                // Do not track the local participant because they are not shown in the grid.
                if let activeSpeaker, activeSpeaker.isLocal == false {
                    speakerOrder.removeAll(where: { $0 == activeSpeaker.id })
                    speakerOrder.append(activeSpeaker.id)
                    speakerOrder = Array(speakerOrder.prefix(limit))
                }
            }
        }

        /// Builds a prioritized view of all visible participants in the call.
        ///
        /// Visible participants are ordered based on the following.
        /// - The active speaker.
        /// - Recent speakers with video.
        /// - Recent speakers without video.
        /// - Participants with video who have recently joined the call.
        /// - Participants who have recently joined the call.
        ///
        /// - Returns: a prioritized view of all visible participants in the call.
        func build() -> CallParticipants {
            var ids: Set<CallParticipant.ID> = []
            var newVisible: [Int: CallParticipant] = [:]

            // Appends a participant if the limit is not yet exceeded, and they do not exist in `newVisible`.
            func append(_ participant: CallParticipant) {
                guard ids.count < limit else { return }
                guard ids.contains(participant.id) == false else { return }

                ids.insert(participant.id)
                newVisible[newVisible.count] = participant
            }

            // Appends the specified participants in order and partitioned by video.
            func append(_ participantIDs: [CallParticipant.ID]) {
                var withVideo: [CallParticipant] = []
                var withoutVideo: [CallParticipant] = []

                let participants = participantIDs
                    .map { remote[$0] }
                    .compactMap { $0 }

                for participant in participants {
                    if participant.hasVideo {
                        withVideo.append(participant)
                    } else {
                        withoutVideo.append(participant)
                    }
                }

                withVideo.forEach { append($0) }
                withoutVideo.forEach { append($0) }
            }

            // We prepend the active speaker, so they will still be first if they do not have video.
            if let activeSpeaker, activeSpeaker.isLocal == false {
                append(activeSpeaker)
            }

            append(speakerOrder.reversed())
            append(joinOrder.reversed())

            return CallParticipants(
                local: local,
                remote: remote,
                visible: newVisible
            )
        }

        /// Handles participants that have joined the call.
        ///
        /// - Parameter participant: the participant that joined the call.
        mutating func handleJoined(_ participant: CallParticipant) {
            assert(participant.isLocal == false, "Unexpected join event for the local participant.")

            joinOrder.append(participant.id)
            joinOrder = Array(joinOrder.prefix(limit))

            remote[participant.id] = participant
        }

        /// Handles participants that have been updated.
        ///
        /// - Parameter participant: the participant that joined the call.
        mutating func handleUpdated(_ participant: CallParticipant) {
            if participant.isLocal {
                local = participant
            } else {
                remote[participant.id] = participant

                if activeSpeaker?.id == participant.id {
                    activeSpeaker = participant
                }
            }
        }

        /// Handles participants that have left the call.
        ///
        /// - Parameter participant: the participant that left the call.
        mutating func handleLeft(_ participant: CallParticipant) {
            assert(participant.isLocal == false, "The local participant cannot be removed.")

            joinOrder.removeAll { $0 == participant.id }
            speakerOrder.removeAll { $0 == participant.id }

            if activeSpeaker?.id == participant.id {
                activeSpeaker = nil
            }

            remote.removeValue(forKey: participant.id)
        }
    }
}

extension CallParticipants.Builder {
    @MainActor
    /// Makes a builder for the specified call client.
    ///
    /// - Parameter callClient: the call client for which to make a builder.
    init(_ callClient: CallClient) {
        self.init(local: callClient.participants.local.asCallParticipant)
    }
}
