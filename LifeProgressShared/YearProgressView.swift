import SwiftUI
import CloudKit

public struct YearProgressView: View {
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
        print("YearProgressView init")
    }

    public var body: some View {
        let yearsInLife = expectedAge
        let yearsLived = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        let currentYearProgress = Calendar.current.component(.dayOfYear, from: Date())
        let blockWidth = (width - 32) / 10
        // print("YearProgressView body", yearsInLife, yearsLived, currentYearProgress, percentage)
        VStack {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: blockWidth))], spacing: 2) {
                    ForEach(0..<yearsInLife, id: \ .self) { index in
                        ZStack(alignment: .bottom) {
                            if index == yearsLived {
                                let progressRatio = CGFloat(currentYearProgress) / 365.0
                                let greenHeight = blockWidth * progressRatio
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: blockWidth, height: blockWidth)
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: blockWidth, height: greenHeight)
                            } else  {
                                Rectangle()
                                    .fill(index < yearsLived ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: blockWidth, height: blockWidth)
                            }
                        }
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

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressView(width: UIScreen.main.bounds.width, height: 0.0)
    }
}
