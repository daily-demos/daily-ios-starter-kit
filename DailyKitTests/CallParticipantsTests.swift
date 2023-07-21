@testable import DailyKit
import XCTest

final class CallParticipantsTests: XCTestCase, TestSupport {}

// MARK: - Ordering

extension CallParticipantsTests {
    func testStabilizePreservesOrderWhenOrderDoesNotChange() throws {
        let visible = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
        ]
        let previous = makeCallParticipants(visible: [
            visible[0],
            visible[1],
            visible[2],
        ])
        let current = makeCallParticipants(visible: [
            visible[0],
            visible[1],
            visible[2],
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            visible[0],
            visible[1],
            visible[2],
        ])
    }

    func testStabilizePreservesPreviousOrderForMovedParticipants() throws {
        let visible = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
        ]
        let previous = makeCallParticipants(visible: [
            visible[0],
            visible[1],
            visible[2],
        ])
        let current = makeCallParticipants(visible: [
            visible[2],
            visible[1],
            visible[0],
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            visible[0],
            visible[1],
            visible[2],
        ])
    }

    func testStabilizeAddsAndRemovesParticipants() throws {
        let visible = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
            CallParticipant(username: "3"),
        ]
        let previous = makeCallParticipants(visible: [
            visible[0], // 0 will be removed.
            visible[1],
            visible[2],
        ])
        let current = makeCallParticipants(visible: [
            visible[1],
            visible[2],
            visible[3], // 3 will be added.
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            visible[3],
            visible[1],
            visible[2],
        ])
    }

    func testStabilizeHandlesBiggerOthers() throws {
        let visible = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
            CallParticipant(username: "3"),
            CallParticipant(username: "4"),
        ]
        let previous = makeCallParticipants(visible: [
            visible[0],
            visible[1],
            visible[2],
        ])
        let current = makeCallParticipants(visible: [
            visible[3],
            visible[4],
            visible[0],
            visible[1],
            visible[2],
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            visible[0],
            visible[1],
            visible[2],
            visible[3],
            visible[4],
        ])
    }

    func testStabilizeHandlesSmallerOthers() throws {
        let visible = [
            CallParticipant(username: "0"),
            CallParticipant(username: "1"),
            CallParticipant(username: "2"),
            CallParticipant(username: "3"),
            CallParticipant(username: "4"),
        ]
        let previous = makeCallParticipants(visible: [
            visible[0],
            visible[1],
            visible[2],
            visible[3],
            visible[4],
        ])
        let current = makeCallParticipants(visible: [
            visible[1],
            visible[2],
            visible[3],
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            visible[3],
            visible[1],
            visible[2],
        ])
    }
}

// MARK: - New Values

extension CallParticipantsTests {
    func testStabilizePreservesNewValuesWhenOrderDoesNotChange() throws {
        let previous = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: false),
            CallParticipant(id: 1, username: "1", hasVideo: false),
            CallParticipant(id: 2, username: "2", hasVideo: false),
        ])
        let current = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            CallParticipant(id: 0, username: "0", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])
    }

    func testStabilizePreservesNewValuesWhenParticipantsAreMoved() throws {
        let previous = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: false),
            CallParticipant(id: 1, username: "1", hasVideo: false),
            CallParticipant(id: 2, username: "2", hasVideo: false),
        ])
        let current = makeCallParticipants(visible: [
            CallParticipant(id: 2, username: "2", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 0, username: "0", hasVideo: true),
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            CallParticipant(id: 0, username: "0", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])
    }

    func testStabilizePreservesNewValuesWhenAddingAndRemovingParticipants() throws {
        let previous = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: false),
            CallParticipant(id: 1, username: "1", hasVideo: false),
            CallParticipant(id: 2, username: "2", hasVideo: false),
        ])
        let current = makeCallParticipants(visible: [
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
            CallParticipant(id: 3, username: "3", hasVideo: true),
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            CallParticipant(id: 3, username: "3", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])
    }

    func testStabilizePreservesNewValuesWhenOthersIsBigger() throws {
        let previous = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: false),
            CallParticipant(id: 1, username: "1", hasVideo: false),
            CallParticipant(id: 2, username: "2", hasVideo: false),
        ])
        let current = makeCallParticipants(visible: [
            CallParticipant(id: 3, username: "3", hasVideo: true),
            CallParticipant(id: 4, username: "4", hasVideo: true),
            CallParticipant(id: 0, username: "0", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            CallParticipant(id: 0, username: "0", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
            CallParticipant(id: 3, username: "3", hasVideo: true),
            CallParticipant(id: 4, username: "4", hasVideo: true),
        ])
    }

    func testStabilizePreservesNewValuesWhenOthersIsSmaller() throws {
        let previous = makeCallParticipants(visible: [
            CallParticipant(id: 0, username: "0", hasVideo: false),
            CallParticipant(id: 1, username: "1", hasVideo: false),
            CallParticipant(id: 2, username: "2", hasVideo: false),
            CallParticipant(id: 3, username: "3", hasVideo: false),
            CallParticipant(id: 4, username: "4", hasVideo: false),
        ])
        let current = makeCallParticipants(visible: [
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
            CallParticipant(id: 3, username: "3", hasVideo: true),
        ])

        let participants = previous.stabilize(current)

        assertParticipants(participants, visibleEquals: [
            CallParticipant(id: 3, username: "3", hasVideo: true),
            CallParticipant(id: 1, username: "1", hasVideo: true),
            CallParticipant(id: 2, username: "2", hasVideo: true),
        ])
    }
}
