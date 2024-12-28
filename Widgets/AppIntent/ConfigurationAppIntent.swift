import WidgetKit
import AppIntents

@available(watchOSApplicationExtension 10.0, *)
@available(iOSApplicationExtension 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This widget displays the current week of the semester in TUKE.")
}
