import Operative
import CoreFoundationLib

final class UpdateSubscriptionOperative: Operative {
    var dependencies: DependenciesInjector & DependenciesResolver
    var container: OperativeContainerProtocol? {
        didSet {
            self.buildSteps()
        }
    }
    var steps: [OperativeStep] = []
    var isActivation: Bool
    
    private lazy var operativeData: UpdateSubscriptionOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: UpdateSubscriptionFinishingCoordinatorProtocol.self)
    }()

    enum FinishingOption {
        case cardsHome
        case globalPosition
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependencies.resolve(for: UseCaseHandler.self)
    }
    
    lazy var getSignPatternUseCase: GetSignPatternUseCaseAlias = {
        self.dependencies.resolve(for: GetSignPatternUseCaseAlias.self)
    }()
    lazy var startSignPatternUseCase: StartSignPatternUseCaseAlias = {
        self.dependencies.resolve(for: StartSignPatternUseCaseAlias.self)
    }()
    lazy var getSignPositionsUseCase: BasicSignValidationUseCaseAlias = {
        self.dependencies.resolve(for: BasicSignValidationUseCaseAlias.self)
    }()
    lazy var activateSubscriptionUseCase: ActivateSubscriptionUseCaseAlias = {
        self.dependencies.resolve(for: ActivateSubscriptionUseCaseAlias.self)
    }()
    lazy var deactivateSubscriptionUseCase: DeactivateSubscriptionUseCaseAlias = {
        self.dependencies.resolve(for: DeactivateSubscriptionUseCaseAlias.self)
    }()

    init(dependencies: DependenciesInjector & DependenciesResolver, isActivation: Bool) {
        self.dependencies = dependencies
        self.isActivation = isActivation
        self.setupDependencies()
    }
}

extension UpdateSubscriptionOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        Scenario(useCase: getSignPatternUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] output in
                guard let strongSelf = self else { return }
                strongSelf.operativeData.pattern = output.pattern ?? .SIGN01
                strongSelf.container?.save(strongSelf.operativeData)
                if strongSelf.isActivation {
                    strongSelf.operativeData.pattern = .SIGN01
                }
                strongSelf.rebuildSteps()
                strongSelf.setupSign(success: success, failed: failed)
            }
            .onError {  [weak self] _ in
                guard let self = self else { return }
                self.showTopAlertError(localized("generic_error_disablePayments"))
                failed(OperativeSetupError(title: nil, message: nil))
            }
    }
}

extension UpdateSubscriptionOperative: OperativeSignatureCapable {
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signature: SignBasicOperationEntity? = self.container?.get()
        let input = BasicSignValidationInput(magicPhrase: signature?.magicPhrase ?? "",
                                             signatureData: signature?.signatureData,
                                             isOTPNull: false)
        Scenario(useCase: self.getSignPositionsUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let strongSelf = self else { return }
                strongSelf.container?.save(output.signBasicOperationEntity)
                switch strongSelf.operativeData.pattern {
                case .SIGN01:
                    strongSelf.handleIsActivationForSign01(output, strongSelf: strongSelf) { (isSuccess) in
                        completion(isSuccess, nil)
                    }
                case .SIGN02:
                    completion(true, nil)
                }
            }
            .onError { errorResult in
                switch errorResult {
                case .error(let signatureError):
                    completion(false, signatureError)
                default:
                    completion(false, nil)
                }
            }
    }
}

extension UpdateSubscriptionOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let signature: SignBasicOperationEntity? = self.container?.get()
        let magicPhrase = signature?.magicPhrase ?? ""
        let ticketOTP = signature?.otpData?.ticketOTP ?? ""
        let codeOTP = presenter.code
        let input = BasicSignValidationInput(magicPhrase: magicPhrase, codeOTP: codeOTP, ticketOTP: ticketOTP)
        Scenario(useCase: self.getSignPositionsUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let strongSelf = self else { return }
                strongSelf.container?.save(output.signBasicOperationEntity)
                strongSelf.handleIsActivationForSign01(output, strongSelf: strongSelf) { (isSuccess) in
                    completion(isSuccess, nil)
                }
            }
            .onError { errorResult in
                switch errorResult {
                case .error(let useCaseError):
                    let otpError = GenericErrorOTPErrorOutput(useCaseError?.getErrorDesc(), .wrongOTP, useCaseError?.errorCode)
                    completion(false, otpError)
                default:
                    completion(false, nil)
                }
            }
    }
}

extension UpdateSubscriptionOperative: OperativeFinishingCoordinatorCapable {}

extension UpdateSubscriptionOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.steps.removeAll()
        switch self.operativeData.pattern {
        case .SIGN01:
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
            self.steps.append(UpdateSubscriptionSummaryStep(dependenciesResolver: dependencies))
        case .SIGN02:
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
            self.steps.append(OTPStep(dependenciesResolver: dependencies))
            self.steps.append(UpdateSubscriptionSummaryStep(dependenciesResolver: dependencies))
        }
    }
}

private extension UpdateSubscriptionOperative {
    func buildSteps() {
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        self.steps.append(UpdateSubscriptionSummaryStep(dependenciesResolver: dependencies))
    }

    func setupDependencies() {
        self.setupSignature()
        self.setupSummary()
    }

    func setupSignature() {
        self.dependencies.register(for: StartSignPatternUseCaseAlias.self) { resolver in
            StartSignPatternUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: GetSignPatternUseCaseAlias.self) { resolver in
            GetSignPatternUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: BasicSignValidationUseCaseAlias.self) { resolver in
            BasicSignValidationUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ActivateSubscriptionUseCaseAlias.self) { resolver in
            ActivateSubscriptionUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: DeactivateSubscriptionUseCaseAlias.self) { resolver in
            DeactivateSubscriptionUseCase(dependenciesResolver: resolver)
        }
    }

    func setupSummary() {
        self.dependencies.register(for: UpdateSubscriptionSummaryPresenterProtocol.self) { resolver in
            UpdateSubscriptionSummaryPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: UpdateSubscriptionSummaryPresenterProtocol.self)
            let viewController = OperativeSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupSign(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        let input = StartSignPatternInput(pattern: self.operativeData.pattern.rawValue, instaID: self.operativeData.instaId ?? "")
        Scenario(useCase: self.startSignPatternUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onError {  [weak self] _ in
                guard let self = self else { return }
                self.showTopAlertError(localized("generic_error_disablePayments"))
                failed(OperativeSetupError(title: nil, message: nil))
            }
            .then(scenario: self.getGetSignPositionsScenario)
            .onSuccess({ [weak self] output in
                guard let self = self else { return }
                self.container?.save(output.signBasicOperationEntity)
                success()
            })
            .onError {  [weak self] _ in
                guard let self = self else { return }
                self.showTopAlertError(localized("generic_error_disablePayments"))
                failed(OperativeSetupError(title: nil, message: nil))
            }
    }
    
    func getGetSignPositionsScenario(_ output: StartSignPatternUseCaseOkOutput) ->  Scenario<BasicSignValidationInput, BasicSignValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        Scenario(
            useCase: self.getSignPositionsUseCase,
            input: BasicSignValidationInput(magicPhrase: output.signBasicOperationEntity.magicPhrase, signatureData: nil)
        )
    }
    
    func getActivateSubscriptionScenario(_ output: BasicSignValidationUseCaseOkOutput, completion: @escaping (Bool) -> Void) {
        let input = ActivateSubscriptionInput(magicPhrase: output.signBasicOperationEntity.magicPhrase, instaID: self.operativeData.instaId ?? "")
        Scenario(useCase: self.activateSubscriptionUseCase, input: input)
        .execute(on: self.useCaseHandler)
        .onSuccess { _ in
            completion(true)
        }
        .onError { _ in
            completion(false)
        }
    }
    
    func getDeactivateSubscriptionScenario(_ output: BasicSignValidationUseCaseOkOutput, completion: @escaping (Bool) -> Void) {
        let input = DeactivateSubscriptionInput(magicPhrase: output.signBasicOperationEntity.magicPhrase, instaID: self.operativeData.instaId ?? "")
        Scenario(useCase: self.deactivateSubscriptionUseCase, input: input)
        .execute(on: self.useCaseHandler)
        .onSuccess { _ in
            completion(true)
        }
        .onError { _ in
            completion(false)
        }
    }
    
    func handleIsActivationForSign01(_ output: BasicSignValidationUseCaseOkOutput, strongSelf: UpdateSubscriptionOperative, completion: @escaping (Bool) -> Void) {
        if !self.isActivation {
            self.getActivateSubscriptionScenario(output, completion: completion)
        } else {
            self.getDeactivateSubscriptionScenario(output, completion: completion)
        }
    }
}

extension UpdateSubscriptionOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        let path = isActivation ? "APP-RET-m4m-deactiv-SUCCESS-ES" : "APP-RET-m4m-activ-SUCCESS-ES"
        return RegularOpinatorInfoEntity(path: path)
    }
}

extension UpdateSubscriptionOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        let path = isActivation ? "APP-RET-m4m-deact-ABANDON-ES" : "APP-RET-m4m-activ-ABANDON-ES"
        return GiveUpOpinatorInfoEntity(path: path)
    }
}

extension UpdateSubscriptionOperative: TopErrorAlertCapable { }

extension UpdateSubscriptionOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return CardSubscriptionDetailPage().page
    }
}

extension UpdateSubscriptionOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [:]
    }
}
