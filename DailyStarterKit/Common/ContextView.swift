import DailyKit
import SwiftUI

struct ContextView<Content: View>: View {
    @StateObject private var callContainerViewModel: CallContainerView.Model
    @StateObject private var callControlsOverlayViewModel: CallControlsOverlayView.Model
    @StateObject private var callControlsViewModel: CallControlsView.Model
    @StateObject private var callDetailsViewModel: CallDetailsView.Model
    @StateObject private var gridLayoutViewModel: GridLayoutView.Model
    @StateObject private var inCallViewModel: InCallView.Model
    @StateObject private var joinLayoutViewModel: JoinLayoutView.Model
    @StateObject private var toastOverlayViewModel: ToastOverlayView.Model
    @StateObject private var waitingLayoutViewModel: WaitingLayoutView.Model

    private let content: () -> Content

    init(
        callManager: CallManageable,
        toastManager: ToastManager = .live,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._callContainerViewModel = StateObject(
            wrappedValue: CallContainerView.Model(manager: callManager)
        )
        self._callControlsOverlayViewModel = StateObject(
            wrappedValue: CallControlsOverlayView.Model(manager: callManager)
        )
        self._callControlsViewModel = StateObject(
            wrappedValue: CallControlsView.Model(manager: callManager)
        )
        self._callDetailsViewModel = StateObject(
            wrappedValue: CallDetailsView.Model(manager: callManager)
        )
        self._gridLayoutViewModel = StateObject(
            wrappedValue: GridLayoutView.Model(manager: callManager)
        )
        self._inCallViewModel = StateObject(
            wrappedValue: InCallView.Model(manager: callManager)
        )
        self._joinLayoutViewModel = StateObject(
            wrappedValue: JoinLayoutView.Model(manager: callManager)
        )
        self._toastOverlayViewModel = StateObject(
            wrappedValue: ToastOverlayView.Model(manager: toastManager)
        )
        self._waitingLayoutViewModel = StateObject(
            wrappedValue: WaitingLayoutView.Model(callManager: callManager, toastManager: toastManager)
        )

        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(callContainerViewModel)
            .environmentObject(callControlsOverlayViewModel)
            .environmentObject(callControlsViewModel)
            .environmentObject(callDetailsViewModel)
            .environmentObject(gridLayoutViewModel)
            .environmentObject(inCallViewModel)
            .environmentObject(joinLayoutViewModel)
            .environmentObject(toastOverlayViewModel)
            .environmentObject(waitingLayoutViewModel)
    }
}
