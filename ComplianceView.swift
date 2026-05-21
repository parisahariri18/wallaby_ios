import SwiftUI
import Charts

struct ComplianceView: View {
    @Environment(\.dismiss) private var dismiss
    
   
    private let treatmentStartDate = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? Date()
    private let treatmentEndDate = Calendar.current.date(from: DateComponents(year: 2026, month: 8, day: 1)) ?? Date()
    private let currentDate = Date()
    

    private let overallCompliancePercent: Double = 80
    private let targetWearHours: Double = 22
    private let actualWearHours: Double = 22.5
    private let treatmentDurationWeeks = 22
    
    var progressPercent: Double {
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: treatmentStartDate, to: treatmentEndDate).day ?? 1
        let completedDays = calendar.dateComponents([.day], from: treatmentStartDate, to: currentDate).day ?? 0
        return min(Double(completedDays) / Double(totalDays), 1.0)
    }
    
    var weeksCompleted: Int {
        let calendar = Calendar.current
        let completedDays = calendar.dateComponents([.day], from: treatmentStartDate, to: currentDate).day ?? 0
        return completedDays / 7
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Text("Treatment Compliance")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                
                        Image(systemName: "chevron.left")
                            .foregroundColor(.clear)
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Provider Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Healthcare Provider Instructions")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Wear device for 22+ hours daily. Maintain safe wrist positions under 70 degrees to be out of the danger zone. Next appointment: June 15th.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // MARK: - Treatment Progress Bar
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Treatment Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                      
                        VStack(spacing: 10) {
                            HStack {
                                Text("Start")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(progressPercent * 100))% Complete")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.cyan)
                                Spacer()
                                Text("End")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                            
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 16)
                                    
                         
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(
                                            colors: [.green, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: geometry.size.width * progressPercent, height: 16)
                                    
                                    // Current position indicator
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 12, height: 12)
                                        .offset(x: geometry.size.width * progressPercent - 6)
                                }
                            }
                            .frame(height: 16)
                            
                            // Date labels
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Mar 1, 2026")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    Text("Treatment Start")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("Today")
                                        .font(.caption2)
                                        .foregroundColor(.cyan)
                                    Text("Week \(weeksCompleted)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Aug 1, 2026")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    Text("Expected End")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // MARK: - Compliance Metrics
                    VStack(spacing: 15) {
                        Text("Current Compliance Metrics")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            
              
                            VStack {
                                Text("\(Int(overallCompliancePercent))%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(overallCompliancePercent >= 80 ? .green : overallCompliancePercent >= 60 ? .yellow : .red)
                                Text("Overall Compliance")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("Target: 80%")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            
                 
                            VStack {
                                Text("\(actualWearHours, specifier: "%.1f")h")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(actualWearHours >= targetWearHours ? .green : .yellow)
                                Text("Daily Wear Time")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("Target: \(Int(targetWearHours))h")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            
                     
                            VStack {
                                Text("\(weeksCompleted)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                Text("Weeks Completed")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("of \(treatmentDurationWeeks) weeks")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            
                    
                            VStack {
                                Text("45")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Safe Days")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("of 79 days")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Recommendations
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Provider Recommendations")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        RecommendationRow(
                            icon: "checkmark.circle.fill",
                            text: "Excellent wear time compliance - keep it up!",
                            color: .green
                        )
                        
                        RecommendationRow(
                            icon: "exclamationmark.triangle.fill",
                            text: "Focus on maintaining safe wrist positions during work hours",
                            color: .yellow
                        )
                        
                        RecommendationRow(
                            icon: "target",
                            text: "Aim for 80%+ overall compliance for optimal recovery",
                            color: .cyan
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
        }
    }
}

// MARK: - Supporting Views and Data
struct RecommendationRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct WeeklyCompliance: Identifiable {
    let id = UUID()
    let week: Int
    let compliance: Double
}

let weeklyComplianceData: [WeeklyCompliance] = [
    .init(week: 1, compliance: 45),
    .init(week: 2, compliance: 58),
    .init(week: 3, compliance: 62),
    .init(week: 4, compliance: 71),
    .init(week: 5, compliance: 68),
    .init(week: 6, compliance: 74),
    .init(week: 7, compliance: 69),
    .init(week: 8, compliance: 73),
    .init(week: 9, compliance: 67),
    .init(week: 10, compliance: 71),
    .init(week: 11, compliance: 75)
]

#Preview {
    ComplianceView()
}
