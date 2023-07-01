import SwiftUI

/// The button style to use for primary buttons, such as the Join button.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Colors.accent)
            .foregroundColor(Colors.backgroundPrimary)
            .font(.system(size: 16, weight: .semibold))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
