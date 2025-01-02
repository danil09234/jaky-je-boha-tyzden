import SwiftUI

struct MainContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#222"))
    }
}

#Preview {
    MainContainer {
        Text("Hello, World!")
            .foregroundColor(.white)
    }
}
