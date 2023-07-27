import AVKit
import Combine
import DailyKit
import SwiftUI

struct CallControlsOverlayView: View {
    // MARK: - Model

    @MainActor
    final class Model: ObservableObject {
        // MARK: - Initialization

        private let manager: CallManageable
        private var camera: CallCamera
        private var subscriptions: Set<AnyCancellable> = []

        init(manager: CallManageable) {
            self.manager = manager
            self.camera = manager.camera

            manager.publisher(for: .camera)
                .sink { [weak self] camera in
                    guard let self else { return }

                    // We assign the `camera` value directly instead of using `assign(to:)` because the view
                    // does not need to be updated when the value changes.
                    self.camera = camera
                }
                .store(in: &subscriptions)
        }

        // MARK: - Properties

        @Published var isCallDetailsViewPresented: Bool = false

        // MARK: - Actions

        func cameraButtonTapped() {
            manager.flipCamera(camera)
        }

        func moreButtonTapped() {
            isCallDetailsViewPresented = true
        }
    }

    // MARK: - RoutePickerButton

    private struct RoutePickerButton<Content: View>: View {
        /// The custom label to be shown over the route picker button.
        @ViewBuilder let label: () -> Content

        var body: some View {
            ZStack {
                label()

                RoutePickerView()
            }
        }
    }

    // MARK: - RoutePickerView

    private struct RoutePickerView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIView {
            let view = AVRoutePickerView()
            // Set all colors to clear, so we can show a custom icon for the button.
            view.backgroundColor = .clear
            view.activeTintColor = .clear
            view.tintColor = .clear
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }

    // MARK: - View

    @EnvironmentObject private var model: Model

    @Environment(\.callLayout) private var layout: CallLayout

    var body: some View {
        ZStack {
            // Top and bottom scrims for the call controls.
            VStack {
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .bottom, endPoint: .top)
                    .frame(height: 200)

                Spacer()

                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 200)
            }
            .ignoresSafeArea()
            // Disable hit testing, so the scrims do not intercept touch events for underlying views.
            .allowsHitTesting(false)

            VStack {
                HStack {
                    HStack(spacing: 0) {
                        Button {
                            model.cameraButtonTapped()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                        .frame(width: 44, height: 44)

                        RoutePickerButton {
                            Image(systemName: "airplayvideo")
                                .font(.system(size: 18))
                                .padding(.top, 2)
                                .foregroundColor(.black)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .frame(width: 104, height: 56)
                    .background(.white)
                    .contentShape(Capsule())
                    // Set the `clipShape`, so touches outside the capsule are not intercepted.
                    .clipShape(Capsule())

                    Spacer()

                    Button {
                        model.moreButtonTapped()
                    } label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 56, height: 56)
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                    .background(.white)
                    .contentShape(Circle())
                    // Set the `clipShape`, so touches outside the capsule are not intercepted.
                    .clipShape(Circle())
                }

                Spacer()

                CallControlsView(shouldShowLeaveButton: true)
            }
            .padding(padding)
            // Ignore the keyboard safe area, so the call controls are not pushed up with the keyboard.
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $model.isCallDetailsViewPresented) {
            CallDetailsView(isPresented: $model.isCallDetailsViewPresented)
        }
    }

    private var padding: EdgeInsets {
        switch layout {
        case .portrait:
            return EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        case .landscape:
            // With default padding the top and bottom of the overlay do not stay within the safe area in
            // landscape, so we increase the insets here.
            return EdgeInsets(top: 30, leading: 16, bottom: 9, trailing: 16)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CallControlsOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            Group {
                ZStack {
                    Text("In a call...")

                    CallControlsOverlayView()
                }
                .previewDisplayName("Portrait")
                .previewInterfaceOrientation(.portrait)

                ZStack {
                    Text("In a call...")

                    CallControlsOverlayView()
                }
                .previewDisplayName("Landscape")
                .previewInterfaceOrientation(.landscapeRight)
                .callLayout(.landscape)
            }
        }
    }
}
#endif
