//
//  Filter.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

//
//  Filter.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation
import AVFoundation

class Filter: ObservableObject {
    private var filterNode: AVAudioNode!
    private var sampleRate: Double = 44100.0
    
    // Published properties for UI binding
    @Published var mode: Int = 0               // 0: Filter 1, 1: Filter 2
    @Published var path: Int = 0               // 0: THRU, 1: ENV, 2: ENV1, 3: BEAT
    @Published var lfoType: Int = 0            // 0: SINE, 1: TRI, 2: SAW, 3: PLS
    
    // LFO Parameters
    @Published var rateF: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    @Published var rateC: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    @Published var depthF: Float = KLUSTERSYNTH.FilterParameters.modDepthRange.defaultValue
    @Published var depthC: Float = KLUSTERSYNTH.FilterParameters.modDepthRange.defaultValue
    
    // Filter Parameters
    @Published var cutoff: Float = KLUSTERSYNTH.FilterParameters.cutoffRange.defaultValue
    @Published var resonance: Float = KLUSTERSYNTH.FilterParameters.resonanceRange.defaultValue
    @Published var amountToDelay: Float = 0.5
    
    // Internal state
    private var phase: Double = 0.0
    private var lastFilteredSamples: [Float] = [0.0, 0.0]  // For resonance feedback
    
    init() {
        setupFilterNode()
    }
    
    private func setupFilterNode() {
        // Create an AudioUnit node for the filter
        filterNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buffer = ablPointer[0]
            let ptr = buffer.mData?.assumingMemoryBound(to: Float.self)
            
            // Process each sample
            for frame in 0..<Int(frameCount) {
                if let inputSample = ptr?[frame] {
                    ptr?[frame] = self.processSample(inputSample)
                }
            }
            
            return noErr
        }
    }
    
    private func processSample(_ input: Float) -> Float {
        // Calculate LFO modulation
        let lfoValue = generateLFO()
        
        // Apply LFO to cutoff frequency
        let modifiedCutoff = calculateModulatedCutoff(lfoValue)
        
        // Apply filter based on current mode
        let output = applyFilter(input, cutoffFreq: modifiedCutoff)
        
        return output
    }
    
    private func generateLFO() -> Float {
        // Advance LFO phase
        let lfoFreq = rateF + rateC
        phase += 1.0 / sampleRate * Double(lfoFreq)
        if phase >= 1.0 { phase -= 1.0 }
        
        // Generate LFO waveform
        switch lfoType {
        case 0: // Sine
            return sin(2.0 * Float.pi * Float(phase))
        case 1: // Triangle
            return 2.0 * abs(2.0 * Float(phase) - 1.0) - 1.0
        case 2: // Saw
            return 2.0 * Float(phase) - 1.0
        case 3: // Pulse
            return Float(phase) < 0.5 ? 1.0 : -1.0
        default:
            return 0.0
        }
    }
    
    private func calculateModulatedCutoff(_ lfoValue: Float) -> Float {
        let depth = depthF + depthC
        let modAmount = lfoValue * depth
        
        // Calculate modulated cutoff frequency
        let modifiedCutoff = cutoff * pow(2, Float(modAmount))
        
        // Clamp to valid range
        return min(max(modifiedCutoff,
                      KLUSTERSYNTH.FilterParameters.cutoffRange.min),
                  KLUSTERSYNTH.FilterParameters.cutoffRange.max)
    }
    
    private func applyFilter(_ input: Float, cutoffFreq: Float) -> Float {
        // Calculate filter coefficients
        let omega = 2.0 * Float.pi * cutoffFreq / Float(sampleRate)
        let alpha = sin(omega) / (2.0 * resonance)
        
        // Implement 2-pole low-pass filter
        let a0 = 1.0 + alpha
        let a1 = -2.0 * cos(omega)
        let a2 = 1.0 - alpha
        let b0 = (1.0 - cos(omega)) / 2.0
        let b1 = 1.0 - cos(omega)
        let b2 = (1.0 - cos(omega)) / 2.0
        
        // Apply filter
        let output = (b0 * input + b1 * lastFilteredSamples[0] + b2 * lastFilteredSamples[1]) -
                    (a1 * lastFilteredSamples[0] + a2 * lastFilteredSamples[1])
        
        // Update filter state
        lastFilteredSamples[1] = lastFilteredSamples[0]
        lastFilteredSamples[0] = output
        
        return output / a0
    }
    
    func getAudioNode() -> AVAudioNode {
        return filterNode
    }
}
