import Combine
import DailyKit
import SwiftUI
import UniformTypeIdentifiers

struct WaitingLayoutView: View {
    // MARK: - Model

    @MainActor
    final class Model: ObservableObject {
        // MARK: - Initialization

        private let callManager: CallManageable
        private let toastManager: ToastManager
        private var url: URL? = nil
        private var subscriptions: Set<AnyCancellable> = []

        init(callManager: CallManageable, toastManager: ToastManager) {
            self.callManager = callManager
            self.toastManager = toastManager
            self.url = callManager.url
            self.localParticipant = callManager.participants.local

            callManager.publisher(for: .participants)
                .map(\.local)
                .assign(to: &$localParticipant)

            callManager.publisher(for: .url)
                .sink { [weak self] url in
                    guard let self else { return }

                    self.url = url
                }
                .store(in: &subscriptions)
        }

        // MARK: - Properties

        @Published private(set) var localParticipant: CallParticipant
        @Published private(set) var toastOpacity: CGFloat = 0

        // MARK: - Actions

        func copyLinkButtonTapped() {
            guard let url = self.url else { return }

            UIPasteboard.general.setValue(url, forPasteboardType: UTType.url.identifier)

            toastManager.showToast(Toast(imageName: "link", message: "Link copied to clipboard!"))
        }
    }

    // MARK: - View

    @EnvironmentObject private var model: Model

    @Environment(\.callLayout) private var layout: CallLayout

    var body: some View {
        ZStack {
            Colors.backgroundPrimary
                .ignoresSafeArea()

            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Waiting for others to join")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    ParticipantView(participant: model.localParticipant)
                        .aspectRatio(layout.localVideoAspectRatio, contentMode: .fit)

                    Button {
                        model.copyLinkButtonTapped()
                    } label: {
                        Text("Copy link to invite")
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PrimaryButtonStyle())
                }
                .fixedSize(horizontal: layout == .landscape, vertical: false)

                Spacer()
            }
            .padding(padding)
        }
    }

    private var padding: EdgeInsets {
        switch layout {
        case .portrait:
            return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        case .landscape:
            return EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        }
    }

}

// MARK: - Previews

#if DEBUG
struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            Group {
                WaitingLayoutView()
                    .previewDisplayName("iPhone Portrait")
                    .previewInterfaceOrientation(.portrait)

                WaitingLayoutView()
                    .previewDisplayName("iPhone Landscape")
                    .previewInterfaceOrientation(.landscapeRight)
                    .callLayout(.landscape)

                WaitingLayoutView()
                    .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
                    .previewDisplayName("iPad Portrait")
                    .previewInterfaceOrientation(.portrait)

                WaitingLayoutView()
                    .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
                    .previewDisplayName("iPad Landscape")
                    .previewInterfaceOrientation(.landscapeRight)
                    .callLayout(.landscape)
            }
        }
    }
}
#endif
