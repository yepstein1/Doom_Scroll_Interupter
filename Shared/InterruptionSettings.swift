import FamilyControls
import Foundation

/// User settings persisted in the shared App Group so the app and all
/// extensions read the same values.
struct InterruptionSettings {
    static let minimumMinutes = 1
    static let defaultMinutes = 5

    private enum Key {
        static let thresholdMinutes = "thresholdMinutes"
        static let selection = "activitySelection"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = UserDefaults(suiteName: AppGroup.identifier) ?? .standard) {
        self.defaults = defaults
    }

    /// Minutes of use (of the selected apps) before the interruption appears.
    var thresholdMinutes: Int {
        get {
            let stored = defaults.integer(forKey: Key.thresholdMinutes)
            return stored >= Self.minimumMinutes ? stored : Self.defaultMinutes
        }
        nonmutating set {
            defaults.set(max(newValue, Self.minimumMinutes), forKey: Key.thresholdMinutes)
        }
    }

    /// The apps, categories and websites the user wants interrupted.
    var selection: FamilyActivitySelection {
        get {
            guard let data = defaults.data(forKey: Key.selection),
                  let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            else { return FamilyActivitySelection() }
            return decoded
        }
        nonmutating set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: Key.selection)
        }
    }
}
