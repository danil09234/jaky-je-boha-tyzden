import SwiftUI

struct SummerBreak: View {
    var nextSemesterStart: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.yellow)
            Text("Vidíme sa \(nextSemesterStart)!")
                .multilineTextAlignment(.center)
                .font(.custom("Roboto-Bold", size: 24))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MainContainer {
        SummerBreak(nextSemesterStart: "23.09.2024")
    }
}
