import SwiftUI

struct AccessoryCornerView: View {
    let displayState: DisplayState

    var body: some View {
        containerBackgroundIfAvailable {
            switch displayState {
            case .week(let week):
                HStack(alignment: .center) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("\(week)")
                        .font(.title)
                        .widgetAccentable()
                        .bold()
                }
            case .specialCase(let state):
                Image(systemName: state.iconName)
                    .widgetAccentable()
                    .bold()
                    .font(.largeTitle)
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
                .containerBackground(for: .widget) { }
        } else {
            content()
        }
    }
}
