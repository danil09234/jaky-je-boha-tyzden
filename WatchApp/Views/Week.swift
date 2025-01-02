import SwiftUI

struct Week: View {
    let week: Int
    
    var body: some View {
        Text("\(week)")
            .font(.custom("Roboto-Bold", size: 150))
            .foregroundColor(.white)
    }
}

#Preview {
    MainContainer {
        Week(week: 14)
    }
}
