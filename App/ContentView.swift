import FamilyControls
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = InterrupterViewModel()
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.isAuthorized {
                    settingsSections
                } else {
                    authorizationSection
                }
            }
            .navigationTitle("Doom Scroll Interrupter")
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var authorizationSection: some View {
        Section {
            Text("This app needs Screen Time access to interrupt the apps you choose.")
            Button("Grant Screen Time Access") {
                Task { await viewModel.requestAuthorization() }
            }
        }
    }

    @ViewBuilder
    private var settingsSections: some View {
        Section("Apps to interrupt") {
            Button(viewModel.hasSelection ? "Change selection" : "Choose apps") {
                isPickerPresented = true
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.selection)
            .onChange(of: viewModel.selection) { _ in viewModel.applyChangesIfMonitoring() }
        }

        Section("Interrupt me after") {
            Stepper(
                "\(viewModel.thresholdMinutes) min of use",
                value: $viewModel.thresholdMinutes,
                in: InterruptionSettings.minimumMinutes...120
            )
            .onChange(of: viewModel.thresholdMinutes) { _ in viewModel.applyChangesIfMonitoring() }
        }

        Section {
            Toggle("Interruptions on", isOn: monitoringBinding)
                .disabled(!viewModel.hasSelection)
        } footer: {
            Text("When time is up you can close the app or choose to keep going. Keeping going starts a fresh countdown.")
        }
    }

    private var monitoringBinding: Binding<Bool> {
        Binding(get: { viewModel.isMonitoring }, set: { viewModel.setMonitoring($0) })
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}
