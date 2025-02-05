//
//  Delay.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation
import AVFoundation

class Delay: ObservableObject {
    private var delayNode: AVAudioNode!
    private var sampleRate: Double = 44100.0
    private var delayBuffer: [Float] = []
    private var writeIndex: Int = 0
    
    // Published properties for UI binding
    @Published var mode: Int = 0           // 0: Delay 1, 1: Delay 2
    @Published var timeRateF: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    @Published var timeRateC: Float = KLUSTERSYNTH.LFOParameters.rateRange.defaultValue
    
    // Delay Parameters
    @Published var time: Float = KLUSTERSYNTH.DelayParameters.timeRange.defaultValue {
        didSet {
            updateDelayBuffer()
        }
    }
    @Published var feedback: Float = KLUSTERSYNTH.DelayParameters.feedbackRange.defaultValue
    @Published var mix: Float = KLUSTERSYNTH.DelayParameters.mixRange.defaultValue
    @Published var filterFeedback: Float = 0.5  // Amount of filtered signal fed back
    
    // Time Division
    @Published var selectedTimeSignature: String = "1/4" {
        didSet {
            updateDelayTime()
        }
    }
    
    // LFO Parameters
    @Published var lfoAmount: Float = KLUSTERSYNTH.LFOParameters.depthRange.defaultValue
    @Published var lfoType: Int = 0        // 0: Sine, 1: Triangle, 2: Pulse
    private var phase: Double = 0.0
    
    init() {
        initializeDelayBuffer()
        setupDelayNode()
    }
    
    private func initializeDelayBuffer() {
        let maxDelay = Int(KLUSTERSYNTH.DelayParameters.timeRange.max * Double(sampleRate))
        delayBuffer = Array(repeating: 0.0, count: maxDelay)
    }
    
    private func updateDelayBuffer() {
        let newSize = Int(time * Float(sampleRate))
        if newSize > delayBuffer.count {
            delayBuffer.append(contentsOf: Array(repeating: 0.0, count: newSize - delayBuffer.count))
        }
        writeIndex = writeIndex % newSize
    }
    
    private func setupDelayNode() {
        delayNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
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
        // Calculate modulated delay time
        let lfoValue = generateLFO()
        let modifiedTime = calculateModulatedTime(lfoValue)
        
        // Read from delay buffer
        let readIndex = (writeIndex - Int(modifiedTime * Float(sampleRate)) + delayBuffer.count) % delayBuffer.count
        let delayedSample = delayBuffer[readIndex]
        
        // Calculate new sample with feedback
        let newSample = input + delayedSample * feedback
        
        // Write to buffer
        delayBuffer[writeIndex] = newSample
        writeIndex = (writeIndex + 1) % delayBuffer.count
        
        // Mix dry/wet
        return input * (1 - mix) + delayedSample * mix
    }
    
    private func generateLFO() -> Float {
        // Advance LFO phase
        let lfoFreq = timeRateF + timeRateC
        phase += 1.0 / sampleRate * Double(lfoFreq)
        if phase >= 1.0 { phase -= 1.0 }
        
        // Generate LFO waveform
        switch lfoType {
        case 0: // Sine
            return sin(2.0 * Float.pi * Float(phase))
        case 1: // Triangle
            return 2.0 * abs(2.0 * Float(phase) - 1.0) - 1.0
        case 2: // Pulse
            return Float(phase) < 0.5 ? 1.0 : -1.0
        default:
            return 0.0
        }
    }
    
    private func calculateModulatedTime(_ lfoValue: Float) -> Float {
        let modAmount = lfoValue * lfoAmount
        
        // Calculate modulated time
        var modifiedTime = time * (1.0 + modAmount)
        
        // Clamp to valid range
        modifiedTime = min(max(modifiedTime,
                             KLUSTERSYNTH.DelayParameters.timeRange.min),
                          KLUSTERSYNTH.DelayParameters.timeRange.max)
        
        return modifiedTime
    }
    
    private func updateDelayTime() {
        // Convert time signature to actual time based on BPM
        // This would be implemented based on your BPM sync requirements
        // For now, using default values from the Parameters
    }
    
    func getAudioNode() -> AVAudioNode {
        return delayNode
    }
}
