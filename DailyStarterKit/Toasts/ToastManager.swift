import SwiftUI

/// A manager used to show toasts.
final class ToastManager: ObservableObject {
    private enum Constants {
        /// The length of time for which to show a toast.
        static let toastVisibilityDuration: Duration = .seconds(3)
    }

    // MARK: - Properties

    @Published private(set) var toast: Toast?

    // MARK: - Actions

    /// Show the specified toast.
    ///
    /// Calling this method while a toast is already visible will have no effect.
    ///
    /// - Parameter toast: the toast to show.
    func showToast(_ toast: Toast) {
        guard self.toast == nil else { return }

        self.toast = toast

        Task { @MainActor in
            try await Task.sleep(for: Constants.toastVisibilityDuration)

            self.toast = nil
        }
    }
}
