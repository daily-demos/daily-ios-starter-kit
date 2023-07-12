import Combine
import DailyKit
import SwiftUI

struct GridLayoutView: View {
    // MARK: - Model

    @MainActor
    final class Model: ObservableObject {
        // MARK: - Initialization

        private let manager: CallManageable
        private var subscriptions: Set<AnyCancellable> = []

        init(manager: CallManageable) {
            self.manager = manager
            self.participants = manager.participants
            self.localParticipant = manager.participants.local
            self.visibleParticipants = manager.participants.visible

            manager.publisher(for: .participants)
                .sink { [weak self] participants in
                    guard let self else { return }

                    // We call `stabilize` before setting the new value to preserve the existing position of
                    // participants that were already visible in the layout.
                    self.participants = self.participants.stabilize(participants)
                }
                .store(in: &subscriptions)
        }

        // We store the call participants here, so we can call `stabilize` on the old value when it changes.
        private var participants: CallParticipants {
            didSet {
                self.localParticipant = participants.local
                self.visibleParticipants = participants.visible
            }
        }

        // MARK: - Properties

        @Published private(set) var localParticipant: CallParticipant
        @Published private(set) var visibleParticipants: [Int: CallParticipant]

        // MARK: - Actions

        func gridSize(for layout: CallLayout) -> GridGeometry {
            GridGeometry(layout: layout, participantsCount: visibleParticipants.count)
        }
    }

    // MARK: - View

    @EnvironmentObject private var model: Model

    @Environment(\.callLayout) private var layout: CallLayout

    // A namespace for use with `matchedGeometryEffect`.
    @Namespace private var namespace: Namespace.ID

    /// Identifiers for use with `matchedGeometryEffect`.
    private enum ViewID: Hashable {
        case tileSize
    }

    // The animation used for transitions in the grid.
    private let animation: Animation = .default

    var body: some View {
        Group {
            let grid = model.gridSize(for: layout)

            switch layout {
            case .portrait:
                HStack {
                    Spacer()

                    VStack(spacing: 8) {
                        Spacer()

                        ParticipantView(participant: model.localParticipant, shouldShowName: false)
                            .aspectRatio(layout.localVideoAspectRatio, contentMode: .fit)
                            .frame(minHeight: 160, maxHeight: 200)

                        ForEach(0 ..< grid.rowCount, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0 ..< grid.columnCount, id: \.self) { column in
                                    let index = (row * grid.columnCount) + column

                                    if let participant = model.visibleParticipants[index] {
                                        // We use `matchedGeometryEffect` here to animate size changes of
                                        // grid tiles when the grid dimensions change.
                                        ParticipantView(participant: participant)
                                            .transition(.opacity.animation(animation))
                                            .aspectRatio(1, contentMode: .fit)
                                            .matchedGeometryEffect(
                                                id: participant.id,
                                                in: namespace,
                                                properties: .size
                                            )
                                    }
                                }
                            }
                            // We use `matchedGeometryEffect` here to make the last `HStack` the same size as
                            // the others, which allows us to center the grid tiles it contains when the row
                            // is not full.
                            .matchedGeometryEffect(
                                id: ViewID.tileSize,
                                in: namespace,
                                properties: .size,
                                isSource: row == 0
                            )
                        }

                        Spacer()
                    }
                    .animation(animation, value: model.visibleParticipants)

                    Spacer()
                }

            case .landscape:
                VStack {
                    Spacer()

                    HStack {
                        Spacer()

                        ParticipantView(participant: model.localParticipant, shouldShowName: false)
                            .aspectRatio(layout.localVideoAspectRatio, contentMode: .fit)
                            .frame(minWidth: 160, maxWidth: 200)

                        HStack(spacing: 8) {
                            ForEach(0 ..< grid.columnCount, id: \.self) { row in
                                VStack(spacing: 8) {
                                    Spacer()

                                    ForEach(0 ..< grid.rowCount, id: \.self) { column in
                                        let index = (row * grid.rowCount) + column
                                        if let participant = model.visibleParticipants[index] {
                                            // We use `matchedGeometryEffect` here to animate size changes of
                                            // grid tiles when the grid dimensions change.
                                            ParticipantView(participant: participant)
                                                .transition(.opacity.animation(animation))
                                                .aspectRatio(1, contentMode: .fit)
                                                .matchedGeometryEffect(
                                                    id: participant.id,
                                                    in: namespace,
                                                    properties: .size
                                                )
                                        }
                                    }

                                    Spacer()
                                }
                                // We use `matchedGeometryEffect` here to make the last `VStack` the same
                                // size as the others, which allows us to center the grid tiles it contains
                                // when the column is not full.
                                .matchedGeometryEffect(
                                    id: ViewID.tileSize,
                                    in: namespace,
                                    properties: .size,
                                    isSource: row == 0
                                )
                            }
                        }

                        Spacer()
                    }
                    .animation(animation, value: model.visibleParticipants)

                    Spacer()
                }
            }
        }
        .background(Colors.backgroundPrimary)
    }
}

// MARK: - Previews

#if DEBUG
struct GridLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        let phoneManager = FakeCallManager(visible: (0 ..< 5).map { _ in CallParticipant() })
        ForEach([
            "iPhone 14 Pro",
        ], id: \.self) { deviceName in
            GridLayoutView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName("\(deviceName) Portrait")
                .previewInterfaceOrientation(.portrait)

            GridLayoutView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName("\(deviceName) Landscape")
                .previewInterfaceOrientation(.landscapeRight)
                .callLayout(.landscape)
        }
        .environmentObject(GridLayoutView.Model(manager: phoneManager))

        let padManager = FakeCallManager(visible: (0 ..< 11).map { _ in CallParticipant() })
        ForEach([
            "iPad mini (6th generation)",
        ], id: \.self) { deviceName in
            GridLayoutView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName("\(deviceName) Portrait")
                .previewInterfaceOrientation(.portrait)

            GridLayoutView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName("\(deviceName) Landscape")
                .previewInterfaceOrientation(.landscapeRight)
                .callLayout(.landscape)
        }
        .environmentObject(GridLayoutView.Model(manager: padManager))
    }
}
#endif
