import SwiftUI

struct DefaultWidgetView: View {
    let displayState: DisplayState

    var body: some View {
        containerBackgroundIfAvailable {
            Text("Default View")
                .font(.headline)
                .foregroundColor(.primary)
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
