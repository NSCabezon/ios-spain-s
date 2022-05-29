import CoreFoundationLib

public enum OTPResult {
    case correctOTP
    case wrongOTP
    case serviceDefault
    case otherError(errorDesc: String)
    case otpExpired
    case otpRevoked
    case unknown
}

public class GenericErrorOTPErrorOutput: StringErrorOutput {
    
    public let otpResult: OTPResult
    public let errorCode: String?
    
    public init(_ errorDesc: String?, _ otpResultType: OTPResult, _ errorCode: String?) {
        self.otpResult = otpResultType
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}

public protocol OTPPresentationDelegate: OperativeView {
    var code: String { get }
}

public protocol OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void)
}

public protocol OperativeOTPNavigationCapable {
    var otpNavigationTitle: String { get }
}

public struct OTPStep: OperativeStep, OperativeStepEvaluateCapable {
 
    private let dependencies: DependenciesDefault
    public weak var view: OperativeView? {
        self.dependencies.resolve(firstTypeOf: OTPViewProtocol.self)
    }
    public var presentationType: OperativeStepPresentationType = .inNavigation(showsBack: true, showsCancel: true)
    
    public var shouldCountForContinueButton: Bool {
        return false
    }
    
    public func evaluateBeforeShowing(container: OperativeContainerProtocol?, action: @escaping (EvaluateBeforeShowing) -> Void) {
        guard let container = container else { return }
        guard container.operative is OperativeOTPCapable else {
            return action(.showError(nil, onErrorAcceptAction: container.goToFirstOperativeStep))
        }
        guard let otp: OTPValidationEntity = container.getOptional(), otp.isOTPExcepted else {
            return action(.show)
        }
        
        guard let viewDelegate = view as? OTPPresentationDelegate, let otpCapable = container.operative as? OperativeOTPCapable else {
            return action(.showError(nil, onErrorAcceptAction: container.goToFirstOperativeStep))
        }
        container.handler?.showOperativeLoading {
            otpCapable.performOTP(for: viewDelegate) { result, error  in
                container.handler?.hideOperativeLoading {
                    if !result {
                        let parsedError = (self.view?.operativePresenter as? OTPPresenter)?.parseError(error: error)
                        action(.showError(parsedError, onErrorAcceptAction: container.goToFirstOperativeStep))
                    } else {
                        action(.skip)
                    }
                }
            }
        }
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setupDependencies() {
        self.dependencies.register(for: OTPPresenterProtocol.self) { resolver in
            OTPPresenter(dependencies: resolver)
        }
        self.dependencies.register(for: OTPViewProtocol.self) { resolver in
            resolver.resolve(for: OTPViewController.self)
        }
        self.dependencies.register(for: OTPViewController.self) { resolver in
            let presenter = resolver.resolve(for: OTPPresenterProtocol.self)
            let viewController = OTPViewController(nibName: "OTP", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
