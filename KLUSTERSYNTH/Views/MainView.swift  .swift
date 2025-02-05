import SwiftUI

struct MainView: View {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var oscillator = Oscillator()

    var body: some View {
        VStack(spacing: 10) { // Reduced spacing for tighter layout
            // Top bar with master controls
            HStack {
                Text("KLUSTERSYNTH")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()

                // Dropdown for device selection
                Menu {
                    if audioManager.availableDevices.isEmpty {
                        Text("No devices available").foregroundColor(.gray)
                    } else {
                        ForEach(audioManager.availableDevices, id: \.self) { device in
                            Button(device) {
                                audioManager.selectDevice(device)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(audioManager.selectedDevice == "Default" ? "Select Device" : audioManager.selectedDevice)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                    }
                }

                // Master Volume
                VStack(alignment: .leading) {
                    Text("Master")
                    Slider(
                        value: $audioManager.volume,
                        in: 0...1
                    )
                    .frame(width: 100)
                }

                // Engine Start/Stop and Master Volume
                VStack {
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
            }
            .padding()

            // Main content grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    // Oscillator Section
                    VStack {
                        Text("Oscillator")
                            .font(.headline)
                        OscillatorView(oscillator: oscillator)
                        HStack {
                            Button("Trig (Start)") {
                                oscillator.start()
                            }
                            .padding(5)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            Button("Trig (Stop)") {
                                oscillator.stop()
                            }
                            .padding(5)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .border(Color.gray, width: 1)

                    // Envelope Section
                    VStack {
                        Text("Envelope")
                            .font(.headline)
                        EnvelopeView(envelope: Envelope())
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .border(Color.gray, width: 1)

                    // Filter Section
                    VStack {
                        Text("Filter")
                            .font(.headline)
                        FilterView(filter: Filter())
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .border(Color.gray, width: 1)

                    // Delay Section
                    VStack {
                        Text("Delay")
                            .font(.headline)
                        DelayView(delay: Delay())
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .border(Color.gray, width: 1)
                }
                .padding([.leading, .trailing], 10) // Align closer to the edges
            }
        }
        .onAppear {
            audioManager.fetchAvailableDevices()
            print("🎛️ Available devices on appear: \(audioManager.availableDevices)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
