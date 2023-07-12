import SwiftUI

struct Colors {
    // rgba(18, 26, 36, 1)
    static var backgroundPrimary = Color(red: 18 / 255, green: 26 / 255, blue: 36 / 255)

    // rgba(31, 45, 61, 1)
    static let backgroundSecondary = Color(red: 31 / 255, green: 45 / 255, blue: 61 / 255)

    // rgba(43, 63, 86, 1)
    static let borderSecondary = Color(red: 43 / 255, green: 63 / 255, blue: 86 / 255)

    static let textPrimary = Color.white

    static let textPrimaryPrompt = Color.white.opacity(0.4)

    // rgba(27, 235, 185, 1)
    static let accent = Color(red: 27 / 255, green: 235 / 255, blue: 185 / 255)
}

#if DEBUG
struct Colors_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Colors.backgroundPrimary
            Colors.backgroundSecondary
            Colors.borderSecondary
            Colors.textPrimary
            Colors.textPrimaryPrompt
            Colors.accent
        }
        .background(.gray)
    }
}
#endif
