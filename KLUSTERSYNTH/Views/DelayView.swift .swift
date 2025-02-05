//
//  DelayView.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct DelayView: View {
    @ObservedObject var delay: Delay
    
    var body: some View {
        GroupBox("Delay") {
            VStack(alignment: .leading, spacing: 15) {
                // Mode Toggle
                HStack {
                    Text("Mode")
                    Picker("Delay Mode", selection: $delay.mode) {
                        Text("Delay 1").tag(0)
                        Text("Delay 2").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Rate Controls Section
                GroupBox("LFO Controls") {
                    VStack(alignment: .leading) {
                        // Rate Controls
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Rate F")
                                Slider(
                                    value: $delay.timeRateF,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Rate C")
                                Slider(
                                    value: $delay.timeRateC,
                                    in: KLUSTERSYNTH.LFOParameters.rateRange.min...KLUSTERSYNTH.LFOParameters.rateRange.max
                                )
                            }
                        }
                        
                        // LFO Amount
                        VStack(alignment: .leading) {
                            Text("LFO Amount")
                            Slider(
                                value: $delay.lfoAmount,
                                in: 0...1
                            )
                        }
                        
                        // LFO Type Selection
                        Picker("OSC", selection: $delay.lfoType) {
                            Text("SINE").tag(0)
                            Text("TRI").tag(1)
                            Text("PLS").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Time Controls Section
                GroupBox("Time Controls") {
                    VStack(alignment: .leading) {
                        // Time Division Picker
                        Picker("Time Division", selection: $delay.selectedTimeSignature) {
                            ForEach(KLUSTERSYNTH.DelayParameters.timeSignatures, id: \.self) { signature in
                                Text(signature).tag(signature)
                            }
                        }
                        
                        // Input Controls
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Input A")
                                Picker("Input A", selection: .constant(0)) {
                                    Text("THRU").tag(0)
                                    Text("2").tag(1)
                                    Text("4").tag(2)
                                    Text("10").tag(3)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Input B")
                                Picker("Input B", selection: .constant(0)) {
                                    Text("THRU").tag(0)
                                    Text("2").tag(1)
                                    Text("4").tag(2)
                                    Text("10").tag(3)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                }
                
                // Delay Parameters Section
                GroupBox("Delay Parameters") {
                    VStack(alignment: .leading) {
                        // T Mix
                        VStack(alignment: .leading) {
                            Text("T Mix: \(delay.mix, specifier: "%.2f")")
                            Slider(
                                value: $delay.mix,
                                in: KLUSTERSYNTH.DelayParameters.mixRange.min...KLUSTERSYNTH.DelayParameters.mixRange.max
                            )
                        }
                        
                        // Feedback
                        VStack(alignment: .leading) {
                            Text("Feedback: \(delay.feedback, specifier: "%.2f")")
                            Slider(
                                value: $delay.feedback,
                                in: KLUSTERSYNTH.DelayParameters.feedbackRange.min...KLUSTERSYNTH.DelayParameters.feedbackRange.max
                            )
                        }
                        
                        // Filter Feedback
                        VStack(alignment: .leading) {
                            Text("Filter FBK: \(delay.filterFeedback, specifier: "%.2f")")
                            Slider(
                                value: $delay.filterFeedback,
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
struct DelayView_Previews: PreviewProvider {
    static var previews: some View {
        DelayView(delay: Delay())
    }
}
