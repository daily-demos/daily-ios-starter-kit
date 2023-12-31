import AVFoundation
import DailyKit
import SwiftUI

// MARK: - Model

@MainActor
final class CallControlsModel: ObservableObject {
    // MARK: - Initialization

    private let manager: CallManageable

    init(manager: CallManageable) {
        self.manager = manager
        self.camera = manager.camera
        self.microphone = manager.microphone

        manager.publisher(for: .camera)
            .assign(to: &$camera)

        manager.publisher(for: .microphone)
            .assign(to: &$microphone)
    }

    // MARK: - Properties

    @Published private(set) var camera: CallCamera
    @Published private(set) var microphone: CallMicrophone

    // MARK: - Actions

    func cameraButtonTapped() async {
        guard await manager.isAuthorized(for: .video) else {
            openSettings()
            return
        }

        manager.toggleCamera(camera)
    }

    // Open `Settings.app` to the settings screen for this app that contains the camera and microphone
    // authorization toggles.
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        UIApplication.shared.open(url)
    }

    func microphoneButtonTapped() async {
        guard await manager.isAuthorized(for: .audio) else {
            openSettings()
            return
        }

        manager.toggleMicrophone(microphone)
    }

    func leaveButtonTapped() {
        manager.leave()
    }
}

// MARK: - View

struct CallControlsView: View {
    // MARK: -

    private struct CallControlButtonStyle: ButtonStyle {
        private enum Constants {
            static let leaveButtonForegroundColor: Color = .white
        }

        let isMuted: Bool

        func makeBody(configuration: Configuration) -> some View {
            var backgroundColor: Color {
                // The background color for the leave button.
                guard configuration.role != .destructive else { return .red }

                // The background color for the camera and microphone buttons.
                return .white
            }

            var primaryForegroundColor: Color {
                // The foreground color for the leave button.
                guard configuration.role != .destructive else { return Constants.leaveButtonForegroundColor }

                // The color used for the slash stroke on the camera and microphone buttons when muted.
                return isMuted ? .red : .black
            }

            var secondaryForegroundColor: Color {
                // There is no secondary foreground color for the leave button.
                guard configuration.role != .destructive else { return Constants.leaveButtonForegroundColor }

                // The foreground color used for the camera and microphone buttons.
                return .black
            }

            return configuration.label
                .frame(width: 72, height: 72)
                .background(backgroundColor)
                .foregroundStyle(primaryForegroundColor, secondaryForegroundColor)
                .clipShape(Circle())
        }
    }

    // MARK: -

    @EnvironmentObject private var model: CallControlsModel
    let shouldShowLeaveButton: Bool

    var body: some View {
        HStack {
            Button {
                Task { await model.cameraButtonTapped() }
            } label: {
                Image(systemName: model.camera.isMuted ? "video.slash.fill" : "video.fill")
                    .font(.system(size: 24))
            }
            .buttonStyle(CallControlButtonStyle(isMuted: model.camera.isMuted))

            Button {
                Task { await model.microphoneButtonTapped() }
            } label: {
                Image(systemName: model.microphone.isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 26))
            }
            .buttonStyle(CallControlButtonStyle(isMuted: model.microphone.isMuted))

            if shouldShowLeaveButton {
                Button(role: .destructive) {
                    model.leaveButtonTapped()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 24))
                        .padding(.leading, 2)
                }
                .buttonStyle(CallControlButtonStyle(isMuted: false))
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CallControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            Group {
                CallControlsView(shouldShowLeaveButton: false)
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName("Camera, Microphone")

                CallControlsView(shouldShowLeaveButton: true)
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName("Camera, Microphone, Leave")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Colors.backgroundPrimary)
        }
    }
}
#endif
