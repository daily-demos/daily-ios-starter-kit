import UIKit

/// Geometry values used in ``GridLayoutView``.
struct GridGeometry: Equatable {
    let rowCount: Int
    let columnCount: Int
}

extension GridGeometry {
    private static let device: UIDevice = .current

    /// Makes a grid geometry value for the specified parameters.
    ///
    /// - Phones support a 2x3 grid of up to 6 participants.
    /// - Pads support a 3x4 grid of up to 12 participants.
    ///
    /// - Parameters:
    ///   - idiom: the user interface idiom.
    ///   - layout: the call layout.
    ///   - participantsCount: the participants count.
    init(
        idiom: UIUserInterfaceIdiom = device.userInterfaceIdiom,
        layout: CallLayout,
        participantsCount: Int
    ) {
        switch (idiom, participantsCount) {
        case (_, 0):
            self.rowCount = 0
            self.columnCount = 0

        case (_, 1):
            self.rowCount = 1
            self.columnCount = 1

        case (_, 2...3) where layout == .portrait:
            self.rowCount = participantsCount
            self.columnCount = 1

        case (_, 2...3) where layout == .landscape:
            self.rowCount = 1
            self.columnCount = participantsCount

        case (_, 4):
            self.rowCount = 2
            self.columnCount = 2

        case (_, 5) where layout == .portrait:
            self.rowCount = 3
            self.columnCount = 2

        case (_, 5):
            self.rowCount = 2
            self.columnCount = 3

        case (.phone, 6...) where layout == .portrait:
            self.rowCount = 3
            self.columnCount = 2

        case (.phone, 6...) where layout == .landscape:
            self.rowCount = 2
            self.columnCount = 3

        case (.pad, 6) where layout == .portrait:
            self.rowCount = 3
            self.columnCount = 2

        case (.pad, 7...8) where layout == .portrait:
            self.rowCount = 4
            self.columnCount = 2

        case (.pad, 9) where layout == .portrait:
            self.rowCount = 3
            self.columnCount = 3

        case (.pad, 10...) where layout == .portrait:
            self.rowCount = 4
            self.columnCount = 3

        case (.pad, 6) where layout == .landscape:
            self.rowCount = 2
            self.columnCount = 3

        case (.pad, 7...8) where layout == .landscape:
            self.rowCount = 2
            self.columnCount = 4

        case (.pad, 9) where layout == .landscape:
            self.rowCount = 3
            self.columnCount = 3

        case (.pad, 10...) where layout == .landscape:
            self.rowCount = 3
            self.columnCount = 4

        default:
            fatalError("Unexpected idom: \(idiom), layout: \(layout).")
        }
    }
}
