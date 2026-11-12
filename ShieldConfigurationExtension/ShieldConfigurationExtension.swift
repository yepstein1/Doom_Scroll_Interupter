import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Defines what the interruption screen looks like.
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        interruptionScreen()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        interruptionScreen()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        interruptionScreen()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        interruptionScreen()
    }

    private func interruptionScreen() -> ShieldConfiguration {
        let minutes = InterruptionSettings().thresholdMinutes
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(text: "Still scrolling?", color: .label),
            subtitle: ShieldConfiguration.Label(
                text: "You've been at it for \(minutes) minutes. Is this how you want to spend your time?",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close app", color: .white),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Keep going", color: .secondaryLabel)
        )
    }
}
