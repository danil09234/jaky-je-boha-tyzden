import SwiftUI
import WidgetKit
import AppCore

struct AccessoryCornerView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
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
}

#if os(watchOS)
struct CharacterNameView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryCornerView(displayState: .week(11))
            .previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}
#endif
