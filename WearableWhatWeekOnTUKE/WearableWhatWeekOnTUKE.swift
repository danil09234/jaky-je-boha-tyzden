import AppIntents

struct WearableWhatWeekOnTUKE: AppIntent {
    static var title: LocalizedStringResource = "WearableWhatWeekOnTUKE"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
