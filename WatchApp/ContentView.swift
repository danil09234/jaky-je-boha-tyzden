import SwiftUI
import AppCore

struct ContentView: View {
    @StateObject private var viewModel = SemesterViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.displayText)
                .font(.custom("Roboto-Bold", size: viewModel.textSize))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#222"))
    }
}

#Preview {
    ContentView()
}
