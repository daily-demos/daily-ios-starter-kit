@testable import DailyStarterKit
import XCTest

final class GridGeometryTests: XCTestCase {
    func testPortraitPhoneGridDimensions() throws {
        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 0),
            GridGeometry(rowCount: 0, columnCount: 0)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 1),
            GridGeometry(rowCount: 1, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 3),
            GridGeometry(rowCount: 3, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 4),
            GridGeometry(rowCount: 2, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 5),
            GridGeometry(rowCount: 3, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 6),
            GridGeometry(rowCount: 3, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .portrait, participantsCount: 7),
            GridGeometry(rowCount: 3, columnCount: 2)
        )
    }

    func testLandscapePhoneGridDimensions() throws {
        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 0),
            GridGeometry(rowCount: 0, columnCount: 0)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 1),
            GridGeometry(rowCount: 1, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 3),
            GridGeometry(rowCount: 1, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 4),
            GridGeometry(rowCount: 2, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 5),
            GridGeometry(rowCount: 2, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 6),
            GridGeometry(rowCount: 2, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .phone, layout: .landscape, participantsCount: 7),
            GridGeometry(rowCount: 2, columnCount: 3)
        )
    }

    func testPortraitPadGridDimensions() throws {
        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 0),
            GridGeometry(rowCount: 0, columnCount: 0)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 1),
            GridGeometry(rowCount: 1, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 3),
            GridGeometry(rowCount: 3, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 4),
            GridGeometry(rowCount: 2, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 5),
            GridGeometry(rowCount: 3, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 6),
            GridGeometry(rowCount: 3, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 7),
            GridGeometry(rowCount: 4, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 8),
            GridGeometry(rowCount: 4, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 9),
            GridGeometry(rowCount: 3, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 10),
            GridGeometry(rowCount: 4, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 11),
            GridGeometry(rowCount: 4, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 12),
            GridGeometry(rowCount: 4, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .portrait, participantsCount: 13),
            GridGeometry(rowCount: 4, columnCount: 3)
        )
    }

    func testLandscapePadGridDimensions() throws {
        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 0),
            GridGeometry(rowCount: 0, columnCount: 0)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 1),
            GridGeometry(rowCount: 1, columnCount: 1)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 3),
            GridGeometry(rowCount: 1, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 4),
            GridGeometry(rowCount: 2, columnCount: 2)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 5),
            GridGeometry(rowCount: 2, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 6),
            GridGeometry(rowCount: 2, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 7),
            GridGeometry(rowCount: 2, columnCount: 4)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 8),
            GridGeometry(rowCount: 2, columnCount: 4)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 9),
            GridGeometry(rowCount: 3, columnCount: 3)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 10),
            GridGeometry(rowCount: 3, columnCount: 4)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 11),
            GridGeometry(rowCount: 3, columnCount: 4)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 12),
            GridGeometry(rowCount: 3, columnCount: 4)
        )

        XCTAssertEqual(
            GridGeometry(idiom: .pad, layout: .landscape, participantsCount: 13),
            GridGeometry(rowCount: 3, columnCount: 4)
        )
    }
}
