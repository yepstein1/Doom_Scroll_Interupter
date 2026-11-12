# Doom Scroll Interrupter: project context

iPhone app (Swift/SwiftUI, iOS 16+) that interrupts the user after N minutes of use of chosen apps. The shield screen offers **Close app** or **Keep going** (restarts the countdown). The threshold is user-adjustable.

iOS cannot detect scrolling in other apps. The app uses the Screen Time APIs (FamilyControls, DeviceActivity, ManagedSettings, ManagedSettingsUI) and treats usage time as the signal.

## History
The code was first written on Windows with no Xcode, so **it has never been compiled or run**. Expect small compile errors and API-detail fixes on the first build. Fix them directly, and keep fixes minimal.

## Layout
- `project.yml`: XcodeGen definition. The `.xcodeproj` is generated and gitignored. After adding or removing files or targets, run `xcodegen generate`.
- `App/`: SwiftUI UI (`ContentView`) and `InterrupterViewModel`.
- `MonitorExtension/`: `DeviceActivityMonitor` subclass. On threshold, calls `MonitoringController.applyShield()`.
- `ShieldConfigurationExtension/`: the shield screen's look and text.
- `ShieldActionExtension/`: button handling. Primary = `.close`. Secondary = `MonitoringController.resume()` then `.defer`.
- `Shared/`: compiled into the app and all three extensions.
  - `AppGroup.swift`: App Group ID.
  - `InterruptionSettings.swift`: threshold and app selection, stored in App Group `UserDefaults`.
  - `MonitoringController.swift`: start/stop monitoring, apply/remove shield.

## Build and run
1. `brew install xcodegen`, then `xcodegen generate`, then open `DoomScrollInterrupter.xcodeproj`.
2. Replace the `com.example` prefix with the user's own prefix in **both** `project.yml` and `Shared/AppGroup.swift`. The bundle IDs and the App Group ID must stay consistent across all four targets.
3. Set `DEVELOPMENT_TEAM` in `project.yml` and use automatic signing.
4. Run on a **real iPhone**. Screen Time APIs do not work in the Simulator.
5. Distribution (TestFlight/App Store) needs Apple's Family Controls (Distribution) entitlement, which must be requested separately. Local device testing does not.

## Constraints to remember
- Extensions are sandboxed and memory-limited. Keep their code small and keep UI work out of them.
- The app and extensions share state only through the App Group (`InterruptionSettings`). No other shared state exists.
- Selected apps appear only as opaque tokens (`ApplicationToken` and similar). Names and bundle IDs are not readable, so don't try to display them as text. Use `Label(token)` in SwiftUI if needed.
- Monitoring restarts reset the usage counter. That is how "Keep going" re-arms the countdown.

## Known things to verify on device
- Threshold fires correctly (test with 1 minute).
- After "Keep going", the shield lifts and re-arms. If the shield lingers, switch `.defer` to `.none` in `ShieldActionExtension`.
- Console.app (with the iPhone connected) is the easiest way to see extension logs.

## Coding principles
Global principles (Pragmatic Programmer and Clean Code) live in `~/.claude/CLAUDE.md` on the Windows machine. If this Mac has no global file, apply the same ideas here: DRY, small single-purpose functions, intention-revealing names, comments explain why, fail loudly, no speculative features.
