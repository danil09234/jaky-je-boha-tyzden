import SwiftUI

struct DisplayNone: View {
    var body: some View {
        Text("...")
            .multilineTextAlignment(.center)
            .font(.custom("Roboto-Bold", size: 24))
    }
}

#Preview {
    DisplayNone()
}
