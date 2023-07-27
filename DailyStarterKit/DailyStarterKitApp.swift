import DailyKit
import SwiftUI

@main
struct DailyStarterKitApp: App {
    var body: some Scene {
        WindowGroup {
            ContextView(callManager: CallManager.live) {
                CallContainerView()
            }
        }
    }
}
