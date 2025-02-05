//
//  MainView.swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var oscillator = Oscillator()
    @StateObject private var filter = Filter()        // ✅ Persist filter state
    @StateObject private var envelope = Envelope()    // ✅ Persist envelope state
    @StateObject private var delay = Delay()          // ✅ Persist delay state

    var body: some View {
        VStack(spacing: 20) {
            // Top bar with master controls
            HStack {
                Text("KLUSTERSYNTH")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Master Volume
                VStack(alignment: .leading) {
                    Text("Master")
                    Slider(
                        value: $audioManager.volume,
                        in: 0...1
                    )
                    .frame(width: 100)
                }
                
                // Engine Start/Stop
                Toggle("Power", isOn: Binding(
                    get: { audioManager.isRunning },
                    set: { newValue in
                        if newValue {
                            audioManager.start()
                        } else {
                            audioManager.stop()
                        }
                    }
                ))
                .toggleStyle(.button)
                .tint(.red)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Module Views
                    OscillatorView(oscillator: oscillator)
                    FilterView(filter: filter)         // ✅ Uses @StateObject
                    EnvelopeView(envelope: envelope)   // ✅ Uses @StateObject
                    DelayView(delay: delay)           // ✅ Uses @StateObject
                }
                .padding()
            }
        }
        .onAppear {
            // Setup initial audio routing
            audioManager.attachNode(oscillator.getAudioNode())
            audioManager.attachNode(filter.getAudioNode())   // ✅ Attach filter
            audioManager.attachNode(delay.getAudioNode())    // ✅ Attach delay
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
