import SwiftUI
import Foundation
import AppCore

struct WinterBreak: View {
    let endOfBreak, examPeriodStart: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "snowflake")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)
            Text(
                """
                Veselé sviatky!\n
                Prestávka do \(endOfBreak).
                Skúšky od \(examPeriodStart).
                """
            )
            .multilineTextAlignment(.center)
            .font(.custom("Roboto-Bold", size: 24))
            .foregroundColor(.white)
        }
    }
}

#Preview {
    MainContainer {
        WinterBreak(
            endOfBreak: "01.01.2025",
            examPeriodStart: "02.01.2025"
        )
    }
}
