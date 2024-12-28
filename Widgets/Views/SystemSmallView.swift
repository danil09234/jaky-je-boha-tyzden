import SwiftUI

struct SystemSmallView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
            switch displayState {
            case .week(let week):
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Text("TUKE")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                        Text("Week")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    Text("\(week)")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .frame(height: heightForFontSize(size: 96))
                }
            case .specialCase(let state):
                VStack(spacing: 10) {
                    Image(systemName: state.iconName)
                        .font(.largeTitle)
                        .foregroundColor(state.color)
                    Text(state.detailedDescription)
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
            case .displayNone:
                VStack {
                    Text("-")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func heightForFontSize(size: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: size)
        return font.capHeight
    }
}
