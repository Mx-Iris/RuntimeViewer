#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

import UIFoundation
import RuntimeViewerCore

public struct AnyThemeProfile<Theme: ThemeProfile & Codable>: Codable {
    public var wrappedValue: Theme
    public init(wrappedValue: Theme) {
        self.wrappedValue = wrappedValue
    }
}

public protocol ThemeProfile {
    var selectionBackgroundColor: NSUIColor { set get }
    var backgroundColor: NSUIColor { set get }
    var fontSize: CGFloat { set get }
    func font(for type: CDSemanticType) -> NSUIFont
    func color(for type: CDSemanticType) -> NSUIColor
    mutating func fontSizeSmaller()
    mutating func fontSizeLarger()
}

public struct XcodePresentationTheme: ThemeProfile, Codable {
    @SecureCodingCodable
    public var selectionBackgroundColor: NSUIColor = #colorLiteral(red: 0.3904261589, green: 0.4343567491, blue: 0.5144847631, alpha: 1)
    
    @SecureCodingCodable
    public var backgroundColor: NSUIColor = .init(light: #colorLiteral(red: 1, green: 0.9999999404, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.1251632571, green: 0.1258862913, blue: 0.1465735137, alpha: 1))

    public var fontSize: CGFloat = 13
    
    public func font(for type: CDSemanticType) -> NSUIFont {
        switch type {
        case .keyword:
            return .monospacedSystemFont(ofSize: fontSize, weight: .semibold)
        default:
            return .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
    }

    private static var colorCache: [CDSemanticType: NSUIColor] = [:]
    
    public func color(for type: CDSemanticType) -> NSUIColor {
        if let existColor = Self.colorCache[type] {
            return existColor
        }
        let light: NSUIColor
        let dark: NSUIColor
        switch type {
        case .comment:
            light = #colorLiteral(red: 0.4095562398, green: 0.4524990916, blue: 0.4956067801, alpha: 1)
            dark = #colorLiteral(red: 0.4976348877, green: 0.5490466952, blue: 0.6000126004, alpha: 1)
        case .keyword:
            light = #colorLiteral(red: 0.7660875916, green: 0.1342913806, blue: 0.4595085979, alpha: 0.8)
            dark = #colorLiteral(red: 0.9686241746, green: 0.2627249062, blue: 0.6156817079, alpha: 1)
        case .variable,
             .method:
            light = #colorLiteral(red: 0.01979870349, green: 0.4877431393, blue: 0.6895453334, alpha: 1)
            dark = #colorLiteral(red: 0.2426597476, green: 0.7430019975, blue: 0.8773110509, alpha: 1)
        case .recordName,
             .class,
             .protocol:
            light = #colorLiteral(red: 0.2404940426, green: 0.115125142, blue: 0.5072092414, alpha: 1)
            dark = #colorLiteral(red: 0.853918612, green: 0.730949223, blue: 1, alpha: 1)
        case .numeric:
            light = #colorLiteral(red: 0.01564520039, green: 0.2087542713, blue: 1, alpha: 1)
            dark = #colorLiteral(red: 1, green: 0.9160019755, blue: 0.5006220341, alpha: 1)
        default:
            return .labelColor
        }
        let color = NSUIColor(light: light, dark: dark)
        Self.colorCache[type] = color
        return color
    }
    
    public mutating func fontSizeSmaller() {
        fontSize -= 1
    }
    
    public mutating func fontSizeLarger() {
        fontSize += 1
    }
}


