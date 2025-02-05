import Foundation
import AVFoundation

class Oscillator: ObservableObject {
    private var oscillatorNode: AVAudioSourceNode!
    private var sampleRate: Double = 44100.0
    private var phase: Double = 0.0
    
    @Published var frequency: Float = 440.0 // Default to A4
    @Published var amplitude: Float = 0.5
    @Published var waveform: WaveformType = .sine
    @Published var isPlaying: Bool = false // Track oscillator state
    
    // Enum for waveform types
    enum WaveformType: String, CaseIterable {
        case sine, triangle, sawtooth, pulse, noise
    }
    
    // MIDI note handling
    private var activeNotes: Set<UInt8> = [] // Track pressed MIDI notes
    private var baseAmplitude: Float = 0.5  // Base volume before velocity scaling
    
    init() {
        setupAudioNode()
    }
    
    private func setupAudioNode() {
        oscillatorNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = ablPointer.first, let ptr = buffer.mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            
            for frame in 0..<Int(frameCount) {
                let value = self.generateSample()
                ptr[frame] = value
                
                self.phase += 1.0 / self.sampleRate * Double(self.frequency)
                if self.phase >= 1.0 {
                    self.phase -= 1.0
                }
            }
            return noErr
        }
    }
    
    private func generateSample() -> Float {
        if !isPlaying {
            return 0.0
        }
        
        switch waveform {
        case .sine:
            return amplitude * sin(2.0 * Float.pi * Float(phase))
        case .triangle:
            return amplitude * (2.0 * abs(2.0 * Float(phase) - 1.0) - 1.0)
        case .sawtooth:
            return amplitude * (2.0 * Float(phase) - 1.0)
        case .pulse:
            return amplitude * (Float(phase) < 0.5 ? 1.0 : -1.0)
        case .noise:
            return amplitude * Float.random(in: -1...1)
        }
    }
    
    func getAudioNode() -> AVAudioNode {
        return oscillatorNode
    }
    
    // Start the oscillator
    func start() {
        isPlaying = true
    }
    
    // Stop the oscillator
    func stop() {
        isPlaying = false
    }
    
    // MIDI note handling
    func noteOn(note: UInt8, velocity: UInt8) {
        activeNotes.insert(note)
        isPlaying = true
        frequency = Float(440.0 * pow(2.0, (Double(note) - 69.0) / 12.0)) // Convert MIDI note to frequency
        amplitude = baseAmplitude * (Float(velocity) / 127.0) // Scale amplitude by velocity
    }
    
    func noteOff(note: UInt8) {
        activeNotes.remove(note)
        if activeNotes.isEmpty {
            isPlaying = false
            amplitude = 0.0
        } else if let lastNote = activeNotes.max() {
            frequency = Float(440.0 * pow(2.0, (Double(lastNote) - 69.0) / 12.0))
        }
    }
    
    // Set base amplitude while preserving MIDI scaling
    func setBaseAmplitude(_ value: Float) {
        baseAmplitude = value
        if isPlaying {
            amplitude = baseAmplitude * (amplitude / (baseAmplitude == 0 ? 1 : baseAmplitude))
        }
    }
}
