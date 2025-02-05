//
//  MIDIManager.swift .swift
//  KLUSTERSYNTH
//
//  Created by Roderick Shoolbraid on 2025-02-04.
//

import Foundation
import CoreMIDI

class MIDIManager: ObservableObject {
    // MIDI Client reference
    private var client = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var sources: [MIDIEndpointRef] = []
    
    // Published properties for UI updates
    @Published var availableSources: [String] = []
    @Published var isSetup = false
    
    // Callback for note events
    var noteOnHandler: ((UInt8, UInt8) -> Void)?  // note, velocity
    var noteOffHandler: ((UInt8) -> Void)?        // note
    
    init() {
        setupMIDI()
    }
    
    private func setupMIDI() {
        // Create MIDI client
        let status = MIDIClientCreateWithBlock("KLUSTERSYNTH" as CFString, &client) { [weak self] message in
            self?.handleMIDINotification(message.pointee)
        }
        
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }
        
        // Create input port
        let createPortStatus = MIDIInputPortCreateWithBlock(client, "KLUSTERSYNTH_Input" as CFString, &inputPort) { [weak self] packetList, _ in
            self?.handleMIDIPacketList(packetList.pointee)
        }
        
        guard createPortStatus == noErr else {
            print("Error creating MIDI input port: \(createPortStatus)")
            return
        }
        
        // Connect available sources
        connectSources()
        isSetup = true
    }
    
    private func connectSources() {
        availableSources.removeAll()
        sources.removeAll()
        
        // Get number of sources
        let sourceCount = MIDIGetNumberOfSources()
        
        // Connect each source
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            sources.append(source)
            
            // Get source name
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &name)
            if let cfName = name?.takeRetainedValue() {
                availableSources.append(cfName as String)
            }
            
            // Connect source to input port
            let connectStatus = MIDIPortConnectSource(inputPort, source, nil)
            if connectStatus != noErr {
                print("Error connecting MIDI source: \(connectStatus)")
            }
        }
    }
    
    private func handleMIDINotification(_ notification: MIDINotification) {
        switch notification.messageID {
        case .msgSetupChanged:
            // MIDI setup changed, reconnect sources
            connectSources()
        default:
            break
        }
    }
    
    private func handleMIDIPacketList(_ packetList: MIDIPacketList) {
        let packet = packetList.packet
        var currentPacket = packet
        
        for _ in 0..<packetList.numPackets {
            let data = UnsafeRawPointer(&currentPacket.data)
            
            // Get status byte and channel
            let status = UInt8(data.load(as: UInt8.self))
            let messageType = status >> 4
            
            // Handle note on/off messages
            switch messageType {
            case 0x9: // Note On
                let note = UInt8(data.load(fromByteOffset: 1, as: UInt8.self))
                let velocity = UInt8(data.load(fromByteOffset: 2, as: UInt8.self))
                if velocity > 0 {
                    DispatchQueue.main.async {
                        self.noteOnHandler?(note, velocity)
                    }
                } else {
                    // Note on with velocity 0 is treated as note off
                    DispatchQueue.main.async {
                        self.noteOffHandler?(note)
                    }
                }
                
            case 0x8: // Note Off
                let note = UInt8(data.load(fromByteOffset: 1, as: UInt8.self))
                DispatchQueue.main.async {
                    self.noteOffHandler?(note)
                }
                
            default:
                break
            }
            
            // Move to next packet
            currentPacket = MIDIPacketNext(&currentPacket).pointee
        }
    }
    
    // Helper function to convert MIDI note number to frequency
    func noteToFrequency(_ note: UInt8) -> Float {
        return Float(440.0 * pow(2.0, (Double(note) - 69.0) / 12.0))
    }
    
    deinit {
        if isSetup {
            // Cleanup MIDI client
            MIDIClientDispose(client)
        }
    }
}
