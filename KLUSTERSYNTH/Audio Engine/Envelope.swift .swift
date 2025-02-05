//
//  Envelope.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation
import AVFoundation

class Envelope: ObservableObject {
    // ADSR Parameters
    @Published var attack: Float = KLUSTERSYNTH.EnvelopeParameters.attackRange.defaultValue
    @Published var decay: Float = KLUSTERSYNTH.EnvelopeParameters.decayRange.defaultValue
    @Published var sustain: Float = KLUSTERSYNTH.EnvelopeParameters.sustainRange.defaultValue
    @Published var release: Float = KLUSTERSYNTH.EnvelopeParameters.releaseRange.defaultValue
    
    // LFO Parameters
    @Published var lfoType: Int = 0        // 0: OFF, 1: SINE, 2: TRI, 3: PLS
    @Published var lfoRateF: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    @Published var lfoRateC: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    @Published var lfoDepth: Float = KLUSTERSYNTH.LFOParameters.depthRange.defaultValue
    @Published var lfoWidth: Float = 0.5
    
    // Mix Control
    @Published var mix: Float = 0.5    // Mix between LFO and ADSR
    
    // Module State
    @Published var mode: Int = 0       // 0: ENV1, 1: ENV2
    @Published var isActive: Bool = false
    
    // Internal State
    private var currentLevel: Float = 0.0
    private var phase: Double = 0.0
    private var sampleRate: Double = 44100.0
    private var currentStage: EnvelopeStage = .idle
    private var releaseLevel: Float = 0.0
    private var sampleTime: Double = 0.0
    
    enum EnvelopeStage {
        case idle, attack, decay, sustain, release
    }
    
    init() {
        setupEnvelope()
    }
    
    private func setupEnvelope() {
        sampleTime = 1.0 / sampleRate
    }
    
    func noteOn(velocity: Float = 1.0) {
        isActive = true
        currentStage = .attack
        if currentStage == .release {
            // Start from current level if key was pressed during release
            releaseLevel = currentLevel
        } else {
            // Start from zero
            currentLevel = 0.0
        }
    }
    
    func noteOff() {
        releaseLevel = currentLevel
        currentStage = .release
    }
    
    func getValue() -> Float {
        // Get base envelope value
        let envelopeValue = processEnvelope()
        
        // Get LFO value
        let lfoValue = processLFO()
        
        // Mix envelope and LFO
        return envelopeValue * (1 - mix) + lfoValue * mix
    }
    
    private func processEnvelope() -> Float {
        switch currentStage {
        case .idle:
            currentLevel = 0.0
            
        case .attack:
            currentLevel += Float(sampleTime) / attack
            if currentLevel >= 1.0 {
                currentLevel = 1.0
                currentStage = .decay
            }
            
        case .decay:
            let decayAmount = Float(sampleTime) / decay
            currentLevel -= decayAmount * (1.0 - sustain)
            if currentLevel <= sustain {
                currentLevel = sustain
                currentStage = .sustain
            }
            
        case .sustain:
            currentLevel = sustain
            
        case .release:
            let releaseAmount = Float(sampleTime) / release
            currentLevel -= releaseAmount * releaseLevel
            if currentLevel <= 0.0 {
                currentLevel = 0.0
                currentStage = .idle
                isActive = false
            }
        }
        
        return currentLevel
    }
    
    private func processLFO() -> Float {
        if lfoType == 0 { return 0.0 } // OFF
        
        // Advance LFO phase
        let lfoFreq = lfoRateF + lfoRateC
        phase += Double(lfoFreq) * sampleTime
        if phase >= 1.0 { phase -= 1.0 }
        
        // Generate base waveform
        let baseValue: Float
        switch lfoType {
        case 1: // Sine
            baseValue = sin(2.0 * Float.pi * Float(phase))
        case 2: // Triangle
            baseValue = 2.0 * abs(2.0 * Float(phase) - 1.0) - 1.0
        case 3: // Pulse
            baseValue = Float(phase) < lfoWidth ? 1.0 : -1.0
        default:
            baseValue = 0.0
        }
        
        // Apply depth
        return baseValue * lfoDepth * 0.5 + 0.5 // Normalize to 0-1 range
    }
    
    // Returns true if envelope is currently producing a non-zero value
    var isGenerating: Bool {
        return currentStage != .idle || currentLevel > 0
    }
}
