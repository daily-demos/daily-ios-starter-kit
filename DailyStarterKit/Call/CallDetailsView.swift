import DailyKit
import SwiftUI

struct CallDetailsView: View {
    // MARK: - Model

    @MainActor
    final class Model: ObservableObject {
        // MARK: - Sort Orders

        // Sort participants by name.
        private static let remoteParticipantSortOrder: (CallParticipant, CallParticipant) -> Bool = {
            $0.username.localizedCaseInsensitiveCompare($1.username) == .orderedAscending
        }

        // MARK: - Initialization

        private let manager: CallManageable

        init(manager: CallManageable) {
            self.manager = manager
            self.participantsCount = manager.participants.count
            self.localParticipant = manager.participants.local
            self.remoteParticipants = manager.participants.remote.values
                .sorted(by: Self.remoteParticipantSortOrder)

            manager.publisher(for: .participants)
                .map(\.count)
                .assign(to: &$participantsCount)

            manager.publisher(for: .participants)
                .map(\.local)
                .assign(to: &$localParticipant)

            manager.publisher(for: .participants)
                .map { participants in
                    // Sort the remote participants whenever they are updated. This should have minimal
                    // overhead because call details are shown infrequently, but we can do this sorting in the
                    // `CallManager` if performance here becomes important.
                    participants.remote.values
                        .sorted(by: Self.remoteParticipantSortOrder)
                }
                .assign(to: &$remoteParticipants)
        }

        // MARK: - Properties

        @Published private(set) var participantsCount: Int
        @Published private(set) var localParticipant: CallParticipant
        @Published private(set) var remoteParticipants: [CallParticipant]
    }

    // MARK: - ParticipantDetailView

    private struct ParticipantDetailView: View {
        let participant: CallParticipant

        var body: some View {
            HStack {
                Text(participant.isLocal ? "You" : participant.username)

                Spacer()

                Image(systemName: participant.hasAudio ? "mic.fill" : "mic.slash.fill")
                    .foregroundColor(participant.hasAudio ? .primary : .red)
            }
        }
    }

    // MARK: - View

    /// A binding presenting views can use to dismiss this view.
    @Binding private(set) var isPresented: Bool

    @EnvironmentObject private var model: Model

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("People (\(model.participantsCount) in call)")

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 48, height: 48)
                        .foregroundColor(.primary)
                }
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 10))

            List {
                ParticipantDetailView(participant: model.localParticipant)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    .listRowSeparator(.hidden)

                ForEach(model.remoteParticipants) { ParticipantDetailView(participant: $0) }
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct CallDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CallDetailsView(
            isPresented: .constant(true)
        )
        .environmentObject(CallDetailsView.Model(manager: FakeCallManager(
            local: .defaultLocal,
            visible: (0 ..< 19).map { CallParticipant(hasAudio: $0.isMultiple(of: 2)) }
        )))
    }
}
#endif
