import Foundation

// MARK: - Data Model
struct WristReading: Identifiable {
    let id = UUID()
    let time: Date
    let rawAngle: Double
    let validPixel: Int
    
   
    var safeAngle: Double {
        min(max(rawAngle, -90), 90)
    }
    
    // MARK: - Zone Classification (for rings)
    var zone: WristZone {
        let angle = abs(safeAngle)
        
        if angle <= 30 {
            return .green
        } else if angle <= 45 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Zone Enum (for rings + UI)
enum WristZone {
    case green
    case yellow
    case red
}

// MARK: - Sample Data Generator
func generateDailySampleData() -> [WristReading] {
    var data: [WristReading] = []
    
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    
    for minute in stride(from: 0, to: 1440, by: 5) {
        let time = calendar.date(byAdding: .minute, value: minute, to: startOfDay)!
        
       
        var angle = Double.random(in: -25...30)
        
 
        if Int.random(in: 0...10) > 8 {
            angle = Double.random(in: 30...45) * (Bool.random() ? 1 : -1)
        }
        
      
        if Int.random(in: 0...20) > 18 {
            angle = Double.random(in: 45...65) * (Bool.random() ? 1 : -1)
        }
        
  
        let validPixel = Int.random(in: 8...32)
        
        data.append(
            WristReading(
                time: time,
                rawAngle: angle,
                validPixel: validPixel
            )
        )
    }
    
    return data
}
