import SwiftUI

struct AccessoryCircularView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
            switch displayState {
            case .week(let week):
                VStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("\(week)")
                        .font(.largeTitle)
                        .widgetAccentable()
                        .bold()
                }
            case .specialCase(let state):
                ViewThatFits(in: .horizontal) {
                    VStack {
                        Image(systemName: state.iconName)
                            .font(.headline)
                            .foregroundColor(state.color)
                        Text(state.shortDescription)
                            .font(.caption)
                    }
                    Image(systemName: state.iconName)
                        .font(.largeTitle)
                        .foregroundColor(state.color)
                }
            case .displayNone:
                Text("-")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}
