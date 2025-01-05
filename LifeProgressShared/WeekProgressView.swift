import SwiftUI
import CloudKit

public struct WeekProgressView: View {
    @State private var expectedAge: Int = {
        let store = NSUbiquitousKeyValueStore.default
        let age = Int(store.longLong(forKey: "expectedAge"))
        return age > 0 ? age : 80 // Fallback to 80 if not set
    }()
    @State private var birthday: Date = {
        let store = NSUbiquitousKeyValueStore.default
        let birthdayTimeInterval = store.double(forKey: "birthday")
        return birthdayTimeInterval > 0 ? Date(timeIntervalSince1970: birthdayTimeInterval) : Date() // Fallback to current date if not set
    }()

    public init() {}

    public var body: some View {
        let endDate = Calendar.current.date(byAdding: .year, value: expectedAge, to: birthday) ?? Date()
        let daysInLife = Calendar.current.dateComponents([.day], from: birthday, to: endDate).day ?? 0
        let weeksInLife = daysInLife / 7
        let daysLived = Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
        let weeksLived = daysLived / 7
        let currentWeekProgress = Calendar.current.component(.weekday, from: Date())
        let blockWidth = (UIScreen.main.bounds.width-32) / 100
        
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 2) {
                    ForEach(0..<weeksInLife, id: \ .self) { index in
                        Rectangle()
                            .fill(index < weeksLived ? Color.green : (index == weeksLived ? Color.green.opacity(Double(currentWeekProgress) / 7.0) : Color.gray))
                            .frame(width: blockWidth, height: blockWidth)
                            .cornerRadius(1)
                    }
                }
            }
        }
        .onAppear {
            expectedAge = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge"))
            birthday = Date(timeIntervalSince1970: NSUbiquitousKeyValueStore.default.double(forKey: "birthday"))
        }
    }
}
