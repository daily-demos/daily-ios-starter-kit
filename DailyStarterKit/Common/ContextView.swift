import DailyKit
import SwiftUI

struct ContextView<Content: View>: View {
    @StateObject private var callContainerModel: CallContainerModel
    @StateObject private var callControlsOverlayModel: CallControlsOverlayModel
    @StateObject private var callControlsModel: CallControlsModel
    @StateObject private var callDetailsModel: CallDetailsModel
    @StateObject private var gridLayoutModel: GridLayoutModel
    @StateObject private var inCallModel: InCallModel
    @StateObject private var joinLayoutModel: JoinLayoutModel
    @StateObject private var toastOverlayModel: ToastOverlayModel
    @StateObject private var waitingLayoutModel: WaitingLayoutModel

    private let content: () -> Content

    init(
        callManager: CallManageable,
        toastManager: ToastManager = .live,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._callContainerModel = StateObject(
            wrappedValue: CallContainerModel(manager: callManager)
        )
        self._callControlsOverlayModel = StateObject(
            wrappedValue: CallControlsOverlayModel(manager: callManager)
        )
        self._callControlsModel = StateObject(
            wrappedValue: CallControlsModel(manager: callManager)
        )
        self._callDetailsModel = StateObject(
            wrappedValue: CallDetailsModel(manager: callManager)
        )
        self._gridLayoutModel = StateObject(
            wrappedValue: GridLayoutModel(manager: callManager)
        )
        self._inCallModel = StateObject(
            wrappedValue: InCallModel(manager: callManager)
        )
        self._joinLayoutModel = StateObject(
            wrappedValue: JoinLayoutModel(manager: callManager)
        )
        self._toastOverlayModel = StateObject(
            wrappedValue: ToastOverlayModel(manager: toastManager)
        )
        self._waitingLayoutModel = StateObject(
            wrappedValue: WaitingLayoutModel(callManager: callManager, toastManager: toastManager)
        )

        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(callContainerModel)
            .environmentObject(callControlsOverlayModel)
            .environmentObject(callControlsModel)
            .environmentObject(callDetailsModel)
            .environmentObject(gridLayoutModel)
            .environmentObject(inCallModel)
            .environmentObject(joinLayoutModel)
            .environmentObject(toastOverlayModel)
            .environmentObject(waitingLayoutModel)
    }
}
