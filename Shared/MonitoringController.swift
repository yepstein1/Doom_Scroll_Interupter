import DeviceActivity
import FamilyControls
import ManagedSettings

/// Starts/stops usage monitoring and raises/lowers the shield.
/// Shared by the app (start/stop) and the extensions (shield/resume).
enum MonitoringController {
    private static let activityName = DeviceActivityName("doomScrollWatch")
    private static let thresholdEventName = DeviceActivityEvent.Name("thresholdReached")

    private static let center = DeviceActivityCenter()
    private static let store = ManagedSettingsStore()

    static var isMonitoring: Bool {
        center.activities.contains(activityName)
    }

    /// (Re)starts monitoring. Restarting resets the usage counter, so the next
    /// interruption fires a full threshold from now.
    static func start(settings: InterruptionSettings = InterruptionSettings()) throws {
        let selection = settings.selection
        let wholeDay = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: settings.thresholdMinutes)
        )

        center.stopMonitoring([activityName])
        try center.startMonitoring(activityName, during: wholeDay, events: [thresholdEventName: event])
    }

    static func stop() {
        center.stopMonitoring([activityName])
        removeShield()
    }

    /// Covers the selected apps with the interruption screen.
    static func applyShield(settings: InterruptionSettings = InterruptionSettings()) {
        let selection = settings.selection
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }

    static func removeShield() {
        store.clearAllSettings()
    }

    /// User chose to keep going: lift the shield and start a fresh countdown.
    static func resume() {
        removeShield()
        try? start()
    }
}
