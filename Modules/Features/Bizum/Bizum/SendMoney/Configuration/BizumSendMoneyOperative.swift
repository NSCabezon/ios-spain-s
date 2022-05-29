import Operative
import CoreFoundationLib
import UI

// MARK: - Operative
final class BizumSendMoneyOperative: BizumMoneyOperative, OperativeJumpToStepCapable {
    let dependencies: DependenciesInjector & DependenciesResolver
    var initialStep: Int
    weak var container: OperativeContainerProtocol? {
        didSet {
            self.evaluateBiometricValidation()
            self.buildSteps()
        }
    }
    private lazy var operativeData: BizumSendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: BizumFinishingCoordinatorProtocol.self)
    }()

    private var isBiometryEnabled: Bool {
        let enableBizumBiometricSendmoney = dependencies
            .resolve(forOptionalType: AppConfigRepositoryProtocol.self)?
            .getBool("enableBizumBiometricSendmoney") ?? false
        return biometricsManager.isTouchIdEnabled && enableBizumBiometricSendmoney
    }

    private var biometricsManager: LocalAuthenticationPermissionsManagerProtocol {
        self.dependenciesResolver.resolve(for: LocalAuthenticationPermissionsManagerProtocol.self)
    }

    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        return self.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()

    init(dependencies: DependenciesInjector & DependenciesResolver, initialStep: Int) {
        self.dependencies = dependencies
        self.initialStep = initialStep
        self.setupDependencies()
    }

    func evaluateBiometricValidation() {
        otpPushManager?.updateToken(completion: { [weak self] _, state in
            guard let strongSelf = self, let state = state else { return }
            strongSelf.operativeData.isBiometricValidationEnable = state == .rightRegisteredDevice && strongSelf.isBiometryEnabled
        })
    }
}

extension BizumSendMoneyOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        let type = self.operativeData.typeUserInSimpleSend
        self.steps.append(BizumContactSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(BizumAmountStep(dependenciesResolver: dependencies))
        switch type {
        case .noRegister: break
        case .register: self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        }
        if !(self.operativeData.isBiometricValidationEnable && self.operativeData.isBiometricEnable) {
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
            self.steps.append(OTPStep(dependenciesResolver: dependencies))
        }
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }
}
// MARK: - Private Methods

private extension BizumSendMoneyOperative {
    func buildSteps() {
        self.steps.append(BizumContactSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(BizumAmountStep(dependenciesResolver: dependencies))
        self.steps.append(BizumConfirmationStep(dependenciesResolver: dependencies))
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
        self.steps.append(BizumSendMoneySummaryStep(dependenciesResolver: dependencies))
    }

    func setupDependencies() {
        self.setupContacts()
        self.setupAmount()
        self.setupAmountUseCases()
        self.setupConfirmation()
        self.setupSignature()
        self.setupOtp()
        self.setupSummary()
        self.dependencies.register(for: BizumWebViewConfigurationUseCaseProtocol.self) { dependenciesResolver in
            return BizumWebViewConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
    }

    func setupAmountUseCases() {
        self.dependencies.register(for: BizumValidateMoneyTransferMultiUseCase.self) { dependenciesResolver in
            return BizumValidateMoneyTransferMultiUseCase(dependencies: dependenciesResolver)
        }
        self.dependencies.register(for: BizumValidateMoneyTransferUseCase.self) { dependenciesResolver in
            return BizumValidateMoneyTransferUseCase(dependencies: dependenciesResolver)
        }
    }

    func setupSignature() {
        self.dependencies.register(for: BizumValidateMoneyTransferOTPUseCase.self) { resolver in
            BizumValidateMoneyTransferOTPUseCase(dependenciesResolver: resolver)
        }
    }

    func setupOtp() {
        self.dependencies.register(for: BizumSendMoneyInviteClientOTPUseCase.self) { resolver in
            BizumSendMoneyInviteClientOTPUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumMoneyTransferOTPUseCase.self) { resolver in
            BizumMoneyTransferOTPUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumMoneyTransferOTPMultiUseCase.self) { resolver in
            BizumMoneyTransferOTPMultiUseCase(dependenciesResolver: resolver)
        }
    }

    func setupConfirmation() {
        self.dependencies.register(for: GetLocalPushTokenUseCase.self) { dependenciesResolver in
            return GetLocalPushTokenUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: BizumMoneyTransferOTPUseCase.self) { resolver in
            BizumMoneyTransferOTPUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumConfirmationCoordinatorProtocol.self) { resolver in
            BizumConfirmationCoordinator(
                dependenciesResolver: resolver,
                navigationController: self.container?.coordinator.navigationController ?? UINavigationController()
            )
        }
        self.dependencies.register(for: SignPosSendMoneyUseCase.self) { resolver in
            SignPosSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumConfirmationPresenterProtocol.self) { resolver in
            BizumConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BizumConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: BizumConfirmationViewController.self)
        }
        self.dependencies.register(for: BizumConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumConfirmationPresenterProtocol.self)
            let viewController = BizumConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSummary() {
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: BizumSendMoneySummaryPresenterProtocol.self) { resolver in
            return BizumSendMoneySummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: GetIsWhatsAppSharingEnabledUseCase.self) { resolver in
            return GetIsWhatsAppSharingEnabledUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: BizumSendMoneySummaryPresenterProtocol.self)
            let viewController = BizumSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension BizumSendMoneyOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = self.container,
              let amount = operativeData.bizumSendMoney?.amount,
              let numberOfRecipients = operativeData.bizumContactEntity?.count else {
            completion(false, nil)
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        let signature: SignatureWithTokenEntity = container.get()
        let input = BizumValidateMoneyTransferOTPInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            signatureWithToken: signature,
            amount: amount,
            numberOfRecipients: numberOfRecipients,
            account: operativeData.accountEntity,
            footPrint: nil,
            deviceToken: nil
        )
        Scenario(useCase: self.dependencies.resolve(for: BizumValidateMoneyTransferOTPUseCase.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { result in
                let validateMoneyTransferOTPEntity = result.validateMoneyTransferOTPEntity
                operativeData.validateMoneyTransferOTPEntity = validateMoneyTransferOTPEntity
                container.save(operativeData)
                container.save(validateMoneyTransferOTPEntity.otp)
                completion(true, nil)
            }
            .onError { result in
                switch result {
                case .error(let signatureError):
                    completion(false, signatureError)
                default:
                    completion(false, nil)
                }
            }
    }
}

extension BizumSendMoneyOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard self.operativeData.validateMoneyTransferOTPEntity != nil  else {
            completion(false, nil)
            return
        }
        switch (operativeData.bizumContactEntity?.count == 1, operativeData.typeUserInSimpleSend ) {
        case (false, _):// Multiple
            self.performMultiOTP(for: presenter, completion: completion)
        case (true, .noRegister):// Simple, Invitar
            self.performSimpleInviteOTP(for: presenter, completion: completion)
        case (true, .register):// Simple
            self.performSimpleOTP(for: presenter, completion: completion)
        }
    }
    
    func performSimpleInviteOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container,
              let amount = operativeData.bizumSendMoney?.amount,
              let bizumValidateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity else {
            completion(false, nil)
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        let otpValidation: OTPValidationEntity = container.get()
        let input = BizumSendMoneyInviteClientOTPUseCaseInput(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            otpCode: presenter.code,
            validateMoneyTransfer: bizumValidateMoneyTransferEntity,
            amount: amount
        )
        Scenario(useCase: self.dependencies.resolve(for: BizumSendMoneyInviteClientOTPUseCase.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { _ in
                let operativeData: BizumSendMoneyOperativeData = container.get()
                if let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
                   let contacts = operativeData.bizumContactEntity {
                    let phones: [String] = contacts.map({ $0.phone })
                    self.performSendMultimedia(phones.first)
                }
                completion(true, nil)
            }
            .onError { result in
                switch result {
                case .error(error: let otpError):
                    completion(false, GenericErrorOTPErrorOutput(
                        otpError?.errorDescription ?? localized("otp_error_unsuccessful"),
                        otpError?.otpResult ?? .serviceDefault,
                        otpError?.errorCode))
                default:
                    completion(false, GenericErrorOTPErrorOutput(
                        localized("otp_error_unsuccessful"),
                        .serviceDefault,
                        nil))
                }
            }
    }
    
    func performSimpleOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container,
              let document = operativeData.document,
              let contact = operativeData.bizumContactEntity?.first,
              let amount = operativeData.bizumSendMoney?.amount,
              let bizumValidateMoneyTransferEntity = operativeData.bizumValidateMoneyTransferEntity else {
            completion(false, nil)
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        let otpValidation: OTPValidationEntity = container.get()
        let input = BizumMoneyTransferOTPInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            document: document,
            otpCode: presenter.code,
            validateMoneyTransfer: bizumValidateMoneyTransferEntity,
            dateTime: Date(),
            concept: operativeData.bizumSendMoney?.concept ?? "",
            amount: amount,
            receiverUserId: contact.phone,
            account: operativeData.accountEntity,
            tokenPush: ""
        )
        let useCase = self.dependencies.resolve(for: BizumMoneyTransferOTPUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                let operativeData: BizumSendMoneyOperativeData = container.get()
                if let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
                   let contacts = operativeData.bizumContactEntity {
                    let phones: [String] = contacts.map({ $0.phone })
                    self.performSendMultimedia(phones.first)
                }
                completion(true, nil)
            }, onError: { result in
                switch result {
                case .error(error: let otpError):
                    completion(false, GenericErrorOTPErrorOutput(
                        otpError?.errorDescription ?? localized("otp_error_unsuccessful"),
                        otpError?.otpResult ?? .serviceDefault,
                        otpError?.errorCode))
                default:
                    completion(false, GenericErrorOTPErrorOutput(
                        localized("otp_error_unsuccessful"),
                        .serviceDefault,
                        nil))
                }
            }
        )
    }
    
    func performMultiOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = self.container,
              let document = operativeData.document,
              let amount = operativeData.bizumSendMoney?.amount,
              let bizumValidateMoneyTransferMultiEntity = operativeData.bizumValidateMoneyTransferMultiEntity else {
            completion(false, nil)
            return
        }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        let otpValidation: OTPValidationEntity = container.get()
        let input = BizumMoneyTransferOTPMultiInputUseCase(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            otpValidation: otpValidation,
            document: document,
            otpCode: presenter.code,
            validateMoneyTransferMulti: bizumValidateMoneyTransferMultiEntity,
            dateTime: Date(),
            concept: operativeData.bizumSendMoney?.concept ?? "",
            amount: amount,
            account: operativeData.accountEntity,
            tokenPush: ""
        )
        Scenario(useCase: self.dependencies.resolve(for: BizumMoneyTransferOTPMultiUseCase.self.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { _ in
                let operativeData: BizumSendMoneyOperativeData = container.get()
                if let multimediaData = operativeData.multimediaData, multimediaData.hasSomeValue(),
                   let contacts = operativeData.bizumContactEntity {
                    let phones: [String] = contacts.map({ $0.phone })
                    self.performSendMultimedia(phones)
                }
                completion(true, nil)
            }
            .onError { result in
                switch result {
                case .error(error: let otpError):
                    completion(false, GenericErrorOTPErrorOutput(
                        otpError?.errorDescription ?? localized("otp_error_unsuccessful"),
                        otpError?.otpResult ?? .serviceDefault,
                        otpError?.errorCode))
                default:
                    completion(false, GenericErrorOTPErrorOutput(
                        localized("otp_error_unsuccessful"),
                        .serviceDefault,
                        nil))
                }
            }
    }
}

extension BizumSendMoneyOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-envio-exito")
    }
}

extension BizumSendMoneyOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-envio-abandono")
    }
}

extension BizumSendMoneyOperative: OperativeFinishingCoordinatorCapable {}

extension BizumSendMoneyOperative: ShareOperativeCapable {
    // MARK: - ShareBizumView
    /// The modalPresentationStyle is overCurrentContext because avoid screen rotation
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        guard let container = self.container else { return }
        let operativeData: BizumSendMoneyOperativeData = container.get()
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        Scenario(useCase: useCase)
            .execute(on: dependencies.resolve())
            .onSuccess { [weak self] response in
                let shareView = ShareBizumView()
                let viewModel = ShareBizumSummaryViewModel(
                    bizumOperativeType: operativeData.bizumOperativeType,
                    bizumAmount: operativeData.bizumSendMoney?.amount,
                    bizumConcept: operativeData.bizumSendMoney?.concept,
                    simpleMultipleType: operativeData.simpleMultipleType,
                    bizumContacts: operativeData.bizumContactEntity,
                    sentDate: operativeData.operationDate,
                    dependenciesResolver: self?.dependenciesResolver)
                viewModel.setUserName(response.globalPosition.fullName)
                shareView.modalPresentationStyle = .overCurrentContext
                shareView.loadViewIfNeeded()
                shareView.setInfoFromSummary(viewModel)
                completion(.success((shareView, shareView.containerView)))
            }.onError { _ in
                completion(.failure(.generalError))
            }
    }
}
