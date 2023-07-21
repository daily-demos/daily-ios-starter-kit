@testable import DailyKit
import XCTest

final class CallParticipantsBuilderTests: XCTestCase, TestSupport {}

// MARK: - Participants Count

extension CallParticipantsBuilderTests {
    func testCountWhenOnlyLocal() throws {
        let builder = CallParticipants.Builder(local: .defaultLocal)

        let participants = builder.build()

        XCTAssertEqual(builder.build().count, 1)
        XCTAssertEqual(participants.visible.count, 0)
    }

    func testCountIncreasesWhenAddingParticipants() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)

        builder.handleJoined(CallParticipant())
        let participants = builder.build()

        XCTAssertEqual(participants.count, 2)
        XCTAssertEqual(participants.visible.count, 1)
    }

    func testCountDecreasesWhenRemovingParticipants() throws {
        let remote: [CallParticipant] = (0 ... 2).map { _ in CallParticipant() }
        var builder = CallParticipants.Builder(local: .defaultLocal)

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        builder.handleJoined(remote[2])
        builder.handleLeft(remote[0])
        let participants = builder.build()

        XCTAssertEqual(participants.count, 3)
        XCTAssertEqual(participants.visible.count, 2)
    }

    func testRemoteParticipantCountDoesNotExceedPhoneLimit() throws {
        var builder = CallParticipants.Builder(
            local: .defaultLocal,
            limit: CallParticipants.Builder.Constants.visibleParticipantLimit(for: .phone)
        )

        for _ in 1 ... 19 {
            builder.handleJoined(CallParticipant())
        }
        let participants = builder.build()

        XCTAssertEqual(participants.count, 20)
        XCTAssertEqual(participants.visible.count, 6)
    }

    func testRemoteParticipantCountDoesNotExceedPadLimit() throws {
        var builder = CallParticipants.Builder(
            local: .defaultLocal,
            limit: CallParticipants.Builder.Constants.visibleParticipantLimit(for: .pad)
        )

        for _ in 1 ... 19 {
            builder.handleJoined(CallParticipant())
        }
        let participants = builder.build()

        XCTAssertEqual(participants.count, 20)
        XCTAssertEqual(participants.visible.count, 12)
    }
}

// MARK: - Visible Participant Limit

extension CallParticipantsBuilderTests {
    func testJoinOrderDoesNotUseVisibleParticipantLimit() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal, limit: 1)

        builder.handleJoined(CallParticipant())
        builder.handleJoined(CallParticipant())

        XCTAssertEqual(builder.joinOrder.count, 2)
    }

    func testSpeakerOrderDoesNotUseVisibleParticipantLimit() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal, limit: 1)
        let remotes: [CallParticipant] = .makeParticipants(count: 2)
        builder.handleJoined(remotes[0])
        builder.handleJoined(remotes[1])

        builder.activeSpeaker = remotes[0]
        builder.activeSpeaker = remotes[1]

        XCTAssertEqual(builder.speakerOrder.count, 2)
    }

    func testVisibleUsesVisibleParticipantLimit() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal, limit: 1)
        let remotes: [CallParticipant] = .makeParticipants(count: 2)

        builder.handleJoined(remotes[0])
        builder.handleJoined(remotes[1])
        let participants = builder.build()

        XCTAssertEqual(participants.visible.count, 1)
    }
}

// MARK: - Remote Participants

extension CallParticipantsBuilderTests {
    func testParticipantsAreAddedToAndRemovedFromRemote() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote = CallParticipant()

        builder.handleJoined(remote)

        XCTAssertEqual(builder.remote[remote.id], remote)

        builder.handleLeft(remote)

        XCTAssertEqual(builder.remote[remote.id], nil)
    }

    func testActiveSpeakerIsRemovedAfterLeft() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote: CallParticipant = CallParticipant()
        builder.handleJoined(remote)
        builder.activeSpeaker = remote

        builder.handleLeft(remote)

        XCTAssertEqual(builder.activeSpeaker, nil)
    }
}

// MARK: - Participant Updates

extension CallParticipantsBuilderTests {
    func testLocalIsUpdatedWhenParticipantsAreUpdated() throws {
        let local = CallParticipant(isLocal: true, hasVideo: false)
        var builder = CallParticipants.Builder(local: local)
        let updated = CallParticipant(isLocal: true, hasVideo: true)
        XCTAssertNotEqual(builder.local, updated)

        builder.handleUpdated(updated)

        XCTAssertEqual(builder.local, updated)
    }

    func testRemoteIsUpdatedWhenParticipantsAreUpdated() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote = CallParticipant(hasVideo: false)
        builder.handleJoined(remote)
        let updated = CallParticipant(id: remote.id, hasVideo: true)
        XCTAssertNotEqual(builder.remote[remote.id], updated)

        builder.handleUpdated(updated)

        XCTAssertEqual(builder.remote[remote.id], updated)
    }

    func testActiveSpeakerIsUpdatedWhenParticipantsAreUpdated() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote = CallParticipant(hasVideo: false)
        builder.handleJoined(remote)
        builder.activeSpeaker = remote
        let updated = CallParticipant(id: remote.id, hasVideo: true)
        XCTAssertNotEqual(builder.activeSpeaker, updated)

        builder.handleUpdated(updated)

        XCTAssertEqual(builder.activeSpeaker, updated)
    }
}

// MARK: - Speaker Order

extension CallParticipantsBuilderTests {
    func testRemoteParticipantsAreAddedToSpeakerOrder() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote: CallParticipant = CallParticipant()
        builder.handleJoined(remote)
        XCTAssertEqual(builder.speakerOrder.contains(remote.id), false)

        builder.activeSpeaker = remote

        XCTAssertEqual(builder.speakerOrder.contains(remote.id), true)
    }

    func testLocalParticipantIsNotAddedToSpeakerOrder() throws {
        let local: CallParticipant = .defaultLocal
        var builder = CallParticipants.Builder(local: local)
        XCTAssertEqual(builder.speakerOrder.count, 0)

        builder.activeSpeaker = local

        XCTAssertEqual(builder.speakerOrder.count, 0)
    }

    func testLocalParticipantIsNotAddedToRemoteWhenActiveSpeaker() throws {
        let local: CallParticipant = .defaultLocal
        var builder = CallParticipants.Builder(local: local)

        builder.activeSpeaker = local
        let participants = builder.build()

        XCTAssertEqual(participants.visible.values.contains(local), false)
    }

    func testSpeakerOrderIsUpdatedWhenActiveSpeakerChanges() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let participants: [CallParticipant] = .makeParticipants(count: 2)
        builder.handleJoined(participants[0])
        builder.handleJoined(participants[1])

        builder.activeSpeaker = participants[0]
        builder.activeSpeaker = participants[1]
        builder.activeSpeaker = participants[0]

        XCTAssertEqual(builder.speakerOrder, [participants[1].id, participants[0].id])
    }

    func testParticipantsAreRemovedFromSpeakerOrder() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let remote: CallParticipant = CallParticipant()
        builder.handleJoined(remote)
        builder.activeSpeaker = remote

        builder.handleLeft(remote)

        XCTAssertEqual(builder.speakerOrder.contains(remote.id), false)
    }
}

// MARK: - Join Order

extension CallParticipantsBuilderTests {
    func testParticipantsAreAddedInJoinOrder() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let participants: [CallParticipant] = .makeParticipants(count: 3)

        builder.handleJoined(participants[0])
        builder.handleJoined(participants[1])
        builder.handleJoined(participants[2])

        XCTAssertEqual(builder.joinOrder, [participants[0].id, participants[1].id, participants[2].id])
    }

    func testParticipantsAreRemovedFromJoinOrder() throws {
        var builder = CallParticipants.Builder(local: .defaultLocal)
        let participants: [CallParticipant] = .makeParticipants(count: 3)
        builder.handleJoined(participants[0])
        builder.handleJoined(participants[1])
        builder.handleJoined(participants[2])

        builder.handleLeft(participants[1])

        XCTAssertEqual(builder.joinOrder, [participants[0].id, participants[2].id])
    }
}

// MARK: - Visible Participants

extension CallParticipantsBuilderTests {
    func testParticipantsAreOrderedByJoinRecency() throws {
        let remote = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        builder.handleJoined(remote[2])
        let participants = builder.build()

        assertParticipants(participants, visibleEquals: [
            remote[2],
            remote[1],
            remote[0],
        ])
    }

    func testParticipantsAreOrderedByJoinRecencyWhenLimitIsExceeded() throws {
        let remote = [
            CallParticipant(username: "0", hasVideo: false),
            CallParticipant(username: "1", hasVideo: false),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal, limit: 1)
        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        // Only participant 1 is visible because the limit is 1.
        assertParticipants(builder.build(), visibleEquals: [
            remote[1],
        ])

        builder.handleLeft(remote[1])
        let participants = builder.build()

        // When participant 1 leaves, participant 0 should become visible.
        assertParticipants(participants, visibleEquals: [
            remote[0]
        ])
    }

    func testParticipantsAreOrderedByJoinRecencyAndVideo() throws {
        let remote = [
            CallParticipant(username: "0 video", hasVideo: true),
            CallParticipant(username: "1", hasVideo: false),
            CallParticipant(username: "2 video", hasVideo: true),
            CallParticipant(username: "3", hasVideo: false),
            CallParticipant(username: "4 video", hasVideo: true),
            CallParticipant(username: "5", hasVideo: false),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)
        XCTAssertEqual(remote.map(\.hasVideo), [true, false, true, false, true, false])

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        builder.handleJoined(remote[2])
        builder.handleJoined(remote[3])
        builder.handleJoined(remote[4])
        builder.handleJoined(remote[5])
        let participants = builder.build()

        XCTAssertEqual(participants.visible.mapValues(\.hasVideo), [
            0: true,
            1: true,
            2: true,
            3: false,
            4: false,
            5: false
        ])
    }

    func testParticipantsAreOrderedBySpeakingRecency() throws {
        let remote = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)
        builder.handleJoined(remote[2])
        builder.handleJoined(remote[1])
        builder.handleJoined(remote[0])

        builder.activeSpeaker = remote[0]
        builder.activeSpeaker = remote[1]
        builder.activeSpeaker = remote[2]
        let participants = builder.build()

        assertParticipants(participants, visibleEquals: [
            remote[2],
            remote[1],
            remote[0],
        ])
    }

    func testParticipantsAreOrderedBySpeakingRecencyWhenLimitIsExceeded() throws {
        let remote = [
            CallParticipant(username: "0", hasVideo: false),
            CallParticipant(username: "1", hasVideo: false),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal, limit: 1)
        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        builder.activeSpeaker = remote[0]
        builder.activeSpeaker = remote[1]
        builder.activeSpeaker = nil
        // Only participant 1 is visible because the limit is 1.
        assertParticipants(builder.build(), visibleEquals: [
            remote[1],
        ])

        builder.handleLeft(remote[1])
        let participants = builder.build()

        // When participant 1 leaves, participant 0 should become visible.
        assertParticipants(participants, visibleEquals: [
            remote[0],
        ])
    }

    func testParticipantsAreOrderedBySpeakingRecencyAndVideo() throws {
        let remote = [
            CallParticipant(username: "0 video", hasVideo: true),
            CallParticipant(username: "1", hasVideo: false),
            CallParticipant(username: "2 video", hasVideo: true),
            CallParticipant(username: "3", hasVideo: false),
            CallParticipant(username: "4 video", hasVideo: true),
            CallParticipant(username: "5", hasVideo: false),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)
        XCTAssertEqual(remote.map(\.hasVideo), [true, false, true, false, true, false])

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])
        builder.handleJoined(remote[2])
        builder.handleJoined(remote[3])
        builder.handleJoined(remote[4])
        builder.handleJoined(remote[5])
        let participants = builder.build()

        XCTAssertEqual(participants.visible.mapValues(\.hasVideo), [
            0: true,
            1: true,
            2: true,
            3: false,
            4: false,
            5: false,
        ])
    }

    func testSpeakingRecencyIsOrderedBeforeJoinRecency() throws {
        let remote = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1])

        builder.activeSpeaker = remote[0]
        let participants = builder.build()

        assertParticipants(participants, visibleEquals: [
            remote[0],
            remote[1],
        ])
    }

    // Participants are ordered by:
    // - Speaking recency w/video
    // - Speaking recency w/o video
    // - Join recency w/video
    // - Join recency w/o video
    func testParticipantsAreOrdered() throws {
        let remote = [
            CallParticipant(username: "0 (active speaker)", hasVideo: false),
            CallParticipant(username: "1 (past speaker, video)", hasVideo: true),
            CallParticipant(username: "2 (past speaker)", hasVideo: false),
            CallParticipant(username: "3 (video)", hasVideo: true),
            CallParticipant(username: "4", hasVideo: false),
        ]
        var builder = CallParticipants.Builder(local: .defaultLocal)
        XCTAssertEqual(remote.map(\.hasVideo), [false, true, false, true, false])

        builder.handleJoined(remote[0])
        builder.handleJoined(remote[1]) // video
        builder.handleJoined(remote[2])
        builder.handleJoined(remote[3]) // video
        builder.handleJoined(remote[4])

        builder.activeSpeaker = remote[1] // video
        builder.activeSpeaker = remote[2]
        builder.activeSpeaker = remote[0]

        let participants = builder.build()

        assertParticipants(participants, visibleEquals: [
            remote[0],
            remote[1],
            remote[2],
            remote[3],
            remote[4],
        ])
    }
}
