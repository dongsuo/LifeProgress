import SwiftUI
import CloudKit

public struct WeekProgressView: View {
    @State private var expectedAge: Int = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge"))
    @State private var birthday: Date = Date(timeIntervalSince1970: NSUbiquitousKeyValueStore.default.double(forKey: "birthday"))

    public init() {}

    public var body: some View {
        let endDate = Calendar.current.date(byAdding: .year, value: expectedAge, to: birthday) ?? Date()
        let daysInLife = Calendar.current.dateComponents([.day], from: birthday, to: endDate).day ?? 0
        let weeksInLife = daysInLife / 7
        let daysLived = Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
        let weeksLived = daysLived / 7
        let currentWeekProgress = Calendar.current.component(.weekday, from: Date())
        let currentAge = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        let percentage = Double(weeksLived) / Double(weeksInLife) * 100
        let blockWidth = (UIScreen.main.bounds.width-32) / 100
        
        VStack {
            ProgressView(value: percentage, total: 100) {
                HStack {
                    Text("Current Age: \(currentAge) years")
                    Spacer()
                    Text(String(format: "%.2f%%", percentage))
                }
                .font(.caption)
            }
            .accentColor(.green)
            .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 2) {
                    ForEach(0..<weeksInLife, id: \ .self) { index in
                        Rectangle()
                            .fill(index < weeksLived ? Color.green : (index == weeksLived ? Color.green.opacity(Double(currentWeekProgress) / 7.0) : Color.gray))
                            .frame(width: blockWidth, height: blockWidth)
                            .cornerRadius(1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical)
                .background(Color.white.opacity(0.1))
            }
            .padding(.vertical)
        }
        .onAppear {
            expectedAge = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge"))
            birthday = Date(timeIntervalSince1970: NSUbiquitousKeyValueStore.default.double(forKey: "birthday"))
        }
    }
}
