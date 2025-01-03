import SwiftUI

struct SummerBreak: View {
    var winterSemesterStart: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.max")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.yellow)
            Text("Vidíme sa \(winterSemesterStart)!")
                .multilineTextAlignment(.center)
                .font(.custom("Roboto-Bold", size: 20))
        }
    }
}

#Preview {
    SummerBreak(winterSemesterStart: "23.09.2024")
}
