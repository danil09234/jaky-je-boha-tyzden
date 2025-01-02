import SwiftUI
import AppCore

struct DefaultWidgetView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
            Text("Default View")
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
