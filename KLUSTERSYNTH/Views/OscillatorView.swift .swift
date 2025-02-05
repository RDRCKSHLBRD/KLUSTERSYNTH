//
//  OscillatorView.swift .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct OscillatorView: View {
    @ObservedObject var oscillator: Oscillator
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox("Oscillator") {
                VStack(alignment: .leading, spacing: 15) {
                    // Waveform Picker
                    Picker("Waveform", selection: $oscillator.waveform) {
                        ForEach(KLUSTERSYNTH.WaveformType.allCases, id: \.self) { waveform in
                            Text(waveform.rawValue).tag(waveform)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Frequency Control
                    VStack(alignment: .leading) {
                        Text("Frequency: \(Int(oscillator.frequency)) Hz")
                        Slider(
                            value: $oscillator.frequency,
                            in: 20...2000,
                            step: 1
                        )
                    }
                    
                    // Amplitude Control
                    VStack(alignment: .leading) {
                        Text("Amplitude: \(oscillator.amplitude, specifier: "%.2f")")
                        Slider(
                            value: $oscillator.amplitude,
                            in: 0...1,
                            step: 0.01
                        )
                    }
                }
                .padding()
            }
            .padding()
        }
        .frame(maxWidth: 400)
    }
}

// Preview Provider
struct OscillatorView_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorView(oscillator: Oscillator())
    }
}
