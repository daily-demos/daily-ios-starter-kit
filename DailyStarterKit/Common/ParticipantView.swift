import DailyKit
import SwiftUI

struct ParticipantView: View {
    let participant: CallParticipant
    let shouldShowName: Bool

    init(participant: CallParticipant, shouldShowName: Bool = true) {
        self.participant = participant
        self.shouldShowName = shouldShowName
    }

    private var aspectRatio: CGFloat {
        // Remote participants are shown in square tiles and can be cropped.
        guard participant.isLocal else { return 1 }

        // The local participant is shown without cropping.
        return layout.localVideoAspectRatio
    }

    private var contentMode: ContentMode {
        // Use `fit` for the local participant to prevent cropping.
        participant.isLocal ? .fit : .fill
    }

    @Environment(\.callLayout) private var layout: CallLayout

    var body: some View {
        ZStack {
            Colors.backgroundSecondary

            Image(systemName: "video.slash.fill")
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .opacity(participant.hasVideo ? 0 : 1)

            DailyVideoView(
                track: participant.videoTrack,
                videoScaleMode: participant.videoScaleMode
            )
            .aspectRatio(aspectRatio, contentMode: contentMode)
            .opacity(participant.hasVideo ? 1 : 0)

            VStack {
                Spacer()

                HStack(spacing: 0) {
                    HStack {
                        Image(systemName: participant.hasAudio ? "mic.fill" : "mic.slash")
                            .frame(width: 24, height: 24)

                        if shouldShowName {
                            Text(participant.username)
                                .font(.system(size: 12))
                                .padding(.trailing, 4)
                        }
                    }
                    .padding(4)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.3))

                    Spacer()
                }
            }
        }
        .cornerRadius(16)
    }
}

#if DEBUG
struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Colors.backgroundPrimary
                    .ignoresSafeArea(.all)

                Grid(verticalSpacing: 8) {
                    Group {
                        GridRow {
                            ParticipantView(
                                participant: .defaultLocal, shouldShowName: false
                            )
                        }

                        GridRow {
                            ParticipantView(participant: CallParticipant(hasVideo: true))
                        }

                        GridRow {
                            ParticipantView(participant: CallParticipant(hasVideo: false))
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .previewDisplayName("Portrait")
            .previewInterfaceOrientation(.portrait)

            ZStack {
                Colors.backgroundPrimary
                    .ignoresSafeArea(.all)

                Grid(horizontalSpacing: 8) {
                    GridRow {
                        ParticipantView(participant: .defaultLocal, shouldShowName: false)

                        ParticipantView(participant: CallParticipant(hasVideo: true))

                        ParticipantView(participant: CallParticipant(hasVideo: false))
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .previewDisplayName("Landscape")
            .previewInterfaceOrientation(.landscapeRight)
            .callLayout(.landscape)
        }
    }
}
#endif
