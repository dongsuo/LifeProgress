import SwiftUI
import CloudKit

public struct MonthProgressView: View {
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
        NavigationView {
            VStack {                
                let monthsInLife = expectedAge * 12
                let monthsLived = Calendar.current.dateComponents([.month], from: birthday, to: Date()).month ?? 0
                let currentMonthProgress = Calendar.current.component(.day, from: Date())
                let blockWidth = (UIScreen.main.bounds.width - 32) / 30
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 1) {
                        ForEach(0..<monthsInLife, id: \ .self) { index in
                            ZStack(alignment: .bottom) {
                                if index == monthsLived {
                                    let monthLength = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
                                    let progressRatio = CGFloat(currentMonthProgress) / CGFloat(monthLength)
                                    let greenHeight = blockWidth * progressRatio
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: blockWidth, height: blockWidth)
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: blockWidth, height: greenHeight)
                                } else {
                                    Rectangle()
                                        .fill(index < monthsLived ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: blockWidth, height: blockWidth)
                                }
                            }
                            .cornerRadius(0.5)
                        }
                    }
                }
            }
        }.onAppear {
            let store = NSUbiquitousKeyValueStore.default
            if store.longLong(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(store.longLong(forKey: "expectedAge")) as Int
            }
            if store.double(forKey: "birthday") == 0 {
                birthday = Date(timeIntervalSince1970: 946684800)
            } else {
                birthday = Date(timeIntervalSince1970: store.double(forKey: "birthday"))
            }
        }
    }
}
