import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var bleManager = BLECentralManager()
    @State private var showMenu = false
    @State private var navigateToBluetooth = false
    @State private var selectedTab = "Today"
    @State private var dailyData = generateDailySampleData()
    
    var filteredData: [WristReading] {
        dailyData.filter { $0.validPixel > 10 }
    }
    
    var greenCount: Int {
        filteredData.filter { abs($0.safeAngle) <= 30 }.count
    }

    var yellowCount: Int {
        filteredData.filter { abs($0.safeAngle) > 30 && abs($0.safeAngle) <= 45 }.count
    }

    var redCount: Int {
        filteredData.filter { abs($0.safeAngle) > 45 }.count
    }

    var total: Double {
        Double(filteredData.count)
    }
    
    var greenPercent: Double {
        total == 0 ? 0 : Double(greenCount) / total
    }

    var yellowPercent: Double {
        total == 0 ? 0 : Double(yellowCount) / total
    }

    var redPercent: Double {
        total == 0 ? 0 : Double(redCount) / total
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.black.ignoresSafeArea()
                
            
                Group {
                    
                   
                    if selectedTab == "Today" {
                        
                        ZStack(alignment: .leading) {
                            
                            ScrollView {
                                VStack(spacing: 20) {
                                    
                                    // MARK: - Top Bar
                                    HStack {
                                        Button {
                                            withAnimation {
                                                showMenu.toggle()
                                            }
                                        } label: {
                                            Image(systemName: "line.3.horizontal")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("WristGuard")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 6) {
                                            Image(systemName: "battery.100")
                                                .foregroundColor(.green)
                                            Text("100%")
                                                .foregroundColor(.white)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                    
                                    // MARK: - Device Connected Badge
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("Device Connected")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Capsule())
                                    
                                    
                                    // MARK: - Wrist Position Summary
                                    VStack(spacing: 15) {
                                        Text("Wrist Position Summary")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                        
                                        HStack(spacing: 30) {
                                            // Activity Rings
                                            ZStack {
                                                ActivityRingsView(
                                                    greenProgress: greenPercent,
                                                    yellowProgress: yellowPercent, 
                                                    redProgress: redPercent
                                                )
                                                .frame(width: 120, height: 120)
                                                
                                               
                                                VStack {
                                                    Text(greenPercent > 0.7 ? "GOOD" : greenPercent > 0.5 ? "OK" : "POOR")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                    Text("\(Int(greenPercent * 100))%")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                     
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Circle()
                                                        .fill(Color.green)
                                                        .frame(width: 12, height: 12)
                                                    VStack(alignment: .leading) {
                                                        Text("Safe Zone")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                        Text("\(greenCount) readings")
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                HStack {
                                                    Circle()
                                                        .fill(Color.yellow)
                                                        .frame(width: 12, height: 12)
                                                    VStack(alignment: .leading) {
                                                        Text("Caution Zone")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                        Text("\(yellowCount) readings")
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                
                                                HStack {
                                                    Circle()
                                                        .fill(Color.red)
                                                        .frame(width: 12, height: 12)
                                                    VStack(alignment: .leading) {
                                                        Text("Danger Zone")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                        Text("\(redCount) readings")
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(20)
                                    
                                    
                                    // MARK: - Alerts Card
                                    StyledCard(color: .orange) {
                                        VStack(alignment: .leading) {
                                            Text("Alerts Today")
                                                .foregroundColor(.white.opacity(0.7))
                                            Text("3")
                                                .font(.largeTitle)
                                                .foregroundColor(.white)
                                            Text("2 wrist angle warnings")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    
                                    
                                    // MARK: - Compliance Card
                                    NavigationLink {
                                        ComplianceView()
                                    } label: {
                                        StyledCard(color: .green) {
                                            VStack(alignment: .leading) {
                                                Text("Compliance")
                                                    .foregroundColor(.white.opacity(0.7))
                                                Text("80%")
                                                    .font(.title)
                                                    .foregroundColor(.white)
                                                Text("Device worn 22.5 hrs today")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    
                                    // MARK: - Daily Summary Chart
                                    VStack(alignment: .leading) {
                                        Text("Daily Summary")
                                            .foregroundColor(.white)
                                        
                                        Chart {
                                            ForEach(sampleData) { item in
                                                LineMark(
                                                    x: .value("Time", item.time),
                                                    y: .value("Activity", item.value)
                                                )
                                                .foregroundStyle(.cyan)
                                            }
                                        }
                                        .frame(height: 150)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(20)
                                    
                                    
                                    // MARK: - Suggestions Section
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("Suggestions for Improvement")
                                            .foregroundColor(.white)
                                        
                                        SuggestionRow(icon: "laptopcomputer", title: "Wrist Ergonomics for Working", subtitle: "Hand, wrist, and elbow ergonomics guide", url: "https://ptsmc.com/hand-wrist-elbow-ergonomics/")
                                        
                                        SuggestionRow(icon: "heart.text.square", title: "Recovery Journey For Carpal Tunnel", subtitle: "Complete guide to carpal tunnel surgery recovery", url: "https://doctorshosplaredo.com/about/blog/carpal-tunnel-surgery-recovery-time/")
                                        
                                        SuggestionRow(icon: "figure.mind.and.body", title: "Exercises and Stretches for Wrist Pain", subtitle: "Evidence-based exercises from Cleveland Clinic", url: "https://health.clevelandclinic.org/wrist-pain-exercises")
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100) 
                            }
                            
                        
                            if showMenu {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        withAnimation {
                                            showMenu = false
                                        }
                                    }
                                
                                SideMenuView(showMenu: $showMenu, bleManager: bleManager)
                                    .transition(.move(edge: .leading))
                            }
                        }
                    }
                    
                   
                    else if selectedTab == "Activity" {
                        ActivityView(bleManager: bleManager)
                    }
                    
                   
                    else {
                        Text("Health Screen Coming Soon")
                            .foregroundColor(.white)
                    }
                }
                
             
                VStack {
                    Spacer()
                    
                    HStack {
                        TabBarItem(icon: "sun.max.fill", title: "Today", selected: selectedTab == "Today") {
                            selectedTab = "Today"
                        }
                        
                        Spacer()
                        
                        TabBarItem(icon: "figure.walk", title: "Activity", selected: selectedTab == "Activity") {
                            selectedTab = "Activity"
                        }
                        
                        Spacer()
                        
                        TabBarItem(icon: "heart.fill", title: "Health", selected: selectedTab == "Health") {
                            selectedTab = "Health"
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.95))
                }
            }
        }
    }
}


struct TabBarItem: View {
    var icon: String
    var title: String
    var selected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .foregroundColor(selected ? .yellow : .gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(selected ? .white : .gray)
            }
        }
    }
}
struct SideMenuView: View {
    
    @Binding var showMenu: Bool
    @ObservedObject var bleManager: BLECentralManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            // CLOSE BUTTON
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        showMenu = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            
            // MENU ITEMS
            Label("My Profile", systemImage: "person.fill")
                .foregroundColor(.white)
            
            Label("My Device", systemImage: "applewatch")
                .foregroundColor(.white)
            
            NavigationLink {
                BluetoothView(bleManager: bleManager)
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
                    .foregroundColor(.white)
            }
            
            Divider().background(Color.white.opacity(0.3))
            
            Label("Reports", systemImage: "chart.bar.fill")
                .foregroundColor(.white)
            
            Label("Help", systemImage: "questionmark")
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
        .frame(width: 280)
        .frame(maxHeight: .infinity)
        .background(Color.black)
    }
}
struct StyledCard<Content: View>: View {
    var color: Color
    let content: Content
    
    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.15))
            .cornerRadius(20)
    }
}

struct SuggestionRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var url: String?
    
    var body: some View {
        Button(action: {
            if let urlString = url, let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: url != nil ? "link" : "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding()
            .background(Color.purple.opacity(0.15))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityData: Identifiable {
    let id = UUID()
    let time: String
    let value: Double
}

let sampleData: [ActivityData] = [
    .init(time: "12am", value: 40),
    .init(time: "6am", value: 55),
    .init(time: "12pm", value: 90),
    .init(time: "6pm", value: 45)
]

// MARK: - Activity Ring Components
struct ActivityRing: View {
    var progress: Double   // 0 → 1
    var color: Color
    var lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(.degrees(-90))
    }
}

struct ActivityRingsView: View {
    let greenProgress: Double
    let yellowProgress: Double
    let redProgress: Double
    
    var body: some View {
        ZStack {
           
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 12)
            
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                .scaleEffect(0.75)
            
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .scaleEffect(0.5)
            
          
            ActivityRing(progress: greenProgress, color: .green, lineWidth: 12)
            
       
            ActivityRing(progress: yellowProgress, color: .yellow, lineWidth: 10)
                .scaleEffect(0.75)
            
            
            ActivityRing(progress: redProgress, color: .red, lineWidth: 8)
                .scaleEffect(0.5)
        }
    }
}




