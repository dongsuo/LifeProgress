import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum EventTheme: String, CaseIterable {
    case engagement
    case wedding
    case graduation
    case baby
    case school
    case firstJob
    case promotion
    case house
    case moved
    case travel
    case anniversary
    case relationship
    case pet
    case award
    case marathon
    case car
    case retirement
    case startup
    case concert
    case exam

    public var keywords: [String] {
        switch self {
        case .engagement:
            return ["engaged", "engagement", "proposal", "订婚", "求婚"]
        case .wedding:
            return ["wedding", "married", "marriage", "bride", "groom", "结婚", "婚礼", "婚纱"]
        case .graduation:
            return ["graduation", "graduated", "commencement", "phd", "doctorate", "毕业", "博士", "硕士"]
        case .baby:
            return ["baby", "newborn", "born", "birth", "宝宝", "出生", "生子", "生孩子", "满月"]
        case .school:
            return ["kindergarten", "school", "开学", "上学", "幼儿园", "入学"]
        case .firstJob:
            return ["job", "hired", "offer", "入职", "上班", "第一份工作"]
        case .promotion:
            return ["promotion", "promoted", "升职", "晋升", "加薪"]
        case .house:
            return ["house", "new home", "mortgage", "买房", "新房", "乔迁"]
        case .moved:
            return ["moved", "relocated", "immigrat", "emigrat", "搬家", "移民", "迁居"]
        case .travel:
            return ["travel", "trip", "vacation", "journey", "旅行", "旅游", "出游"]
        case .anniversary:
            return ["anniversary", "周年", "纪念日"]
        case .relationship:
            return ["girlfriend", "boyfriend", "dating", "first kiss", "恋爱", "在一起", "表白"]
        case .pet:
            return ["dog", "cat", "puppy", "kitten", "pet", "宠物", "猫咪", "猫猫", "狗狗"]
        case .award:
            return ["award", "champion", "prize", "获奖", "冠军", "得奖", "比赛"]
        case .marathon:
            return ["marathon", "triathlon", "race", "马拉松", "铁人三项"]
        case .car:
            return ["car", "driver license", "license", "买车", "驾照", "提车"]
        case .retirement:
            return ["retired", "retirement", "退休"]
        case .startup:
            return ["founded", "startup", "launched", "创业", "成立", "公司成立"]
        case .concert:
            return ["concert", "music festival", "演唱会", "音乐会", "音乐节"]
        case .exam:
            return ["exam", "certified", "certification", "考试", "证书", "考证"]
        }
    }

    public var symbolName: String {
        switch self {
        case .engagement:   return "sparkles"
        case .wedding:     return "heart.fill"
        case .graduation:  return "graduationcap.fill"
        case .baby:        return "figure.and.child.holdinghands"
        case .school:      return "book.closed.fill"
        case .firstJob:    return "briefcase.fill"
        case .promotion:   return "arrow.up.circle.fill"
        case .house:       return "house.fill"
        case .moved:       return "shippingbox.fill"
        case .travel:      return "airplane"
        case .anniversary: return "infinity"
        case .relationship: return "heart.circle.fill"
        case .pet:         return "pawprint.fill"
        case .award:       return "trophy.fill"
        case .marathon:    return "figure.run"
        case .car:         return "car.fill"
        case .retirement:  return "sun.max.fill"
        case .startup:     return "flag.fill"
        case .concert:     return "music.note"
        case .exam:        return "checkmark.seal.fill"
        }
    }

    public var fallbackSymbolName: String {
        switch self {
        case .baby:        return "face.smiling"
        case .moved:       return "cube.box.fill"
        case .award:       return "star.fill"
        default:           return "star.fill"
        }
    }

    public var resolvedSymbolName: String {
        #if canImport(UIKit)
        if UIImage(systemName: symbolName) != nil {
            return symbolName
        }
        #endif
        return fallbackSymbolName
    }

    private static func isASCII(_ string: String) -> Bool {
        string.unicodeScalars.allSatisfy { $0.isASCII }
    }

    private static func matchesASCIIKeyword(_ title: String, keyword: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: keyword.lowercased())
        let pattern = keyword.count <= 3 ? "\\b\(escaped)(s|es)?\\b" : "\\b\(escaped)"
        return title.range(of: pattern, options: .regularExpression) != nil
    }

    public static func match(title: String) -> EventTheme? {
        let normalized = title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        for theme in allCases {
            for keyword in theme.keywords {
                if isASCII(keyword) {
                    if matchesASCIIKeyword(normalized, keyword: keyword) {
                        return theme
                    }
                } else if normalized.contains(keyword) {
                    return theme
                }
            }
        }
        return nil
    }
}

public extension LifeEvent {
    var eventTheme: EventTheme? {
        EventTheme.match(title: title)
    }
}

#if canImport(UIKit)
import SwiftUI

public func drawThemeSymbol(_ theme: EventTheme, in context: GraphicsContext, at rect: CGRect, size: CGFloat, tint: UIColor) {
    let config = UIImage.SymbolConfiguration(pointSize: size, weight: .bold)
    guard let image = UIImage(systemName: theme.resolvedSymbolName, withConfiguration: config)?
        .withTintColor(tint, renderingMode: .alwaysOriginal) else { return }
    let imageSize = image.size
    let scale = min(size / imageSize.width, size / imageSize.height)
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let drawRect = CGRect(x: rect.midX - drawSize.width / 2,
                          y: rect.midY - drawSize.height / 2,
                          width: drawSize.width,
                          height: drawSize.height)
    context.withCGContext { cg in
        UIGraphicsPushContext(cg)
        image.draw(in: drawRect)
        UIGraphicsPopContext()
    }
}
#endif
