import CoreFoundationLib
import UI
import CoreDomain

public protocol SignaturePresentationDelegate: OperativeView { }

extension SignaturePresentationDelegate {
    
    public func showFatalErrorDialog(
        title: LocalizedStylableText? = nil,
        description: LocalizedStylableText? = nil,
        phone: String? = nil,
        image: String? = nil,
        action: Dialog.Action? = nil,
        isCloseOptionAvailable: Bool = true,
        stringLoader: StringLoader
    ) {
        HapticTrigger.operativeError()
        self.showDialog(
            title: title,
            description: description,
            phone: phone,
            image: image,
            action: action,
            isCloseOptionAvailable: isCloseOptionAvailable,
            stringLoader: stringLoader
        )
    }
    
    public func showDialog(
        title: LocalizedStylableText? = nil,
        description: LocalizedStylableText? = nil,
        phone: String? = nil,
        image: String? = nil,
        action: Dialog.Action? = nil,
        isCloseOptionAvailable: Bool = true,
        stringLoader: StringLoader
    ) {
        let descriptionText: LocalizedStylableText = {
            guard let phoneText = phone.flatMap({ self.fullPhoneDescription(phone: $0, description: description?.text, stringLoader: stringLoader) }) else {
                return localized("generic_error_internetConnection")
            }
            return phoneText
        }()
        self.showOldDialog(
            title: title,
            description: descriptionText,
            acceptAction: DialogButtonComponents(titled: LocalizedStylableText(text: action?.title ?? localized("generic_button_accept"), styles: []), does: action?.action),
            cancelAction: nil,
            isCloseOptionAvailable: isCloseOptionAvailable
        )
    }
    
    func fullPhoneDescription(phone: String, description: String?, stringLoader: StringLoader) -> LocalizedStylableText? {
        guard let description = description else { return nil }
        return stringLoader.getWsErrorWithNumber(description, phone)
    }
}

public protocol OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void)
    var isProgressBarEnabled: Bool { get }
    var progressBarBackgroundColor: UIColor { get }
}

public extension OperativeSignatureCapable {
    var isProgressBarEnabled: Bool {
        return true
    }
    var progressBarBackgroundColor: UIColor {
        return .skyGray
    }
}

public protocol OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String { get }
}

public final class SignatureStep: OperativeStep, OperativeStepEvaluateCapable {
    
    private let dependencies: DependenciesDefault
    public weak var view: OperativeView? {
        self.dependencies.resolve(firstTypeOf: InternalSignatureViewProtocol.self)
    }
    public var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    public var shouldCountForContinueButton: Bool {
        return false
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func evaluateBeforeShowing(container: OperativeContainerProtocol?, action: @escaping (EvaluateBeforeShowing) -> Void) {
        guard container?.operative is OperativeSignatureCapable else { return action(.skip) }
        action(.show)
    }
    
    private func setupDependencies() {
        self.dependencies.register(for: InternalSignaturePresenterProtocol.self) { resolver in
            SignaturePresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalSignatureViewProtocol.self) { resolver in
            resolver.resolve(for: SignatureViewController.self)
        }
        self.dependencies.register(for: SignatureViewController.self) { resolver in
            let presenter = resolver.resolve(for: InternalSignaturePresenterProtocol.self)
            let viewController = SignatureViewController(nibName: "Signature", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
