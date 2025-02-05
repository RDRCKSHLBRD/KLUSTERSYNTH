//
//  FilterView.swift .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

//
//  FilterView.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var filter: Filter
    
    var body: some View {
        GroupBox("Filter") {
            VStack(alignment: .leading, spacing: 15) {
                // Mode Toggle
                HStack {
                    Text("Mode")
                    Picker("Filter Mode", selection: $filter.mode) {
                        Text("Filter 1").tag(0)
                        Text("Filter 2").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Filter Path Selection
                HStack {
                    Text("Path")
                    Picker("Filter Path", selection: $filter.path) {
                        Text("THRU").tag(0)
                        Text("ENV").tag(1)
                        Text("ENV1").tag(2)
                        Text("BEAT").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // LFO Controls
                GroupBox("LFO") {
                    VStack(alignment: .leading) {
                        // LFO Type
                        Picker("OSC", selection: $filter.lfoType) {
                            Text("SINE").tag(0)
                            Text("TRI").tag(1)
                            Text("SAW").tag(2)
                            Text("PLS").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Rate Controls
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rate F")
                                Slider(
                                    value: $filter.rateF,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                            VStack(alignment: .leading) {
                                Text("Rate C")
                                Slider(
                                    value: $filter.rateC,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                        }
                        
                        // Depth Controls
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Depth F")
                                Slider(
                                    value: $filter.depthF,
                                    in: KLUSTERSYNTH.FilterParameters.modDepthRange.min...KLUSTERSYNTH.FilterParameters.modDepthRange.max
                                )
                            }
                            VStack(alignment: .leading) {
                                Text("Depth C")
                                Slider(
                                    value: $filter.depthC,
                                    in: KLUSTERSYNTH.FilterParameters.modDepthRange.min...KLUSTERSYNTH.FilterParameters.modDepthRange.max
                                )
                            }
                        }
                    }
                }
                
                // Main Filter Controls
                GroupBox("Filter Controls") {
                    VStack(alignment: .leading) {
                        // Cutoff
                        VStack(alignment: .leading) {
                            Text("Cutoff: \(Int(filter.cutoff)) Hz")
                            Slider(
                                value: $filter.cutoff,
                                in: KLUSTERSYNTH.FilterParameters.cutoffRange.min...KLUSTERSYNTH.FilterParameters.cutoffRange.max
                            )
                        }
                        
                        // Resonance
                        VStack(alignment: .leading) {
                            Text("Resonance: \(filter.resonance, specifier: "%.2f")")
                            Slider(
                                value: $filter.resonance,
                                in: KLUSTERSYNTH.FilterParameters.resonanceRange.min...KLUSTERSYNTH.FilterParameters.resonanceRange.max
                            )
                        }
                        
                        // Amount to Delay
                        VStack(alignment: .leading) {
                            Text("AMT 2 D: \(filter.amountToDelay, specifier: "%.2f")")
                            Slider(
                                value: $filter.amountToDelay,
                                in: 0...1
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: 400)
    }
}

// Preview Provider
struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filter: Filter())
    }
}
