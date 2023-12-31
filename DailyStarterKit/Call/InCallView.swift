import DailyKit
import SwiftUI

// MARK: - Model

@MainActor
final class InCallModel: ObservableObject {
    // MARK: - Initialization

    private let manager: CallManageable

    init(manager: CallManageable) {
        self.manager = manager

        manager.publisher(for: .participants)
            .map(\.count)
            .assign(to: &$participantsCount)
    }

    // MARK: - Properties

    // The current participants count from `CallParticipants`.
    @Published private(set) var participantsCount: Int = 0

    // Visibility of the call controls based on user interaction.
    @Published private(set) var callControlsOpacity: CGFloat = 1

    // MARK: - Actions

    func backgroundTapped() {
        // Toggle the call controls whenever the background is tapped.
        callControlsOpacity = callControlsOpacity.isZero ? 1 : 0
    }
}

// MARK: - View

struct InCallView: View {
    @EnvironmentObject private var model: InCallModel

    var body: some View {
        Group {
            if model.participantsCount > 1 {
                // Show the grid layout once other participants have joined the call.
                GridLayoutView()
            } else {
                // Show the waiting layout while the local participant is the only participant in the call.
                WaitingLayoutView()
            }
        }
        .onTapGesture {
            withAnimation {
                model.backgroundTapped()
            }
        }
        .overlay {
            // Show the call controls above the current layout.
            CallControlsOverlayView()
                .opacity(model.callControlsOpacity)
        }
        .overlay {
            // Show toasts above both the call controls an the current layout.
            ToastOverlayView()
        }
    }
}

// MARK: - Previews

#if DEBUG
struct InCallView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            InCallView()
        }
    }
}
#endif
