import SwiftUI
import Charts

struct ActivityView: View {
    
    @ObservedObject var bleManager: BLECentralManager
    @State private var selectedDay = 4
    @State private var selectedTab = "Overview"
    @State private var dailyData = generateDailySampleData()
    @State private var currentDate = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? Date()
    @State private var selectedDate: Date? = nil
    
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
    
    let days = [
        ("Sat","Dec 7",5),
        ("Sun","Dec 8",2),
        ("Mon","Dec 9",4),
        ("Tue","Dec 10",3),
        ("Today","Dec 11",3)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Title
                    Text("Activity")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    // MARK: Interactive Calendar
                    InteractiveCalendar(
                        currentDate: $currentDate,
                        selectedDate: $selectedDate,
                        startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? Date()
                    )
                    
                    // MARK: Toggle
                    HStack {
                        ToggleButton(title: "Overview", selected: selectedTab == "Overview") {
                            selectedTab = "Overview"
                        }
                        
                        ToggleButton(title: "Warnings", selected: selectedTab == "Warnings") {
                            selectedTab = "Warnings"
                        }
                    }
                    
                    // MARK: CONTENT SWITCH
                    if selectedTab == "Overview" {
                        OverviewSection()
                    } else {
                        WarningListView()
                    }
                    
                    Spacer(minLength: 100) // Add bottom padding for tab bar
                }
                .padding()
            }
        }
    }
}

struct DayCard: View {
    var day: String
    var date: String
    var alerts: Int
    var selected: Bool
    
    var body: some View {
        VStack {
            Text(day).foregroundColor(.gray)
            Text(date).foregroundColor(.white)
            Text("\(alerts) alerts")
                .foregroundColor(.red)
                .font(.caption)
        }
        .padding()
        .background(selected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ToggleButton: View {
    var title: String
    var selected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct OverviewSection: View {
    // Use specific day counts as provided
    private let totalDays = 79 // Days from March 1, 2026 to May 19, 2026
    private let greenCount = 45 // Safe zone days
    private let yellowCount = 20 // Caution zone days  
    private let redCount = 14 // Danger zone days
    private let overallSafetyScore = 82 // Overall safety percentage
    
    var greenPercent: Double {
        Double(greenCount) / Double(totalDays)
    }

    var yellowPercent: Double {
        Double(yellowCount) / Double(totalDays)
    }

    var redPercent: Double {
        Double(redCount) / Double(totalDays)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Zone Summary Cards
            HStack(spacing: 15) {
                // Safe Zone Card
                VStack {
                    Text("\(greenCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Safe")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(Int(greenPercent * 100))%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.15))
                .cornerRadius(15)
                
                // Caution Zone Card
                VStack {
                    Text("\(yellowCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text("Caution")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(Int(yellowPercent * 100))%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(15)
                
                // Danger Zone Card
                VStack {
                    Text("\(redCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Danger")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(Int(redPercent * 100))%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.15))
                .cornerRadius(15)
            }
            
            // Movement Quality
            VStack(alignment: .leading, spacing: 10) {
                Text("Movement Quality")
                    .foregroundColor(.white)
                
                StatRow(title: "Safe zone days", value: "\(greenCount)")
                StatRow(title: "Caution zone days", value: "\(yellowCount)")
                StatRow(title: "Danger zone days", value: "\(redCount)")
                StatRow(title: "Total days tracked", value: "\(totalDays)")
                StatRow(title: "Overall safety score", value: "\(overallSafetyScore)%")
            }
            .padding()
            .background(Color.blue.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

struct WarningListView: View {
    let warnings = [
        Warning(time: "8:23 AM", angle: 72, level: "High"),
        Warning(time: "12:47 PM", angle: 78, level: "High")
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                Text("Today's Warnings")
                    .foregroundColor(.white)
                Spacer()
                Text("\(warnings.count) total")
                    .foregroundColor(.gray)
            }
            
            ForEach(warnings) { warning in
                NavigationLink {
                    WarningDetailView(warning: warning)
                } label: {
                    WarningCard(warning: warning)
                }
            }
        }
    }
}

struct Warning: Identifiable {
    let id = UUID()
    let time: String
    let angle: Int
    let level: String
}

struct WarningCard: View {
    var warning: Warning
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(warning.time)
                    .foregroundColor(.white)
                
                Text("Wrist Angle Warning")
                    .foregroundColor(.gray)
                
                Text("Angle: \(warning.angle)°")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(warning.level)
                .padding(6)
                .background(warning.level == "High" ? Color.red : Color.orange)
                .cornerRadius(10)
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(15)
    }
}

struct WarningDetailView: View {
    var warning: Warning
    @State private var dailyData: [WristReading] = generateDailySampleData()
    
    // Generate data up to the warning time
    var dataUpToWarning: [WristReading] {
        let warningHour = extractHour(from: warning.time)
        return dailyData.filter { reading in
            let readingHour = Calendar.current.component(.hour, from: reading.time)
            return readingHour <= warningHour && reading.validPixel > 10
        }
    }
    
    // Add warning point at the end
    var dataWithWarning: [WristReading] {
        var data = dataUpToWarning
        
        // Create warning time Date
        if let warningTime = createWarningDate(from: warning.time) {
            let warningReading = WristReading(
                time: warningTime,
                rawAngle: Double(warning.angle),
                validPixel: 50
            )
            data.append(warningReading)
        }
        
        return data.sorted { $0.time < $1.time }
    }
    
    func colorForAngle(_ angle: Double) -> Color {
        let absAngle = abs(angle)
        
        if absAngle > 45 {
            return .red
        } else if absAngle > 30 {
            return .yellow
        } else {
            return .green
        }
    }
    
    func extractHour(from timeString: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let date = formatter.date(from: timeString) {
            return Calendar.current.component(.hour, from: date)
        }
        return 12 // Default fallback
    }
    
    func createWarningDate(from timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        if let time = formatter.date(from: timeString) {
            let calendar = Calendar.current
            let today = Date()
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: timeComponents.hour ?? 12, 
                               minute: timeComponents.minute ?? 0, 
                               second: 0, 
                               of: today)
        }
        return nil
    }
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Warning Details")
                    .foregroundColor(.white)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("Time: \(warning.time)")
                        .foregroundColor(.white)
                    Text("Angle: \(warning.angle)°")
                        .foregroundColor(.white)
                }
                
                Chart {
                    // Main line including the warning point for a continuous line
                    ForEach(dataWithWarning) { reading in
                        LineMark(
                            x: .value("Time", reading.time),
                            y: .value("Angle", reading.safeAngle)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.cyan)
                    }

                    // Red warning point at the end (on top of the line)
                    if let warningTime = createWarningDate(from: warning.time) {
                        PointMark(
                            x: .value("Time", warningTime),
                            y: .value("Angle", Double(warning.angle))
                        )
                        .foregroundStyle(.red)
                        .symbol(.circle)
                        .symbolSize(100)
                    }

                    // Neutral line at 0
                    RuleMark(y: .value("Neutral", 0))
                        .foregroundStyle(.gray)
                }
                .frame(height: 250)
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisValueLabel()
                            .foregroundStyle(.white)
                        AxisTick()
                            .foregroundStyle(.white)
                        AxisGridLine()
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 1)) {
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                            .foregroundStyle(.white)
                        AxisTick()
                            .foregroundStyle(.white)
                        AxisGridLine()
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
                .padding(.horizontal, 10) // Add padding to prevent label cutoff
                .overlay(alignment: .topLeading) {
                    Text("Flexion")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.top, 5)
                        .padding(.leading, 15)
                }
                .overlay(alignment: .bottomLeading) {
                    Text("Extension")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.bottom, 25)
                        .padding(.leading, 15)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct StatRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Interactive Calendar Components
struct InteractiveCalendar: View {
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?
    let startDate: Date
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var monthYearString: String {
        dateFormatter.string(from: currentDate)
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        
        var days: [Date] = []
        
        // Add previous month's trailing days
        for i in 1..<firstWeekday {
            if let day = calendar.date(byAdding: .day, value: -(firstWeekday - i), to: firstOfMonth) {
                days.append(day)
            }
        }
        
        // Add current month's days
        for i in 0..<numberOfDaysInMonth {
            if let day = calendar.date(byAdding: .day, value: i, to: firstOfMonth) {
                days.append(day)
            }
        }
        
        // Add next month's leading days to complete the grid
        let totalCells = 42 // 6 rows × 7 days
        let remainingCells = totalCells - days.count
        let lastDay = days.last ?? firstOfMonth
        
        for i in 1...remainingCells {
            if let day = calendar.date(byAdding: .day, value: i, to: lastDay) {
                days.append(day)
            }
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Month/Year Header with Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            HStack {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        currentMonth: currentDate,
                        selectedDate: selectedDate,
                        startDate: startDate,
                        onDateSelected: { selectedDate = $0 }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.blue.opacity(0.15))
        .cornerRadius(20)
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let currentMonth: Date
    let selectedDate: Date?
    let startDate: Date
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let today = Date()
    
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
    
    private var isSelected: Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isPastDay: Bool {
        !isToday && date < today && date >= startDate
    }
    
    private var isFutureDay: Bool {
        date > today
    }
    
    private var isBeforeStartDate: Bool {
        date < startDate
    }
    
    private var dayRating: DayRating {
        // Only show ratings for past days after start date
        guard isPastDay && !isBeforeStartDate else { return .none }
        return generateDayRating(for: date, startDate: startDate)
    }
    
    var body: some View {
        Button(action: {
            if isCurrentMonth && !isBeforeStartDate {
                onDateSelected(date)
            }
        }) {
            VStack(spacing: 2) {
                Text("\(dayNumber)")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if dayRating != .none {
                    Text(dayRating.emoji)
                        .font(.system(size: 16))
                } else {
                    Text(" ")
                        .font(.system(size: 16))
                }
            }
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!isCurrentMonth || isBeforeStartDate)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var textColor: Color {
        if !isCurrentMonth || isBeforeStartDate {
            return .gray.opacity(0.3)
        } else if isToday {
            return .black
        } else {
            return .white
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .cyan
        } else if isSelected {
            return .blue.opacity(0.3)
        } else if isCurrentMonth {
            return Color.clear
        } else {
            return Color.clear
        }
    }
}

// MARK: - Day Rating System
enum DayRating {
    case excellent  // Green zone (65% chance)
    case good       // Green zone (65% chance)
    case caution    // Yellow zone (20% chance)
    case danger     // Red zone (15% chance)
    case none       // No data or future day
    
    var emoji: String {
        switch self {
        case .excellent: return "😊"
        case .good: return "🙂"
        case .caution: return "😐"
        case .danger: return "😡" // Red face emoji for bad days
        case .none: return ""
        }
    }
    
    var description: String {
        switch self {
        case .excellent: return "Excellent posture day!"
        case .good: return "Good posture day"
        case .caution: return "Caution zone day"
        case .danger: return "Danger zone day"
        case .none: return "No data"
        }
    }
}

// MARK: - Rating Generation Function
func generateDayRating(for date: Date, startDate: Date) -> DayRating {
    // Only generate ratings for dates after start date (March 1, 2026)
    guard date >= startDate else { return .none }
    
    // Generate consistent data based on the date
    let calendar = Calendar.current
    let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
    
    // Use a deterministic approach based on the day number
    // This ensures the same date always gets the same rating
    let seed = daysSinceStart % 79
    
    // Distribute according to actual counts:
    // 45 safe days (excellent + good), 20 caution days, 14 danger days
    switch seed {
    case 0..<25: // 25 excellent (green)
        return .excellent
    case 25..<45: // 20 good (green) - total 45 green
        return .good
    case 45..<65: // 20 caution (yellow)
        return .caution
    default: // 14 danger (red)
        return .danger
    }
}


