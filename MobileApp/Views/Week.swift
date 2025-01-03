import SwiftUI

struct Week: View {
    let week: Int
    
    var body: some View {
        Text("\(week)")
            .font(.custom("Roboto-Bold", size: 280))
    }
}

#Preview {
    Week(week: 14)
}
