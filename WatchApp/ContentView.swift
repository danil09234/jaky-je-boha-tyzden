import SwiftUI
import AppCore

struct ContentView: View {
    @ObservedObject public var viewModel: SemesterViewModelBase

    init(viewModel: SemesterViewModelBase = SemesterViewModel()) {
        self.viewModel = viewModel
    }

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

struct ContentView_Previews: PreviewProvider {
    private struct PreviewData {
        let displayName: String
        let timestamp: Double
    }
    
    private static let previewTimelines: [PreviewData] = [
        PreviewData(displayName: "Summer Break", timestamp: 1720569600),
        PreviewData(displayName: "Winter Semester - Week 6", timestamp: 1731196800),
        PreviewData(displayName: "Winter Break", timestamp: 1735325027),
        PreviewData(displayName: "Exam Period", timestamp: 1735689600),
        PreviewData(displayName: "Summer Semester - Week 14", timestamp: 1747267200)
    ]
    
    private static func generateViewModel(from timestamp: Double) -> SemesterViewModelBase {
        return SemesterViewModel(referenceDate: Date(timeIntervalSince1970: timestamp))
    }
    
    static var previews: some View {
        Group {
            ForEach(previewTimelines, id: \.displayName) { preview in
                ContentView(viewModel: generateViewModel(from: preview.timestamp))
                    .previewDisplayName(preview.displayName)
            }
            
            ContentView(viewModel: SemesterViewModel())
                .previewDisplayName("Default")
        }
    }
}
