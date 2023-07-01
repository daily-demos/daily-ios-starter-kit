import Combine
import Daily
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ToastOverlayView: View {
    // MARK: - Model

    final class Model: ObservableObject {
        // MARK: - Initialization

        private let manager: ToastManager

        init(manager: ToastManager) {
            self.manager = manager

            manager.$toast
                .assign(to: &$toast)
        }

        // MARK: - Properties

        @Published private(set) var toast: Toast?
    }

    // MARK: - View

    @EnvironmentObject private var model: Model

    // The iOS 17 default animation.
    private let animation = Animation.spring(response: 0.55, dampingFraction: 1, blendDuration: 0)

    var body: some View {
        VStack {
            if let toast = model.toast {
                HStack {
                    Image(systemName: toast.imageName)

                    Text(toast.message)
                }
                .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                .background(Colors.borderSecondary)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(radius: 8)
                .transition(.opacity.animation(animation))

                Spacer()
            }
        }
        .padding()
    }
}

// MARK: - Previews

#if DEBUG
struct ToastOverlayView_Previews: PreviewProvider {
    struct ContainerView: View {
        let manager: ToastManager

        var body: some View {
            VStack {
                Button("Test Me") {
                    manager.showToast(Toast(imageName: "link", message: "Link copied to clipboard!"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                ToastOverlayView()
            }
        }
    }

    private static let manager = ToastManager()

    static var previews: some View {
        Group {
            ContainerView(manager: manager)
                .previewDisplayName("iPhone Portrait")
                .previewInterfaceOrientation(.portrait)

            ContainerView(manager: manager)
                .previewDisplayName("iPhone Landscape")
                .previewInterfaceOrientation(.landscapeRight)

            ContainerView(manager: manager)
                .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
                .previewDisplayName("iPad Portrait")
                .previewInterfaceOrientation(.portrait)

            ContainerView(manager: manager)
                .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
                .previewDisplayName("iPad Landscape")
                .previewInterfaceOrientation(.landscapeRight)
        }
        .environmentObject(ToastOverlayView.Model(manager: manager))
    }
}
#endif
