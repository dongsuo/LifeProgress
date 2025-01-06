import SwiftUI
import CloudKit

public struct WeekProgressView: View {
    let width: CGFloat
    let height: CGFloat
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

    public init(width: CGFloat, height: CGFloat) {
        self.width = width
       
        self.height = height
        
        print("WeekProgressView init, height: \(height)")
    }

    public var body: some View {
        let endDate = Calendar.current.date(byAdding: .year, value: expectedAge, to: birthday) ?? Date()
        let daysInLife = Calendar.current.dateComponents([.day], from: birthday, to: endDate).day ?? 0
        let weeksInLife = daysInLife / 7
        let daysLived = Calendar.current.dateComponents([.day], from: birthday, to: Date()).day ?? 0
        let weeksLived = daysLived / 7
        let currentWeekProgress = Calendar.current.component(.weekday, from: Date())
        let blockWidth = (width - 32) / 100
        let blockHeight = blockWidth / 2

        VStack {
            // Text("Weeks Lived: \(weeksLived) / \(weeksInLife) blockWidth: \(blockWidth) blockHeight: \(blockHeight), height: \(height)")
            //     .font(.system(size: 12))
            //     .padding(.top, 8)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 2) {
                    ForEach(0..<weeksInLife, id: \ .self) { index in
                        Rectangle()
                            .fill(index < weeksLived ? Color.green : (index == weeksLived ? Color.green.opacity(Double(currentWeekProgress) / 7.0) : Color.gray))
                            .frame(width: blockWidth, height: blockHeight)
                            .cornerRadius(1)
                    }
                }
        }
        .onAppear {
            let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
            if defaults?.integer(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80) as Int
            }
            if defaults?.double(forKey: "birthday") == 0 {
                birthday = Date(timeIntervalSince1970: 946684800)
            } else {
                birthday = Date(timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 946684800)
            }
        }
    }
}
