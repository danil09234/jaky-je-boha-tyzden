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
                VStack {
#if os(watchOS)
                    Image(systemName: state.iconName)
                        .font(.largeTitle)
                        .foregroundColor(state.color)
#else
                    Image(systemName: state.iconName)
                        .font(.title2)
                        .foregroundColor(state.color)
                    Text(state.shortDescription)
                        .font(.caption)
                        .foregroundColor(state.color)
#endif
                }
            case .displayNone:
                Text("-")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}
