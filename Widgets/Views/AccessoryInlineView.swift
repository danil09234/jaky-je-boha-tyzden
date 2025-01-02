import SwiftUI
import AppCore

struct AccessoryInlineView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
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
}
