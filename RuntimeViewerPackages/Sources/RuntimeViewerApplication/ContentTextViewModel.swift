#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

import RuntimeViewerCore
import RuntimeViewerUI
import RuntimeViewerArchitectures

public class ContentTextViewModel: ViewModel<ContentRoute> {
    @Observed
    public private(set) var theme: ThemeProfile

    @Observed
    public private(set) var runtimeObject: RuntimeObjectType

    @Observed
    public private(set) var attributedString: NSAttributedString?

    public init(runtimeObject: RuntimeObjectType, appServices: AppServices, router: any Router<ContentRoute>) {
        self.runtimeObject = runtimeObject
        self.theme = XcodePresentationTheme()
        super.init(appServices: appServices, router: router)
        Observable.combineLatest($runtimeObject, AppDefaults[\.$options], AppDefaults[\.$themeProfile])
            .observeOnMainScheduler()
            .flatMap { [unowned self] runtimeObject, options, theme -> NSAttributedString? in
                let semanticString = try await self.appServices.runtimeListings.semanticString(for: runtimeObject, options: options)
                return await MainActor.run {
                    semanticString.attributedString(for: theme)
                }
            }
            .catchAndReturn(nil)
            .bind(to: $attributedString)
            .disposed(by: rx.disposeBag)
    }

    public struct Input {
        public let runtimeObjectClicked: Signal<RuntimeObjectType>
        public init(runtimeObjectClicked: Signal<RuntimeObjectType>) {
            self.runtimeObjectClicked = runtimeObjectClicked
        }
    }

    public struct Output {
        public let attributedString: Driver<NSAttributedString>
        public let runtimeObjectName: Driver<String>
        public let theme: Driver<ThemeProfile>
    }

//    private func setAttributedString(for options: CDGenerationOptions) {
//        switch runtimeObject {
//        case let .class(named):
//            if let cls = NSClassFromString(named) {
//                let classModel = CDClassModel(with: cls)
//                attributedString = classModel.semanticLines(with: options).attributedString(for: theme)
//            } else {
//                attributedString = NSAttributedString {
//                    AText("\(named) class not found.")
//                }
//            }
//        case let .protocol(named):
//            if let proto = NSProtocolFromString(named) {
//                let protocolModel = CDProtocolModel(with: proto)
//                attributedString = protocolModel.semanticLines(with: options).attributedString(for: theme)
//            } else {
//                attributedString = NSAttributedString {
//                    AText("\(named) protocol not found.")
//                }
//            }
//        }
//    }

    public func transform(_ input: Input) -> Output {
        input.runtimeObjectClicked.emit(with: self) { $0.router.trigger(.next($1)) }.disposed(by: rx.disposeBag)
        return Output(
            attributedString: $attributedString.asDriver().compactMap { $0 },
            runtimeObjectName: $runtimeObject.asDriver().map { $0.name },
            theme: $theme.asDriver()
        )
    }
}

extension NSAttributedString: @unchecked Sendable {}
