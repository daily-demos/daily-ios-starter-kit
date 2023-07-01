import DailyKit
import SwiftUI

@main
struct DailyStarterKitApp: App {
    var body: some Scene {
        WindowGroup {
            let callManager = CallManager()
            let toastManager = ToastManager()
            CallContainerView()
                .environmentObject(CallContainerView.Model(manager: callManager))
                .environmentObject(CallControlsOverlayView.Model(manager: callManager))
                .environmentObject(CallControlsView.Model(manager: callManager))
                .environmentObject(CallDetailsView.Model(manager: callManager))
                .environmentObject(GridLayoutView.Model(manager: callManager))
                .environmentObject(InCallView.Model(manager: callManager))
                .environmentObject(JoinLayoutView.Model(manager: callManager))
                .environmentObject(ToastOverlayView.Model(manager: toastManager))
                .environmentObject(WaitingLayoutView.Model(callManager: callManager, toastManager: toastManager))
        }
    }
}
