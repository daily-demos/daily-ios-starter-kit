@testable import DailyKit
import XCTest

final class CallParticipantsTests: XCTestCase, TestSupport {
    func testStabilizePreservesOrderWhenEqual() throws {
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

        XCTAssertEqual(participants.visible.mapValues(\.username), [
            0: visible[0].username,
            1: visible[1].username,
            2: visible[2].username,
            3: visible[3].username,
            4: visible[4].username,
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
