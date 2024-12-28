import SwiftUI
import AppCore

enum DisplayState {
    case week(Int)
    case specialCase(SemesterState)
    case displayNone
}
