import AVFoundation
import CoreAudio

class AudioManager: ObservableObject {
    private var engine: AVAudioEngine
    private var mainMixer: AVAudioMixerNode

    @Published var isRunning = false
    @Published var volume: Float = 0.5 {
        didSet {
            mainMixer.volume = volume
        }
    }

    // List of available devices
    @Published var availableDevices: [String] = ["Default"]
    @Published var selectedDevice: String = "Default"

    init() {
        engine = AVAudioEngine()
        mainMixer = engine.mainMixerNode
        setupAudio()
        fetchAvailableDevices()
    }

    private func setupAudio() {
        let output = engine.outputNode
        let format = output.inputFormat(forBus: 0)

        // Connect the main mixer to the output
        engine.connect(mainMixer, to: output, format: format)

        do {
            try engine.start()
            print("✅ Audio Engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func fetchAvailableDevices() {
        var devices: [String] = []
        var defaultDevice = "Default"

        // Use CoreAudio to fetch all audio devices
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )

        var dataSize: UInt32 = 0
        let audioSystemObjectID = AudioObjectID(kAudioObjectSystemObject)

        // Get the size of the device list
        AudioObjectGetPropertyDataSize(audioSystemObjectID, &address, 0, nil, &dataSize)

        let deviceCount = Int(dataSize) / MemoryLayout<AudioObjectID>.size
        var deviceIDs = [AudioObjectID](repeating: 0, count: deviceCount)

        // Get the device IDs
        AudioObjectGetPropertyData(audioSystemObjectID, &address, 0, nil, &dataSize, &deviceIDs)

        for deviceID in deviceIDs {
            var name: CFString = "" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMaster
            )

            if AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, &name) == noErr {
                devices.append(name as String)
            }

            // Detect the default output device
            if let defaultOutputID = getDefaultOutputDeviceID(), defaultOutputID == deviceID {
                defaultDevice = name as String
            }
        }

        DispatchQueue.main.async {
            self.availableDevices = devices
            self.selectedDevice = defaultDevice
        }

        print("🎛️ Available devices: \(availableDevices)")
        print("🎚️ Default device: \(defaultDevice)")
    }

    private func getDefaultOutputDeviceID() -> AudioObjectID? {
        var defaultOutputDeviceID = AudioObjectID(0)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )

        if AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &defaultOutputDeviceID) == noErr {
            return defaultOutputDeviceID
        }

        return nil
    }

    func selectDevice(_ deviceName: String) {
        // macOS doesn't allow selecting output devices programmatically via AVAudioEngine.
        // This method is a placeholder to show the user-selected device.
        print("⚠️ macOS does not support programmatic device switching in AVAudioEngine.")
        selectedDevice = deviceName
    }

    func start() {
        do {
            try engine.start()
            isRunning = true
            print("✅ Audio Engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    func stop() {
        engine.stop()
        isRunning = false
    }
}
