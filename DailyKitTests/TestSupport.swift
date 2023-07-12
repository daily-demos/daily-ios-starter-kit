@testable import DailyKit
import XCTest

protocol TestSupport {}

extension TestSupport {
    func makeCallParticipants(visible participants: [CallParticipant]) -> CallParticipants {
        let visible = participants
            .enumerated()
            .reduce(into: [:]) { $0[$1.offset] = $1.element }
        let remote = participants
            .reduce(into: [:]) { $0[$1.id] = $1 }

        return CallParticipants(
            local: .defaultLocal,
            remote: remote,
            visible: visible
        )
    }

    func assertParticipants(
        _ participants: CallParticipants,
        visibleEquals visible: [CallParticipant],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard participants.visible.count == visible.count else {
            XCTFail(
                "Expected visible.count of \(visible.count) but was \(participants.visible.count).",
                file: file,
                line: line
            )
            return
        }

        for i in visible.indices {
            let expected = visible[i]
            guard let actual = participants.visible[i] else {
                XCTFail(
                    "Expected participant named \(expected.username) at index \(i) but was nil.",
                    file: file,
                    line: line
                )
                continue
            }

            if actual != expected {
                XCTFail(
                    """
                    Expected participant named "\(expected.username)" at index \(i) but was \
                    "\(actual.username)".
                    """,
                    file: file,
                    line: line
                )
            }
        }
    }
}
