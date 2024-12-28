import SwiftUI

struct AccessoryInlineView: View {
    let displayState: DisplayState

    var body: some View {
        containerBackgroundIfAvailable {
            switch displayState {
            case .week(let week):
                Text("Week \(week)")
                    .font(.headline)
                    .foregroundColor(.primary)
            case .specialCase(let state):
                HStack {
                    Image(systemName: state.iconName)
                        .foregroundColor(state.color)
                    Text(state.shortDescription)
                        .font(.caption)
                        .foregroundColor(state.color)
                }
            case .displayNone:
                Text("-")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    @ViewBuilder
    private func containerBackgroundIfAvailable<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content()
                .containerBackground(for: .widget) {}
        } else {
            content()
        }
    }
}
