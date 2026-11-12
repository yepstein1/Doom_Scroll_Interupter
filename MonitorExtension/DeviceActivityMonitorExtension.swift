import DeviceActivity

/// Runs in the background. When the usage threshold is reached, raise the shield.
final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        MonitoringController.applyShield()
    }
}
