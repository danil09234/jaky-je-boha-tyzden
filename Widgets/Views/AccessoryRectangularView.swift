import SwiftUI

struct AccessoryRectangularView: View {
    let displayState: DisplayState

    var body: some View {
        ContainerBackgroundWrapper {
            switch displayState {
            case .week(let week):
                ViewThatFits {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                        VStack {
                            Text("TUKE")
                                .foregroundColor(.red)
                                .bold()
                            Text("Week")
                                .foregroundColor(.gray)
                        }
                        Text("\(week)")
                            .font(.title)
                            .bold()
                    }
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.title)
                        VStack {
                            Text("TUKE")
                                .font(.caption)
                                .foregroundColor(.red)
                                .bold()
                            Text("Week")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("\(week)")
                            .font(.title)
                            .bold()
                    }
                }
            case .specialCase(let state):
                HStack(spacing: 10) {
                    Image(systemName: state.iconName)
                        .font(.title)
                        .foregroundColor(state.color)
                    Text(state.shortDescription)
                        .font(.headline)
                }
            case .displayNone:
                Text("-")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}
