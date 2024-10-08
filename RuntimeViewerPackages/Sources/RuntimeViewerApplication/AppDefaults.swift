import Foundation
import RxDefaultsPlus
import RuntimeViewerCore
import RuntimeViewerArchitectures

public class AppDefaults {
    public static let shared = AppDefaults()

    @UserDefault(key: "isInitialSetupSplitView", defaultValue: true)
    public var isInitialSetupSplitView: Bool

    @UserDefault(key: "generationOptions", defaultValue: .init())
    public var options: CDGenerationOptions

    @UserDefault(key: "themeProfile", defaultValue: XcodePresentationTheme())
    public var themeProfile: XcodePresentationTheme

    public static subscript<Value>(keyPath: ReferenceWritableKeyPath<AppDefaults, Value>) -> Value {
        set {
            shared[keyPath: keyPath] = newValue
        }
        get {
            shared[keyPath: keyPath]
        }
    }

    public static subscript<Value>(keyPath: KeyPath<AppDefaults, Value>) -> Value {
        shared[keyPath: keyPath]
    }
}
