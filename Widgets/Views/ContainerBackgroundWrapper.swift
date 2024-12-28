import SwiftUI
import WidgetKit

struct ContainerBackgroundWrapper<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {}
        } else {
            content
        }
    }
}
