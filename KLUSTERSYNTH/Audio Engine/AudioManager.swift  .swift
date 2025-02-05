//
//  AudioManager.swift  .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

// File: Audio Engine/AudioManager.swift

// File: Audio Engine/AudioManager.swift

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    private var engine: AVAudioEngine
    private var mainMixer: AVAudioMixerNode
    
    // Published properties that Views can observe
    @Published var isRunning = false
    @Published var volume: Float = 0.5 {
        didSet {
            mainMixer.volume = volume
        }
    }
    
    init() {
        engine = AVAudioEngine()
        mainMixer = engine.mainMixerNode
        setupAudio()
    }
    
    private func setupAudio() {
        // Set default output format
        let output = engine.outputNode
        let format = output.inputFormat(forBus: 0)
        engine.connect(mainMixer, to: output, format: format)
    }
    
    func start() {
        do {
            try engine.start()
            isRunning = true
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        engine.stop()
        isRunning = false
    }
    
    // Method to add new audio nodes
    func attachNode(_ node: AVAudioNode) {
        engine.attach(node)
        engine.connect(node, to: mainMixer, format: nil)
    }
}
