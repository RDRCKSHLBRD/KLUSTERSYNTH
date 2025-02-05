//
//  MainView.swift  .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var oscillator = Oscillator()
    
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
                    
                    // Placeholder views for other modules
                    Text("Filter Module - Coming Soon")
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.gray.opacity(0.2))
                    
                    Text("Envelope Module - Coming Soon")
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.gray.opacity(0.2))
                    
                    Text("Delay Module - Coming Soon")
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(Color.gray.opacity(0.2))
                }
                .padding()
            }
        }
        .onAppear {
            // Setup initial audio routing
            audioManager.attachNode(oscillator.getAudioNode())
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
