# Doom Scroll Interrupter

An iPhone app that interrupts you after a set amount of time in apps you choose. When time is up, the app is covered by a screen with two choices: **Close app** or **Keep going** (which starts a fresh countdown).

iOS can't detect scrolling inside other apps, so this uses Apple's Screen Time APIs (FamilyControls, DeviceActivity, ManagedSettings) and treats continuous usage time as the signal.

## Structure

| Folder | Purpose |
| --- | --- |
| `App/` | SwiftUI app: pick apps, set minutes, toggle on/off |
| `MonitorExtension/` | Background extension: raises the shield when the threshold is hit |
| `ShieldConfigurationExtension/` | Look and text of the interruption screen |
| `ShieldActionExtension/` | What the two buttons do |
| `Shared/` | Settings storage and monitoring logic used by all targets |
| `project.yml` | XcodeGen project definition (the `.xcodeproj` is generated, not committed) |

## Setup on the Mac

1. Install tools: Xcode (App Store) and XcodeGen (`brew install xcodegen`).
2. Pick your own identifiers. Replace `com.example` with your own reverse-domain prefix in `project.yml` (bundle IDs, App Group) and in `Shared/AppGroup.swift`. Keep them consistent.
3. Set `DEVELOPMENT_TEAM` in `project.yml` to your Apple Developer Team ID.
4. Generate the project: `xcodegen generate`, then open `DoomScrollInterrupter.xcodeproj`.
5. Request the Family Controls entitlement. In Xcode, check "Automatically manage signing" for all four targets. For development this works with a paid developer account. To distribute via TestFlight or the App Store, request the **Family Controls (Distribution)** entitlement from Apple: https://developer.apple.com/contact/request/family-controls-distribution
6. Run on a **real iPhone**. Screen Time APIs don't work in the Simulator. Tap "Grant Screen Time Access", choose apps, set the minutes, and switch interruptions on.

## Things to verify on a device

This was written without a Mac to test on, so expect to adjust small things:

- The threshold fires on usage of the selected apps. Try a 1-minute setting first.
- After "Keep going", the shield should lift and re-arm. If the shield lingers, change `.defer` to `.none` in `ShieldActionExtension.swift`.
- Extension logs are easiest to read via Console.app with the iPhone connected.
