import SwiftUI
import CloudKit

public struct MonthProgressView: View {
    @State private var expectedAge: Int = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge"))
    @State private var birthday: Date = Date(timeIntervalSince1970: NSUbiquitousKeyValueStore.default.double(forKey: "birthday"))
    public init() {}

    public var body: some View {
        NavigationView {
            VStack {                
                let monthsInLife = expectedAge * 12
                let monthsLived = Calendar.current.dateComponents([.month], from: birthday, to: Date()).month ?? 0
                let currentMonthProgress = Calendar.current.component(.day, from: Date())
                let currentAge = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
                let percentage = Double(monthsLived) / Double(monthsInLife) * 100                
                let blockWidth = (UIScreen.main.bounds.width - 32) / 30
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
                    .padding(.horizontal, 4)
                    .padding(.vertical)
                    .background(Color.white.opacity(0.1))
                }
                .padding(.vertical)
                .background(Color.white.opacity(0.1))
                .edgesIgnoringSafeArea([])
            }
            .navigationBarTitleDisplayMode(.automatic)
        }.onAppear {
            expectedAge = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "expectedAge"))
            birthday = Date(timeIntervalSince1970: NSUbiquitousKeyValueStore.default.double(forKey: "birthday"))
        }
    }
}
