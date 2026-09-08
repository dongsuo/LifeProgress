import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        self.init(red: Double((hexNumber & 0xFF0000) >> 16) / 255.0,
                  green: Double((hexNumber & 0x00FF00) >> 8) / 255.0,
                  blue: Double(hexNumber & 0x0000FF) / 255.0)
    }

    var hexString: String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02lX%02lX%02lX",
                      lround(Double(r) * 255),
                      lround(Double(g) * 255),
                      lround(Double(b) * 255))
        #else
        return "34C759"
        #endif
    }
}
