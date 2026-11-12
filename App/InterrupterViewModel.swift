import FamilyControls
import SwiftUI

@MainActor
final class InterrupterViewModel: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet { settings.selection = selection }
    }
    @Published var thresholdMinutes: Int {
        didSet { settings.thresholdMinutes = thresholdMinutes }
    }
    @Published private(set) var isMonitoring: Bool
    @Published private(set) var isAuthorized: Bool
    @Published var errorMessage: String?

    private let settings = InterruptionSettings()

    init() {
        selection = settings.selection
        thresholdMinutes = settings.thresholdMinutes
        isMonitoring = MonitoringController.isMonitoring
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            errorMessage = "Screen Time access was not granted: \(error.localizedDescription)"
        }
    }

    func setMonitoring(_ enabled: Bool) {
        do {
            if enabled {
                try MonitoringController.start(settings: settings)
            } else {
                MonitoringController.stop()
            }
            isMonitoring = enabled
        } catch {
            errorMessage = "Could not start monitoring: \(error.localizedDescription)"
            isMonitoring = MonitoringController.isMonitoring
        }
    }

    /// Applies a changed threshold or selection to an already-running monitor.
    func applyChangesIfMonitoring() {
        guard isMonitoring else { return }
        setMonitoring(true)
    }
}
