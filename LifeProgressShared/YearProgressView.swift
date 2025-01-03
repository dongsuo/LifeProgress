import SwiftUI
import CloudKit

public struct YearProgressView: View {
    @State private var expectedAge: Int = {
        let store = NSUbiquitousKeyValueStore.default
        return Int(store.longLong(forKey: "expectedAge"))
    }()
    @State private var birthday: Date = {
        let store = NSUbiquitousKeyValueStore.default
        return Date(timeIntervalSince1970: store.double(forKey: "birthday"))
    }()
    public init() {
        print("YearProgressView init")
    }

    public var body: some View {
        let yearsInLife = expectedAge
        let yearsLived = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        let currentYearProgress = Calendar.current.component(.dayOfYear, from: Date())
        let percentage = Double(yearsLived) / Double(yearsInLife) * 100
        let blockWidth = (UIScreen.main.bounds.width - 32) / 10
        // print("YearProgressView body", yearsInLife, yearsLived, currentYearProgress, percentage)
        VStack {
            ProgressView(value: percentage, total: 100) {
                HStack {
                    Text("\(yearsLived) years")
                    Spacer()
                    Text(String(format: "%.2f%%", percentage))
                }
                .font(.caption)
            }
            .accentColor(.green)
            .padding(.horizontal)
            
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
                            } else {
                                Rectangle()
                                    .fill(index < yearsLived ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: blockWidth, height: blockWidth)
                            }
                        }
                        .cornerRadius(0.5)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical)
                .background(Color.white.opacity(0.1))
            }
            .padding(.vertical)
        }
        // .navigationBarTitleDisplayMode(.automatic)
        .onAppear {
            print("YearProgressView onAppear")
            do {
                let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
                expectedAge = defaults?.integer(forKey: "expectedAge") ?? 80
                birthday = Date(timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 0)
                if expectedAge == 0 {
                    expectedAge = 80
                }
                print("YearProgressView onAppear.1", expectedAge, birthday)
            } catch {
                print("Error synchronizing NSUbiquitousKeyValueStore: \(error)")
            }
        }
    }
}

struct YearProgressView_Previews: PreviewProvider {
    static var previews: some View {
        YearProgressView()
    }
}
