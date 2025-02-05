//
//  Routing.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation
import AVFoundation

class Routing: ObservableObject {
    // Audio Engine Reference
    private weak var audioEngine: AVAudioEngine?
    
    // Module References
    private weak var oscillator1: Oscillator?
    private weak var oscillator2: Oscillator?
    private weak var filter1: Filter?
    private weak var filter2: Filter?
    private weak var delay1: Delay?
    private weak var delay2: Delay?
    private weak var envelope1: Envelope?
    private weak var envelope2: Envelope?
    
    // Routing States
    @Published var routingState: [String: Bool] = [
        "osc1ToFilter1": true,
        "osc2ToFilter2": true,
        "filter1ToDelay1": true,
        "filter2ToDelay2": true,
        "env1ToFilter1": false,
        "env1ToOsc2": false,
        "env2ToFilter2": false,
        "delayToMixer": true
    ]
    
    // Initialize with AudioEngine
    init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
    }
    
    // Module Registration
    func registerOscillators(_ osc1: Oscillator, _ osc2: Oscillator) {
        self.oscillator1 = osc1
        self.oscillator2 = osc2
        updateOscillatorRouting()
    }
    
    func registerFilters(_ filter1: Filter, _ filter2: Filter) {
        self.filter1 = filter1
        self.filter2 = filter2
        updateFilterRouting()
    }
    
    func registerDelays(_ delay1: Delay, _ delay2: Delay) {
        self.delay1 = delay1
        self.delay2 = delay2
        updateDelayRouting()
    }
    
    func registerEnvelopes(_ env1: Envelope, _ env2: Envelope) {
        self.envelope1 = env1
        self.envelope2 = env2
        updateEnvelopeRouting()
    }
    
    // Routing Updates
    private func updateOscillatorRouting() {
        guard let engine = audioEngine else { return }
        
        // Clear existing connections
        engine.disconnectNodeOutput(oscillator1?.getAudioNode())
        engine.disconnectNodeOutput(oscillator2?.getAudioNode())
        
        // Establish new connections based on routing state
        if routingState["osc1ToFilter1"] == true {
            connectNodes(from: oscillator1?.getAudioNode(), to: filter1?.getAudioNode())
        }
        
        if routingState["osc2ToFilter2"] == true {
            connectNodes(from: oscillator2?.getAudioNode(), to: filter2?.getAudioNode())
        }
    }
    
    private func updateFilterRouting() {
        guard let engine = audioEngine else { return }
        
        // Clear existing connections
        engine.disconnectNodeOutput(filter1?.getAudioNode())
        engine.disconnectNodeOutput(filter2?.getAudioNode())
        
        // Establish new connections based on routing state
        if routingState["filter1ToDelay1"] == true {
            connectNodes(from: filter1?.getAudioNode(), to: delay1?.getAudioNode())
        }
        
        if routingState["filter2ToDelay2"] == true {
            connectNodes(from: filter2?.getAudioNode(), to: delay2?.getAudioNode())
        }
    }
    
    private func updateDelayRouting() {
        guard let engine = audioEngine else { return }
        
        // Clear existing connections
        engine.disconnectNodeOutput(delay1?.getAudioNode())
        engine.disconnectNodeOutput(delay2?.getAudioNode())
        
        // Connect to main mixer if enabled
        if routingState["delayToMixer"] == true {
            connectNodes(from: delay1?.getAudioNode(), to: engine.mainMixerNode)
            connectNodes(from: delay2?.getAudioNode(), to: engine.mainMixerNode)
        }
    }
    
    private func updateEnvelopeRouting() {
        // Update envelope modulation routing
        if routingState["env1ToFilter1"] == true {
            filter1?.setEnvelopeModulation(envelope1?.getValue() ?? 0)
        }
        
        if routingState["env1ToOsc2"] == true {
            oscillator2?.setBaseAmplitude(envelope1?.getValue() ?? 0)
        }
        
        if routingState["env2ToFilter2"] == true {
            filter2?.setEnvelopeModulation(envelope2?.getValue() ?? 0)
        }
    }
    
    // Helper function to safely connect audio nodes
    private func connectNodes(from sourceNode: AVAudioNode?, to destinationNode: AVAudioNode?) {
        guard let engine = audioEngine,
              let source = sourceNode,
              let destination = destinationNode else { return }
        
        engine.connect(source, to: destination, format: nil)
    }
    
    // Public function to toggle routing
    func toggleRoute(_ route: String) {
        routingState[route]?.toggle()
        
        // Update routing based on the changed state
        updateOscillatorRouting()
        updateFilterRouting()
        updateDelayRouting()
        updateEnvelopeRouting()
    }
    
    // Update all routing
    func updateAllRouting() {
        updateOscillatorRouting()
        updateFilterRouting()
        updateDelayRouting()
        updateEnvelopeRouting()
    }
}
