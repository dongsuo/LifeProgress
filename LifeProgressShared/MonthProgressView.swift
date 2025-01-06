import SwiftUI
import CloudKit

public struct MonthProgressView: View {
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
        return birthdayTimeInterval > 0 ? Date(timeIntervalSince1970: birthdayTimeInterval) : Date(timeIntervalSince1970: 946684800000) // Fallback to current date if not set
    }()
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height 
        print("MonthProgressView init", height)
    }

    public var body: some View {
        VStack {                
                let monthsInLife = expectedAge * 12
                let monthsLived = Calendar.current.dateComponents([.month], from: birthday, to: Date()).month ?? 0
                let currentMonthProgress = Calendar.current.component(.day, from: Date())
                let blockWidth = (width - 32) / 36
                let blockHeight = blockWidth / 2
                // Text("Months Lived: \(monthsLived) / \(monthsInLife) blockWidth: \(blockWidth) blockHeight: \(blockHeight), height: \(height)")
                //     .font(.system(size: 12))
                //     .padding(.top, 8)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 20), spacing: 1) {
                        ForEach(0..<monthsInLife, id: \.self) { index in
                            ZStack(alignment: .bottom) {
                                if index == monthsLived {
                                    let monthLength = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
                                    let progressRatio = CGFloat(currentMonthProgress) / CGFloat(monthLength)
                                    let greenHeight = blockHeight * progressRatio
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: blockWidth, height: blockHeight)
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: blockWidth, height: greenHeight)
                                } else {
                                    Rectangle()
                                        .fill(index < monthsLived ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: blockWidth, height: blockHeight)
                                }
                            }
                            .cornerRadius(0.5)
                        }
            }
        }.onAppear {
            let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
            if defaults?.integer(forKey: "expectedAge") == 0 {
                expectedAge = 80
            } else {
                expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80)
            }
            if defaults?.double(forKey: "birthday") == 0 {
                birthday = Date(timeIntervalSince1970: 946684800000)
            } else {
                birthday = Date(timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 946684800000)
            }
            print("MonthProgressView init")
        }
    }
}
