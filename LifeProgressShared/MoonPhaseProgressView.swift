import CloudKit
import SwiftUI

public struct MoonPhaseProgressView: View {
  let width: CGFloat
  let height: CGFloat
  @State private var expectedAge: Int = {
    let store = NSUbiquitousKeyValueStore.default
    let age = Int(store.longLong(forKey: "expectedAge"))
    return age > 0 ? age : 80
  }()
  @State private var birthday: Date = {
    let store = NSUbiquitousKeyValueStore.default
    let birthdayTimeInterval = store.double(forKey: "birthday")
    return birthdayTimeInterval > 0
      ? Date(timeIntervalSince1970: birthdayTimeInterval)
      : Date(timeIntervalSince1970: 946_684_800)
  }()

  public init(width: CGFloat, height: CGFloat) {
    self.width = width
    self.height = height
  }

  public var body: some View {
    let birthYear = Calendar.current.component(.year, from: birthday)
    let currentYear = Calendar.current.component(.year, from: Date())
    let currentMonth = Calendar.current.component(.month, from: Date())
    let currentDay = Calendar.current.component(.day, from: Date())
    let monthLength = Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    let currentMonthPhase = Double(currentDay) / Double(monthLength)

    let columns = 24
    let rows = Int(ceil(Double(expectedAge * 12) / Double(columns)))
    let spacing: CGFloat = 2
    let padding: CGFloat = 16

    let availableWidth = width - (padding * 2) - (spacing * CGFloat(columns - 1))
    let availableHeight = height - (padding * 2) - (spacing * CGFloat(rows - 1)) - 60

    let moonSizeByWidth = availableWidth / CGFloat(columns)
    let moonSizeByHeight = availableHeight / CGFloat(rows)
    let moonSize = min(moonSizeByWidth, moonSizeByHeight)

    VStack(spacing: 0) {
      LazyVGrid(
        columns: Array(repeating: GridItem(.fixed(moonSize), spacing: spacing), count: columns),
        spacing: spacing
      ) {
        ForEach(0..<(expectedAge * 12), id: \.self) { index in
          let yearIndex = index / 12
          let monthIndex = index % 12 + 1
          let year = birthYear + yearIndex
          let isCurrentYear = year == currentYear
          let isPastYear = year < currentYear
          let isPastMonth = isPastYear || (isCurrentYear && monthIndex < currentMonth)
          let isCurrentMonth = isCurrentYear && monthIndex == currentMonth

          if isPastMonth {
            MoonView(phase: 1.0, size: moonSize)
          } else if isCurrentMonth {
            MoonView(phase: currentMonthPhase, size: moonSize)
          } else {
            MoonView(phase: 0.0, size: moonSize)
          }
        }
      }
      .padding(padding)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.95))
    .onAppear {
      let defaults = UserDefaults(suiteName: "group.com.v2free.life_progress")
      if defaults?.integer(forKey: "expectedAge") == 0 {
        expectedAge = 80
      } else {
        expectedAge = Int(defaults?.integer(forKey: "expectedAge") ?? 80)
      }
      if defaults?.double(forKey: "birthday") == 0 {
        birthday = Date(timeIntervalSince1970: 946_684_800)
      } else {
        birthday = Date(
          timeIntervalSince1970: defaults?.double(forKey: "birthday") ?? 946_684_800)
      }
    }
  }
}

struct MoonView: View {
  let phase: Double
  let size: CGFloat

  private let moonBright = Color(red: 1.0, green: 0.98, blue: 0.88)
  private let moonMid = Color(red: 0.95, green: 0.90, blue: 0.70)
  private let moonDark = Color(red: 0.85, green: 0.78, blue: 0.55)
  private let craterColor = Color(red: 0.75, green: 0.68, blue: 0.50)
  private let darkSide = Color(red: 0.12, green: 0.12, blue: 0.18)

  private let craters: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
    (0.3, 0.25, 0.18),
    (0.65, 0.35, 0.14),
    (0.45, 0.6, 0.2),
    (0.25, 0.7, 0.12),
    (0.7, 0.65, 0.16),
    (0.5, 0.3, 0.1),
    (0.35, 0.45, 0.08),
    (0.6, 0.75, 0.1),
    (0.2, 0.5, 0.09),
    (0.75, 0.2, 0.11),
  ]

  var body: some View {
    ZStack {
      Circle()
        .fill(darkSide)
        .frame(width: size, height: size)

      if phase > 0 {
        Canvas { context, canvasSize in
          let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
          let radius = min(canvasSize.width, canvasSize.height) / 2 - 0.5

          let moonPath = createMoonPath(center: center, radius: radius)

          context.fill(
            moonPath,
            with: .radialGradient(
              Gradient(colors: [moonBright, moonMid, moonDark]),
              center: CGPoint(x: center.x - radius * 0.3, y: center.y - radius * 0.3),
              startRadius: 0,
              endRadius: radius * 1.8
            )
          )

          context.clip(to: moonPath)

          for crater in craters {
            let craterX = center.x - radius + (crater.x * radius * 2)
            let craterY = center.y - radius + (crater.y * radius * 2)
            let craterRadius = crater.size * radius

            let craterPath = Path(
              ellipseIn: CGRect(
                x: craterX - craterRadius,
                y: craterY - craterRadius,
                width: craterRadius * 2,
                height: craterRadius * 2
              ))

            context.fill(
              craterPath,
              with: .radialGradient(
                Gradient(colors: [
                  craterColor.opacity(0.6),
                  craterColor.opacity(0.3),
                  Color.clear,
                ]),
                center: CGPoint(x: craterX, y: craterY),
                startRadius: 0,
                endRadius: craterRadius
              )
            )
          }
        }
        .frame(width: size, height: size)
      }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .shadow(color: phase > 0.5 ? moonBright.opacity(0.3) : Color.clear, radius: phase > 0.5 ? 3 : 0)
  }

  private func createMoonPath(center: CGPoint, radius: CGFloat) -> Path {
    Path { path in
      if phase >= 1.0 {
        path.addEllipse(
          in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
          ))
      } else {
        path.move(to: CGPoint(x: center.x, y: center.y - radius))
        path.addArc(
          center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(90),
          clockwise: false)

        if phase < 0.5 {
          let curveOffset = radius * CGFloat(1 - phase * 2)
          path.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y - radius),
            control: CGPoint(x: center.x - curveOffset, y: center.y)
          )
        } else {
          let curveOffset = radius * CGFloat((phase - 0.5) * 2)
          path.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y - radius),
            control: CGPoint(x: center.x + curveOffset, y: center.y)
          )
        }
        path.closeSubpath()
      }
    }
  }
}
