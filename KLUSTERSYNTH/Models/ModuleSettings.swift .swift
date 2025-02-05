//
//  ModuleSettings.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation

class ModuleSettings: ObservableObject {
    // Module States
    @Published var currentModuleState: [KLUSTERSYNTH.ModuleType: Bool] = [
        .oscillator: true,
        .filter: true,
        .delay: true,
        .envelope: true,
        .pitchMod: true
    ]
    
    // Module Routing States
    @Published var moduleRouting: [String: Bool] = [
        "osc1ToFilter": true,
        "osc2ToFilter": true,
        "filterToDelay": true,
        "env1ToOsc2": false,
        "env1ToFilter": false,
        "lfoToDelay": true
    ]
    
    // Default Preset Data Structure
    struct ModulePreset: Codable {
        var oscillatorSettings: OscillatorSettings?
        var filterSettings: FilterSettings?
        var delaySettings: DelaySettings?
        var envelopeSettings: EnvelopeSettings?
        var routingSettings: [String: Bool]
    }
    
    // Individual Module Settings
    struct OscillatorSettings: Codable {
        var waveform: String
        var frequency: Float
        var amplitude: Float
        var lfoAmount: Float
        var lfoRate: Float
    }
    
    struct FilterSettings: Codable {
        var cutoff: Float
        var resonance: Float
        var modDepth: Float
        var lfoRate: Float
    }
    
    struct DelaySettings: Codable {
        var time: Float
        var feedback: Float
        var mix: Float
        var filterFeedback: Float
    }
    
    struct EnvelopeSettings: Codable {
        var attack: Float
        var decay: Float
        var sustain: Float
        var release: Float
        var lfoAmount: Float
    }
    
    // Save current settings as preset
    func savePreset(name: String) {
        let preset = createPresetFromCurrentState()
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(preset)
            
            // Save to UserDefaults or FileSystem
            UserDefaults.standard.set(data, forKey: "KLUSTERSYNTH_PRESET_\(name)")
        } catch {
            print("Error saving preset: \(error)")
        }
    }
    
    // Load preset
    func loadPreset(name: String) -> ModulePreset? {
        if let data = UserDefaults.standard.data(forKey: "KLUSTERSYNTH_PRESET_\(name)") {
            do {
                let decoder = JSONDecoder()
                let preset = try decoder.decode(ModulePreset.self, from: data)
                return preset
            } catch {
                print("Error loading preset: \(error)")
                return nil
            }
        }
        return nil
    }
    
    // Create preset from current state
    private func createPresetFromCurrentState() -> ModulePreset {
        // This would be populated with actual current values from modules
        return ModulePreset(
            oscillatorSettings: OscillatorSettings(
                waveform: "SINE",
                frequency: 440.0,
                amplitude: 0.5,
                lfoAmount: 0.0,
                lfoRate: 1.0
            ),
            filterSettings: FilterSettings(
                cutoff: KLUSTERSYNTH.FilterParameters.cutoffRange.defaultValue,
                resonance: KLUSTERSYNTH.FilterParameters.resonanceRange.defaultValue,
                modDepth: KLUSTERSYNTH.FilterParameters.modDepthRange.defaultValue,
                lfoRate: KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
            ),
            delaySettings: DelaySettings(
                time: KLUSTERSYNTH.DelayParameters.timeRange.defaultValue,
                feedback: KLUSTERSYNTH.DelayParameters.feedbackRange.defaultValue,
                mix: KLUSTERSYNTH.DelayParameters.mixRange.defaultValue,
                filterFeedback: 0.5
            ),
            envelopeSettings: EnvelopeSettings(
                attack: KLUSTERSYNTH.EnvelopeParameters.attackRange.defaultValue,
                decay: KLUSTERSYNTH.EnvelopeParameters.decayRange.defaultValue,
                sustain: KLUSTERSYNTH.EnvelopeParameters.sustainRange.defaultValue,
                release: KLUSTERSYNTH.EnvelopeParameters.releaseRange.defaultValue,
                lfoAmount: KLUSTERSYNTH.LFOParameters.depthRange.defaultValue
            ),
            routingSettings: moduleRouting
        )
    }
    
    // Module state management
    func toggleModule(_ module: KLUSTERSYNTH.ModuleType) {
        currentModuleState[module]?.toggle()
    }
    
    func isModuleActive(_ module: KLUSTERSYNTH.ModuleType) -> Bool {
        return currentModuleState[module] ?? false
    }
    
    // Routing management
    func toggleRouting(_ route: String) {
        moduleRouting[route]?.toggle()
    }
    
    func isRouteActive(_ route: String) -> Bool {
        return moduleRouting[route] ?? false
    }
}
