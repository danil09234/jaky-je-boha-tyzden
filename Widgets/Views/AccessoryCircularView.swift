import SwiftUI

struct AccessoryCircularView: View {
    let displayState: DisplayState

    var body: some View {
        containerBackgroundIfAvailable {
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
    
    @ViewBuilder
    private func containerBackgroundIfAvailable<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content()
                .containerBackground(for: .widget) { }
        } else {
            content()
        }
    }
}
