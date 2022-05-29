import Foundation
import CoreFoundationLib
import Operative

final class BizumRefundMoneyOperative: Operative {
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        return self.dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
}

extension BizumRefundMoneyOperative: OperativeFinishingCoordinatorCapable {}

extension BizumRefundMoneyOperative: OperativeSetupCapable, BizumCommonSetupCapable {
    func performSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        let useCase = self.dependencies.resolve(for: SetupBizumRefundMoneyUseCase.self)
        let input = SetupBizumRefundMoneyUseCaseInput(checkPayment: self.operativeData.checkPayment)
        let scenario = Scenario(useCase: useCase, input: input)
        self.bizumSetupWithScenario(scenario) { [weak self] result in
            guard let self = self else { return }
            self.operativeData.account = result.account
            self.operativeData.document = result.document
            self.container?.save(self.operativeData)
            success()
        }
    }
}

extension BizumRefundMoneyOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = self.container, let iban = self.operativeData.account?.getIban() else { return completion(false, nil) }
        let useCase = self.dependencies.resolve(for: SignRefundMoneyUseCase.self)
        let input = SignRefundMoneyUseCaseInput(iban: iban, signature: container.get(), amount: self.operativeData.totalAmount)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] result in
                self?.container?.save(result.otpValidation)
                completion(true, nil)
            }.onError { [weak self] error in
                switch error {
                case .error(let signatureError):
                    self?.trackErrorEvent(page: BizumRefundMoneySignaturePage().page, error: signatureError?.errorDescription, code: signatureError?.errorCode)
                    completion(false, signatureError)
                case .generic, .intern, .networkUnavailable:
                    self?.trackErrorEvent(page: BizumRefundMoneySignaturePage().page, error: nil, code: nil)
                    completion(false, nil)
                case .unauthorized:
                    presenter.dismissLoading {
                        self?.dependencies.resolve(for: SessionResponseController.self).recivenUnauthorizedResponse()
                    }
                }
            }
    }
}

extension BizumRefundMoneyOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container, let document = self.operativeData.document else { return completion(false, nil) }
        let useCase = self.dependencies.resolve(for: ConfirmRefundMoneyUseCase.self)
        let input = ConfirmRefundMoneyUseCaseInput(checkPayment: operativeData.checkPayment, operation: operativeData.operation, otp: container.get(), otpCode: presenter.code, amount: operativeData.totalAmount, document: document)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] _ in
                self?.sendSimpleMultimediaWithoutChecking()
                completion(true, nil)
            }.onError { [weak self] error in
                switch error {
                case .error(error: let otpError):
                    completion(false, GenericErrorOTPErrorOutput(
                        otpError?.errorDescription ?? localized("otp_error_unsuccessful"),
                        otpError?.otpResult ?? .serviceDefault,
                        otpError?.errorCode))
                case .generic, .intern, .networkUnavailable:
                    completion(false, GenericErrorOTPErrorOutput(
                        localized("otp_error_unsuccessful"),
                        .serviceDefault,
                        nil))
                case .unauthorized:
                    presenter.dismissLoading {
                        self?.dependencies.resolve(for: SessionResponseController.self).recivenUnauthorizedResponse()
                    }
                }
            }
    }
}

extension BizumRefundMoneyOperative: OperativeGlobalPositionReloaderCapable {}

extension BizumRefundMoneyOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        return RegularOpinatorInfoEntity(path: "app-bizum-devolver-dinero-exito")
    }
}

extension BizumRefundMoneyOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        return GiveUpOpinatorInfoEntity(path: "app-bizum-devolver-dinero-abandono")
    }
}

extension BizumRefundMoneyOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return self.dependencies.resolve()
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}

extension BizumRefundMoneyOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return BizumRefundMoneySignaturePage().page
    }
}

extension BizumRefundMoneyOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        return BizumRefundMoneyOTPPage().page
    }
}

extension BizumRefundMoneyOperative: BizumOperativeSendSimpleMultimediaCapable {
    var receiverUserId: String {
        return self.operativeData.operation.emitterId?.trim() ?? ""
    }
    
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
    
    var checkPayment: BizumCheckPaymentEntity {
        return self.operativeData.checkPayment
    }
    
    var multimedia: BizumMultimediaData? {
        return BizumMultimediaData(image: nil, note: self.operativeData.comment)
    }
    
    var operationId: String {
        return self.operativeData.operation.operationId ?? ""
    }
    
    var operationType: BizumSendMultimediaOperationType {
        return .refundMoney
    }
}

private extension BizumRefundMoneyOperative {
    var operativeData: BizumRefundMoneyOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    
    func setupDependencies() {
        self.setupBizumRefundMoneyConfirmation()
        self.setupBizumRefundMoneySummary()
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { resolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SetupBizumRefundMoneyUseCase.self) { resolver in
            return SetupBizumRefundMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetMultimediaUsersUseCase.self) { resolver in
            return GetMultimediaUsersUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMultimediaSimpleUseCase.self) { resolver in
            return SendMultimediaSimpleUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SignRefundMoneyUseCase.self) { resolver in
            return SignRefundMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ConfirmRefundMoneyUseCase.self) { resolver in
            return ConfirmRefundMoneyUseCase(dependenciesResolver: resolver)
        }
    }
    
    func buildSteps() {
        self.steps.append(BizumRefundMoneyConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(BizumRefundMoneySummaryStep(dependenciesResolver: dependencies))
    }
    
    func setupBizumRefundMoneyConfirmation() {        
        self.dependencies.register(for: SignPosSendMoneyUseCase.self) { resolver in
            SignPosSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumRefundMoneyConfirmationPresenterProtocol.self) { resolver in
            BizumRefundMoneyConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumRefundMoneyConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumRefundMoneyConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumRefundMoneyConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumRefundMoneyConfirmationPresenterProtocol.self)
            let viewController = BizumRefundMoneyConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupBizumRefundMoneySummary() {
        self.dependencies.register(for: BizumRefundMoneySummaryPresenterProtocol.self) { resolver in
            BizumRefundMoneySummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: BizumRefundMoneySummaryViewController.self)
        }
        self.dependencies.register(for: BizumRefundMoneySummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumRefundMoneySummaryPresenterProtocol.self)
            let viewController = BizumRefundMoneySummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
