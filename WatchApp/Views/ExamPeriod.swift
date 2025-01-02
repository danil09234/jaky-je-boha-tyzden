import SwiftUI
import AppCore

struct ExamPeriod: View {
    let endOfExams: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.green)
            Text(
                """
                Veľa šťastia na skúškach!\n
                Skúšky sa končia \(endOfExams)
                """
            )
            .multilineTextAlignment(.center)
            .font(.custom("Roboto-Bold", size: 14))
            .foregroundColor(.white)
        }
    }
}

#Preview {
    MainContainer {
        ExamPeriod(
            endOfExams: "09.02.2025"
        )
    }
}
