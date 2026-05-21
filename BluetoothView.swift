import SwiftUI

struct BluetoothView: View {
    
    @ObservedObject var bleManager: BLECentralManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Text("Bluetooth")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(bleManager.isConnected ? "Connected ✅" : "Not Connected ❌")
                    .foregroundColor(.white)
                
                Text(bleManager.statusMessage)
                    .foregroundColor(.gray)
            }
        }
    }
}
