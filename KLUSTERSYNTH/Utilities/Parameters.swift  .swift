//
//  Parameters.swift  .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

// File: Utilities/Parameters.swift

// Make sure this is empty/new and paste this complete code:

import Foundation

// Create a namespace for our synth parameters
enum KLUSTERSYNTH {
    // MARK: - Core Parameter Types
    struct ParameterRange {
        let min: Float
        let max: Float
        let defaultValue: Float
    }

    // MARK: - Module Types
    enum ModuleType {
        case oscillator
        case filter
        case delay
        case envelope
        case pitchMod
    }

    // MARK: - Waveform Types
    enum WaveformType: String, CaseIterable {
        case sine = "SINE"
        case triangle = "TRI"
        case sawtooth = "SAW"
        case pulse = "PLS"
        case noise = "NOISE"
    }

    // MARK: - LFO Parameters
    struct LFOParameters {
        static let rateRange = ParameterRange(min: 0.0, max: 20.0, defaultValue: 1.0)
        static let depthRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.5)
        static let multiplierValues = [1, 2, 4, 8, 16]
    }

    // MARK: - Filter Parameters
    struct FilterParameters {
        static let cutoffRange = ParameterRange(min: 20.0, max: 20000.0, defaultValue: 1000.0)
        static let resonanceRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.0)
        static let modDepthRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.5)
    }

    // MARK: - Delay Parameters
    struct DelayParameters {
        static let timeRange = ParameterRange(min: 0.0, max: 2.0, defaultValue: 0.5)
        static let feedbackRange = ParameterRange(min: 0.0, max: 0.95, defaultValue: 0.5)
        static let mixRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.5)
        static let timeSignatures = ["1/2", "1/4", "1/4T", "1/8", "1/8T", "1/16", "1/16T", "1/32", "1/32T", "1/64"]
    }

    // MARK: - Envelope Parameters
    struct EnvelopeParameters {
        static let attackRange = ParameterRange(min: 0.001, max: 10.0, defaultValue: 0.1)
        static let decayRange = ParameterRange(min: 0.001, max: 10.0, defaultValue: 0.1)
        static let sustainRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.5)
        static let releaseRange = ParameterRange(min: 0.001, max: 10.0, defaultValue: 0.5)
    }

    // MARK: - Mix Parameters
    struct MixParameters {
        static let levelRange = ParameterRange(min: 0.0, max: 1.0, defaultValue: 0.5)
    }
}
