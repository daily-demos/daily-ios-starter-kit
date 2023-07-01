import SwiftUI

/// The visual layout of the call UI.
enum CallLayout {
    case portrait, landscape

    /// The aspect ratio to use when showing local video in the UI without cropping.
    ///
    /// - Note: This ratio assumes 720p video and a fullscreen window, which is appropriate for iPhone and
    /// fullscreen iPad apps using the system camera.
    var localVideoAspectRatio: CGFloat {
        switch self {
        case .portrait:
            return 720 / 1280
        case .landscape:
            return 1280 / 720
        }
    }
}

extension CallLayout {
    /// Makes a `CallLayout` based on the specified window size.
    ///
    /// - Parameter size: the size of the window.
    init(_ size: CGSize) {
        self = size.width < size.height ? .portrait : .landscape
    }
}

private struct CallLayoutKey: EnvironmentKey {
    static let defaultValue: CallLayout = .portrait
}

extension EnvironmentValues {
    var callLayout: CallLayout {
        get { self[CallLayoutKey.self] }
        set { self[CallLayoutKey.self] = newValue }
    }
}

extension View {
    /// Sets the environment `callLayout` to the specified value.
    ///
    /// - Parameter callLayout: the call layout value to set.
    /// - Returns: a view with the environment `callLayout` set to the specified value.
    func callLayout(_ callLayout: CallLayout) -> some View {
        environment(\.callLayout, callLayout)
    }
}
