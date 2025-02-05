//
//  EnvelopeView.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct EnvelopeView: View {
    @ObservedObject var envelope: Envelope
    
    var body: some View {
        GroupBox("ADSR Envelope") {
            VStack(alignment: .leading, spacing: 15) {
                // Mode Toggle
                HStack {
                    Text("Mode")
                    Picker("Envelope Mode", selection: $envelope.mode) {
                        Text("ENV1").tag(0)
                        Text("ENV2").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // ADSR Controls
                GroupBox("ADSR") {
                    VStack(alignment: .leading) {
                        // Attack
                        VStack(alignment: .leading) {
                            Text("Attack: \(envelope.attack, specifier: "%.3f")s")
                            Slider(
                                value: $envelope.attack,
                                in: KLUSTERSYNTH.EnvelopeParameters.attackRange.min...KLUSTERSYNTH.EnvelopeParameters.attackRange.max
                            )
                        }
                        
                        // Decay
                        VStack(alignment: .leading) {
                            Text("Decay: \(envelope.decay, specifier: "%.3f")s")
                            Slider(
                                value: $envelope.decay,
                                in: KLUSTERSYNTH.EnvelopeParameters.decayRange.min...KLUSTERSYNTH.EnvelopeParameters.decayRange.max
                            )
                        }
                        
                        // Sustain
                        VStack(alignment: .leading) {
                            Text("Sustain: \(envelope.sustain, specifier: "%.2f")")
                            Slider(
                                value: $envelope.sustain,
                                in: KLUSTERSYNTH.EnvelopeParameters.sustainRange.min...KLUSTERSYNTH.EnvelopeParameters.sustainRange.max
                            )
                        }
                        
                        // Release
                        VStack(alignment: .leading) {
                            Text("Release: \(envelope.release, specifier: "%.3f")s")
                            Slider(
                                value: $envelope.release,
                                in: KLUSTERSYNTH.EnvelopeParameters.releaseRange.min...KLUSTERSYNTH.EnvelopeParameters.releaseRange.max
                            )
                        }
                    }
                }
                
                // LFO Controls
                GroupBox("ENV LFO") {
                    VStack(alignment: .leading) {
                        // LFO Type Selection
                        Picker("LFO Type", selection: $envelope.lfoType) {
                            Text("OFF").tag(0)
                            Text("SINE").tag(1)
                            Text("TRI").tag(2)
                            Text("PLS").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Rate Controls
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rate F")
                                Slider(
                                    value: $envelope.lfoRateF,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Rate C")
                                Slider(
                                    value: $envelope.lfoRateC,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                        }
                        
                        // Depth and Width
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Depth")
                                Slider(
                                    value: $envelope.lfoDepth,
                                    in: KLUSTERSYNTH.LFOParameters.depthRange.min...KLUSTERSYNTH.LFOParameters.depthRange.max
                                )
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Width")
                                Slider(
                                    value: $envelope.lfoWidth,
                                    in: 0...1
                                )
                            }
                        }
                    }
                }
                
                // Mix Control
                VStack(alignment: .leading) {
                    Text("Mix: \(envelope.mix, specifier: "%.2f")")
                    Slider(
                        value: $envelope.mix,
                        in: 0...1
                    )
                }
                
                // Test Button for Preview
                if envelope.isActive {
                    Button("Release") {
                        envelope.noteOff()
                    }
                } else {
                    Button("Trigger") {
                        envelope.noteOn()
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: 400)
    }
}

// Preview Provider
struct EnvelopeView_Previews: PreviewProvider {
    static var previews: some View {
        EnvelopeView(envelope: Envelope())
    }
}
