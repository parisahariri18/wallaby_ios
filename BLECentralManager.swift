//
//  BLECentralManager.swift
//  Wallaby Wrist Care
//
//  Created by Clarity Design on 2/5/26.
//
import Foundation
import CoreBluetooth //BLE framework (CBCentralManager, CBPeripheral, etc.)
import Combine //ObservableObject and @Published lived in a combined framework, not in foundation or corebluetooth
/// A data model representing the 5 sensor values received via notification.
struct SensorReading {
    // Defines a value type
    // Used to represent one snapshot of sensor data
    let sensorValues: [UInt16]
    // Subject to change: array of 16-bit unsigned integers
    // This array matches how our board sends raw sensor data
    let timestamp: Date
    // Stores when data was received on the phone - important for logging
}
 
/// BLECentralManager handles the lifecycle of Bluetooth connections:
/// Scanning -> Connecting -> Discovering Services -> Discovering Characteristics -> Data Exchange.
class BLECentralManager: NSObject, ObservableObject {
    // Delegates require NSObject
    // ObservableObject allows the SwiftUI to observe state changes and enables @Published properties
   
    // Published means if a value changes, noify observers
    @Published var isConnected: Bool = false
    @Published var statusMessage: String = "Scanning for devices..."
   
    // Core Bluetooth Obejcts
    // The Central Manager is the "brain" that manages the iPhone's Bluetooth radio.
    private var centralManager: CBCentralManager! // ! means it will be initialized in init so you can control when it's created
    // The Peripheral represents the external hardware device we connect to.
    private var discoveredPeripheral: CBPeripheral? // ? means optional variable - may not have a value
   
    // Service and Characteristic UUIDs (Replace strings with your actual hardware UUIDs).
    private let serviceUUID        = CBUUID(string: "f3b2a1c4-e5d6-47a8-92b1-0f9e8d7c6b5a")
    private let personWriteCharUUID = CBUUID(string: "0001")
    private let sensorNotifyCharUUID = CBUUID(string: "0002")
   
    // References to specific characteristics so we can write to them later.
    private var personCharacteristic: CBCharacteristic?
   
    // Local storage for the history of sensor readings.
    // Other classes can read, only this class can modify
    private(set) var sensorHistory: [SensorReading] = []
 
    override init() {
        super.init()
        // Initialize the central manager on the main thread.
        // The 'delegate' is self, meaning this class will handle the Bluetooth callbacks.
        print("BLECentralManager INIT CALLED")
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
}
 
// MARK: - CBCentralManagerDelegate
// These methods handle the state of the iPhone's Bluetooth and the connection process.
extension BLECentralManager: CBCentralManagerDelegate {
   
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState fired")
        print("Bluetooth state: \(central.state.rawValue)")
        switch central.state {
        case .poweredOn:
            print("Bluetooth is On. Starting Scan...")
            // Only scan for devices that advertise our specific Service UUID.
            //write nil instead of serviceUUID to advertise to all peripherals
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        case .poweredOff:
            print("Bluetooth is Off. Please turn it on.")
        case .unauthorized:
            print("Bluetooth permission denied.")
        default:
            break
        }
    }
 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found Peripheral: \(peripheral.name ?? "Unknown")")
       
        // Save a reference to the peripheral or it will be deallocated.
        discoveredPeripheral = peripheral
       
        // Stop scanning to save battery once the device is found.
        centralManager.stopScan()
       // comment these two out if adbvertise is nil
        //have lucas name the peripheral
        // Initiate the connection.
        centralManager.connect(peripheral, options: nil)
    }
 
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Device")")
       
        isConnected = true
        statusMessage = "Connected to \(peripheral.name ?? "Device")"
        // Set the peripheral delegate to receive service/characteristic updates.
        peripheral.delegate = self
       
        // Search for the service we care about.
        peripheral.discoverServices([serviceUUID])
    }
}
 
// MARK: - CBPeripheralDelegate
// These methods handle interactions with the hardware's internal structure and data.
extension BLECentralManager: CBPeripheralDelegate {
   
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
       
        for service in services {
            // Once service is found, look for our Write and Notify characteristics.
            peripheral.discoverCharacteristics(nil, for: service)
            //peripheral.discoverCharacteristics([personWriteCharUUID, sensorNotifyCharUUID], for: service)
        }
    }
 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
       
        for characteristic in characteristics {
            print("Found characteristic: \(characteristic.uuid)")
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to: \(characteristic.uuid)")
            }
            if characteristic.properties.contains(.write) {
                self.personCharacteristic = characteristic
                print("Write characteristic saved: \(characteristic.uuid)")
            }
        }
        /*for characteristic in characteristics {
            if characteristic.uuid == personWriteCharUUID {
                // Save the reference so we can call writeValue later.
                peripheral.setNotifyValue(true, for: characteristic)
                //self.personCharacteristic = characteristic
                print("Write characteristic found.")
               
            } else if characteristic.uuid == sensorNotifyCharUUID {
                // Subscribe to notifications: the peripheral will now push data to us
                // whenever the sensor value changes.
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to sensor notifications.")
            }
        }*/
    }
 
    /// This is called whenever the peripheral sends a notification or a read response.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving update: \(error.localizedDescription)")
            return
        }
       
        guard let data = characteristic.value else {
            print("No data recieved")
            return
        }
        //added for ble
        
        if data.count == 4 {
            let smoothedRaw = Int16(bitPattern: UInt16(data[0]) | UInt16(data[1]) << 8)
            let rawRaw      = Int16(bitPattern: UInt16(data[2]) | UInt16(data[3]) << 8)
            let sensorValues: [UInt16] = [UInt16(bitPattern: smoothedRaw),
                                          UInt16(bitPattern: rawRaw)]
            let reading = SensorReading(sensorValues: sensorValues, timestamp: Date())
            sensorHistory.append(reading)
            //print("Angle — smoothed: \(sensorValues[0])  raw: \(sensorValues[1])")
            let smoothed  = Double(Int16(bitPattern: sensorValues[0])) / 10.0
            let raw       = Double(Int16(bitPattern: sensorValues[1])) / 10.0
            let direction = smoothed >= 0 ? "Flexion" : "Extension"
            print("Angle — smoothed: \(smoothed) deg (\(direction))  raw: \(raw) deg")

        } else if data.count == 3 {
            //print("Status — validPx: \(data[0])/64  bestPat: \(data[1]) deg  flags: \(data[2])")
            let sensorReady  = data[2] & 0x01 != 0
            let lowConf      = data[2] & 0x02 != 0
            let highAngle    = data[2] & 0x04 != 0
            let settling     = data[2] & 0x08 != 0
            print("Status — validPx: \(data[0])/64  bestPat: \(data[1]) deg  ready:\(sensorReady)  lowConf:\(lowConf)  highAngle:\(highAngle)  settling:\(settling)")
        } else {
            print("Unknown packet: \(data.count) bytes")
        }
        
        //print("Raw Data Recieved: \(data)")
       
        /*if characteristic.uuid == sensorNotifyCharUUID {
            // The data is 10 bytes (5 sensors * 2 bytes each for UInt16).
            // We use .withUnsafeBytes to map the raw buffer directly into a UInt16 array.
            //let sensorValues = data.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) -> [UInt16] in
                //let typedBuffer = rawBuffer.bindMemory(to: UInt16.self)
                //return Array(typedBuffer)
            //}
            
            //Added for BLE data testing
            guard data.count >= 4 else {
                print("Packet too short: \(data.count) bytes")
                return
            }
            let smoothedRaw = Int16(bitPattern: UInt16(data[0]) | UInt16(data[1]) << 8)
            let rawRaw      = Int16(bitPattern: UInt16(data[2]) | UInt16(data[3]) << 8)
            //let smoothed    = Double(smoothedRaw) / 10.0
            //let raw         = Double(rawRaw)      / 10.0
            //let direction   = smoothed >= 0 ? "Flexion" : "Extension"

            // Pack into sensorValues as UInt16 bit patterns to preserve SensorReading struct.
            let sensorValues: [UInt16] = [UInt16(bitPattern: smoothedRaw),
                                          UInt16(bitPattern: rawRaw)]
           
            // Save the data with a local timestamp.
            let reading = SensorReading(sensorValues: sensorValues, timestamp: Date())
            sensorHistory.append(reading)
           
            print("Received \(sensorValues.count) sensor points: \(sensorValues)")
        }*/
    }
}
 
// MARK: - Data Transmission Logic
extension BLECentralManager {
   
    /// Packs a Person model into bytes and sends it.
    /// Format: [ID (4 bytes, Little Endian)] + [Age (1 byte)]
    func sendPersonData(id: UInt32, age: UInt8) {
        guard let peripheral = discoveredPeripheral,
              let characteristic = personCharacteristic else {
            print("Peripheral not connected or characteristic missing.")
            return
        }
       
        var data = Data()
       
        // 1. Pack ID: Ensure it uses Little Endian (least significant byte first).
        var littleID = id.littleEndian
        // We take the memory address of the UInt32 and append its 4 bytes to the Data object.
        withUnsafeBytes(of: &littleID) { data.append(contentsOf: $0) }
       
        // 2. Pack Age: UInt8 is already a single byte.
        data.append(age)
       
        // Send to peripheral. .withResponse ensures we get an error if the write fails.
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("Sent Person Data: ID \(id), Age \(age)")
    }
}
