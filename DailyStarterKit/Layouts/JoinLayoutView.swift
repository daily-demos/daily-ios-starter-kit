import Combine
import DailyKit
import SwiftUI

// MARK: - Model

@MainActor
final class JoinLayoutModel: ObservableObject {
    // MARK: - Initialization

    private let manager: CallManageable
    private var subscriptions: Set<AnyCancellable> = []

    init(manager: CallManageable) {
        self.manager = manager
        self.localParticipant = manager.participants.local

        setupCallStateSubscription()
        setupParticipantsSubscription()
        setupAdaptiveHEVCSubscription()
    }

    private func setupCallStateSubscription() {
        // Disable the join button in the `joining` and `joined` states.
        manager.publisher(for: .callState)
            .map { [.joining, .joined].contains($0) }
            .assign(to: &$isJoinButtonDisabled)
    }

    private func setupParticipantsSubscription() {
        manager.publisher(for: .participants)
            .map(\.local)
            .assign(to: &$localParticipant)
    }

    private func setupAdaptiveHEVCSubscription() {
        $isAdaptiveHEVCEnabled.sink { [weak self] isAdaptiveHEVCEnabled in
            guard let self else { return }

            self.adaptiveHEVCButtonTapped(isAdaptiveHEVCEnabled)
        }
        .store(in: &subscriptions)
    }

    // MARK: - Properties

    @AppStorage("meetingURL") var meetingURLString: String = "" {
        didSet {
            // Remove the red error border once the user starts typing again.
            isMeetingURLValid = true
        }
    }

    @AppStorage("username") var username: String = ""
    @Published private(set) var localParticipant: CallParticipant
    @Published private(set) var isJoinButtonDisabled: Bool = false
    @Published private(set) var isMeetingURLValid: Bool = true
    @Published var isAdaptiveHEVCEnabled: Bool = false

    // MARK: - Actions

    func joinButtonTapped() {
        guard let meetingURL = validateMeetingURL() else {
            // Show the red error border if the URL was invalid.
            isMeetingURLValid = false
            return
        }

        manager.setUsername(username)
        manager.join(url: meetingURL)

        // Disable the join button immediately to prevent redundant taps.
        isJoinButtonDisabled = true
    }

    func adaptiveHEVCButtonTapped(_ isAdaptiveHEVCEnabled: Bool) {
        manager.toggleAdaptiveHEVC(isAdaptiveHEVCEnabled)
    }

    // Validate the URL String in `meetingURLString` after prepending `https` if needed. A URL is
    // considered valid if it is a subdomain of `daily.co` and has at least one character in the path
    // after the root `/`.
    private func validateMeetingURL() -> URL? {
        let urlString = meetingURLString.hasPrefix("https://") ? meetingURLString : "https://\(meetingURLString)"
        guard let components = URLComponents(string: urlString),
              components.host?.hasSuffix(".daily.co") == true,
              components.path.count >= 2
        else { return nil }

        return components.url
    }
}

// MARK: - View

struct JoinLayoutView: View {
    @EnvironmentObject private var model: JoinLayoutModel
    @Environment(\.callLayout) private var layout: CallLayout

    @FocusState private var inputViewFocusedField: InputViewField?

    // Focusable input fields.
    private enum InputViewField {
        case room, name
    }

    var body: some View {
        ZStack {
            Colors.backgroundPrimary
                .ignoresSafeArea()

            switch layout {
            case .portrait:
                VStack(spacing: 16) {
                    titleView

                    ZStack {
                        participantView

                        VStack {
                            inputView

                            Spacer()
                        }
                        .padding(4)
                    }
                    .aspectRatio(layout.localVideoAspectRatio, contentMode: .fit)

                    buttonView
                }
                .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                .ignoresSafeArea(.keyboard)
            case .landscape:
                VStack(spacing: 0) {
                    titleView

                    HStack(spacing: 16) {
                        VStack(spacing: 16) {
                            inputView

                            buttonView
                        }
                        .frame(maxHeight: .infinity)

                        participantView
                            .frame(maxHeight: .infinity)
                            .aspectRatio(layout.localVideoAspectRatio, contentMode: .fit)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .ignoresSafeArea(.keyboard)
            }
        }
    }

    // MARK: - CallLayout Dependent Subviews

    private var titleView: some View {
        Text("Join meeting")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Room:")
                    .fontWeight(.bold)
                    .foregroundColor(Colors.textPrimaryPrompt)

                TextField(
                    "Meeting URL",
                    text: $model.meetingURLString,
                    prompt:
                        Text(verbatim: "https://meeting.daily.co/example...")
                        .foregroundColor(Colors.textSecondaryPrompt)
                )
                .keyboardType(.URL)
                .submitLabel(.done)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .foregroundColor(Colors.textPrimary)
                .focused($inputViewFocusedField, equals: .room)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.red)
                        .padding(-4)
                        .opacity(model.isMeetingURLValid ? 0 : 1)
                }
            }

            HStack {
                Text("Name:")
                    .fontWeight(.bold)
                    .foregroundColor(Colors.textPrimaryPrompt)

                TextField(
                    "Name",
                    text: $model.username,
                    prompt:
                        Text(verbatim: "Jane Smith...")
                        .foregroundColor(Colors.textSecondaryPrompt)

                )
                .disableAutocorrection(true)
                .submitLabel(.done)
                .foregroundColor(Colors.textPrimary)
                .focused($inputViewFocusedField, equals: .name)
            }

            Toggle(isOn: $model.isAdaptiveHEVCEnabled) {
                Text("Adaptive HEVC:")
                    .fontWeight(.bold)
                    .foregroundColor(Colors.textPrimaryPrompt)
            }
            .tint(Colors.accent)
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(Colors.backgroundPrimary.opacity(0.9))
        .cornerRadius(12)
        .onSubmit {
            inputViewFocusedField = nil
        }
    }

    private var participantView: some View {
        VStack {
            ZStack {
                Text("Setup your camera and mic")
                    .foregroundColor(Colors.textPrimary)

                DailyVideoView(
                    track: model.localParticipant.videoTrack,
                    videoScaleMode: .fit
                )

                VStack {
                    Spacer()

                    CallControlsView(shouldShowLeaveButton: false)
                        .padding()
                }
            }
        }
        .background(Colors.backgroundSecondary)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Colors.borderSecondary, lineWidth: 1)
        )
    }

    private var buttonView: some View {
        Button("Join meeting") {
            model.joinButtonTapped()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(PrimaryButtonStyle())
        .disabled(model.isJoinButtonDisabled)
    }
}

// MARK: - Previews

#if DEBUG
struct JoinView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView(callManager: FakeCallManager()) {
            Group {
                JoinLayoutView()
                    .previewDisplayName("iPhone Portrait")
                    .previewInterfaceOrientation(.portrait)

                JoinLayoutView()
                    .previewDisplayName("iPhone Landscape")
                    .previewInterfaceOrientation(.landscapeRight)
                    .callLayout(.landscape)
            }
        }
    }
}
#endif
