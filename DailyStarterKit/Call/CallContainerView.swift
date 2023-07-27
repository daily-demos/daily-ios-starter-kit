import Combine
import DailyKit
import SwiftUI

struct CallContainerView: View {
    // MARK: - Model

    @MainActor
    final class Model: ObservableObject {
        // MARK: - Initialization

        private let manager: CallManageable
        private var subscriptions: Set<AnyCancellable> = []

        init(manager: CallManageable) {
            self.manager = manager

            manager.publisher(for: .callState)
                .map { [.joining, .joined].contains($0) }
                .assign(to: &$isInCall)

            $isInCall.sink { isJoined in
                // Disable the idle timer to keep the screen awake while in a call.
                UIApplication.shared.isIdleTimerDisabled = isJoined
            }
            .store(in: &subscriptions)
        }

        // MARK: - Properties

        // Whether the call is in the `joining` or `joined` call state.
        @Published private(set) var isInCall: Bool = false
    }

    // MARK: - View

    @EnvironmentObject private var model: Model

    var body: some View {
        GeometryReader { geometry in
            Group {
                if model.isInCall {
                    // Show the in-call layouts once the call has been joined.
                    InCallView()
                } else {
                    // Show the join layout before joining or after leaving a call.
                    JoinLayoutView()
                }
            }
            // Set the `callLayout` based on the size of the window.
            .callLayout(CallLayout(geometry.size))
            // Prefer the dark color scheme, so text in the status bar will be readable.
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            CallContainerView()
        }
    }
}
#endif
