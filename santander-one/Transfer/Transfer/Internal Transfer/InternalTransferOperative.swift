import CoreFoundationLib
import Operative
import CoreDomain

// MARK: - Operative

final class InternalTransferOperative: Operative {
    
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol?
    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var steps: [OperativeStep] = []
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: InternalTransferFinishingCoordinatorProtocol.self)
    }()
    private var isSelectedAccountStepVisible: Bool = false
    
    private var predefinedSCA: PredefinedSCAEntity? {
        let entity: PredefinedSCAEntity? = self.container?.getOptional()
        return entity
    }
    
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
    
    enum FinishingOption {
        case sendMoney
        case globalPosition
    }
    
    // MARK: - Private
    
    private func setupDependencies() {
        self.setupPreSetup()
        self.setupAccountSelector()
        self.setupAccountDestinationSelector()
        self.setupAmountAndTypeSelector()
        self.setupConfirmation()
        self.setupSummary()
    }
    
    private func setupAccountSelector() {
        self.dependencies.register(for: InternalTransferAccountSelectorPresenterProtocol.self) { resolver in
            InternalTransferAccountSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferAccountSelectorViewProtocol.self) { resolver in
            resolver.resolve(for: InternalTransferAccountSelectorViewController.self)
        }
        self.dependencies.register(for: InternalTransferAccountSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: InternalTransferAccountSelectorPresenterProtocol.self)
            let viewController = InternalTransferAccountSelectorViewController(nibName: "InternalTransferAccountSelector", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    private func setupAccountDestinationSelector() {
        self.dependencies.register(for: ValidateInternalTransferUseCase.self) { resolver in
            ValidateInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferDestinationAccountSelectorPresenterProtocol.self) { resolver in
            InternalTransferDestinationAccountSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferDestinationAccountSelectorViewProtocol.self) { resolver in
            resolver.resolve(for: InternalTransferDestinationAccountSelectorViewController.self)
        }
        self.dependencies.register(for: InternalTransferDestinationAccountSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: InternalTransferDestinationAccountSelectorPresenterProtocol.self)
            let viewController = InternalTransferDestinationAccountSelectorViewController(nibName: "InternalTransferDestinationAccountSelector", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    private func setupAmountAndTypeSelector() {
        self.dependencies.register(for: InternalTransferAmountAndTypeSelectorPresenterProtocol.self) { resolver in
            InternalTransferAmountAndTypeSelectorPresenter(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferAmountAndTypeSelectorViewProtocol.self) { resolver in
            resolver.resolve(for: InternalTransferAmountAndTypeSelectorViewController.self)
        }
        self.dependencies.register(for: InternalTransferAmountAndTypeSelectorViewController.self) { resolver in
            let presenter = resolver.resolve(for: InternalTransferAmountAndTypeSelectorPresenterProtocol.self)
            let viewController = InternalTransferAmountAndTypeSelectorViewController(nibName: "InternalTransferAmountAndTypeSelectorViewController", bundle: .module, presenter: presenter, dependenciesResolver: self.dependencies)
            presenter.view = viewController
            return viewController
        }
    }
    
    private func setupConfirmation() {
        self.setupConfirmationPresenter()
        self.dependencies.register(for: InternalTransferConfirmationViewProtocol.self) { resolver in
            resolver.resolve(for: InternalTransferConfirmationViewController.self)
        }
        self.dependencies.register(for: InternalTransferConfirmationViewController.self) { resolver in
            let presenter = resolver.resolve(for: InternalTransferConfirmationPresenterProtocol.self)
            let viewController = InternalTransferConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    private func setupSummary() {
        self.setupSummaryPresenter()
        self.dependencies.register(for: GetHasOneProductsUseCase.self) { resolver in
            return GetHasOneProductsUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: OperativeSummaryViewProtocol.self) { resolver in
            return resolver.resolve(for: OperativeSummaryViewController.self)
        }
        self.dependencies.register(for: OperativeSummaryViewController.self) { resolver in
            let presenter = resolver.resolve(for: OperativeSummaryPresenterProtocol.self)
            let viewController = OperativeSummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetPullOffersUseCase.self) { resolver in
            return GetPullOffersUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func setupSummaryPresenter() {
        self.dependencies.register(for: OperativeSummaryPresenterProtocol.self) { resolver in
            return InternalTransferSummaryPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupDeferredSummaryPresenter() {
        self.dependencies.register(for: OperativeSummaryPresenterProtocol.self) { resolver in
            return InternalDeferredTransferSummaryPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupPeriodicSummaryPresenter() {
        self.dependencies.register(for: OperativeSummaryPresenterProtocol.self) { resolver in
            return InternalPeriodicTransferSummaryPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupConfirmationPresenter() {
        self.dependencies.register(for: ConfirmInternalTransferUseCaseProtocol.self) { resolver in
            ConfirmInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferConfirmationPresenterProtocol.self) { resolver in
            InternalTransferConfirmationPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupDeferredConfirmationPresenter() {
        self.dependencies.register(for: ConfirmDeferredInternalTransferUseCase.self) { resolver in
            ConfirmDeferredInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferConfirmationPresenterProtocol.self) { resolver in
            InternalDeferredTransferConfirmationPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupPeriodicConfirmationPresenter() {
        self.dependencies.register(for: ConfirmPeriodicInternalTransferUseCase.self) { resolver in
            ConfirmPeriodicInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: InternalTransferConfirmationPresenterProtocol.self) { resolver in
            InternalPeriodicTransferConfirmationPresenter(dependenciesResolver: resolver)
        }
    }
    
    private func setupPreSetup() {
        self.dependencies.register(for: PreSetupInternalTransferUseCaseProtocol.self) { _ in
            return PreSetupInternalTransferUseCase(dependenciesResolver: self.dependencies)
        }
        self.dependencies.register(for: PredefinedSCAInternalTransferUseCaseProtocol.self) { resolver in
            return PredefinedSCAInternalTransferUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func setupSignatureUseCase() {
        self.dependencies.register(for: SignDeferredInternalTransferUseCase.self) { resolver in
            SignDeferredInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SignPeriodicInternalTransferUseCase.self) { resolver in
            SignPeriodicInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SignInternalTransferUseCase.self) { resolver in
            SignInternalTransferUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func setupOtpUseCase() {
        self.dependencies.register(for: ConfirmOTPDeferredInternalTransferUseCaseProtocol.self) { resolver in
            ConfirmOTPDeferredInternalTransferUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: ConfirmOTPPeriodicInternalTransferUseCase.self) { resolver in
            ConfirmOTPPeriodicInternalTransferUseCase(dependenciesResolver: resolver)
        }
    }
    
    private func buildCommonSteps() {
        if operativeData.selectedAccount == nil || isSelectedAccountStepVisible {
            self.steps.append(InternalTransferAccountSelectorStep(dependenciesResolver: dependencies))
            isSelectedAccountStepVisible = true
        }
        self.steps.append(InternalTransferDestinationAccountSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(InternalTransferAmountAndTypeSelectorStep(dependenciesResolver: dependencies))
        self.steps.append(InternalTransferConfirmationStep(dependenciesResolver: dependencies))
    }
    
    private func buildSteps() {
        self.setupConfirmationPresenter()
        self.setupSummaryPresenter()
        self.setupSignatureUseCase()
        self.setupOtpUseCase()
        self.buildCommonSteps()
        self.appendPredefinedSCASteps()
        self.steps.append(TransferSummaryStep(dependenciesResolver: dependencies))
    }
    
    private func appendPredefinedSCASteps() {
        switch self.predefinedSCA {
        case .signature:
            self.steps.append(SignatureStep(dependenciesResolver: dependencies))
        case .otp, .signatureAndOtp, .none:
            break
        }
    }
    
    private func buildNowSteps() {
        self.setupConfirmationPresenter()
        self.setupSummaryPresenter()
        self.buildCommonSteps()
        self.sca?.prepareForVisitor(self)
        self.steps.append(TransferSummaryStep(dependenciesResolver: dependencies))
    }
    
    private func buildDeferredSteps() {
        self.setupDeferredConfirmationPresenter()
        self.setupDeferredSummaryPresenter()
        self.buildCommonSteps()
        self.sca?.prepareForVisitor(self)
        self.steps.append(TransferSummaryStep(dependenciesResolver: dependencies))
    }
    
    private func buildPeriodicSteps() {
        self.setupPeriodicConfirmationPresenter()
        self.setupPeriodicSummaryPresenter()
        self.buildCommonSteps()
        self.sca?.prepareForVisitor(self)
        self.steps.append(TransferSummaryStep(dependenciesResolver: dependencies))
    }
}

// MARK: - Capabilities

extension InternalTransferOperative: OperativePresetupCapable {
    
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil)) }
        Scenario(useCase: self.dependencies.resolve(for: PredefinedSCAInternalTransferUseCaseProtocol.self))
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                container.save(result.predefinedSCAEntiy)
                self?.buildSteps()
            }.then(scenario: {_ in
                Scenario(useCase: self.dependencies.resolve(firstTypeOf: PreSetupInternalTransferUseCaseProtocol.self))
            }, scheduler: self.dependencies.resolve(for: UseCaseHandler.self))
            .onSuccess { result in
                let operativeData: InternalTransferOperativeData = container.get()
                operativeData.accountVisibles = result.accountVisibles
                operativeData.accountNotVisibles = result.accountNotVisibles
                operativeData.faqs = result.faqs
                container.save(operativeData)
                success()
            }.onError { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
            }
    }
}

extension InternalTransferOperative: OperativeRebuildStepsCapable {
    
    func rebuildSteps() {
        switch self.operativeData.time {
        case .now?, .none: self.buildNowSteps()
        case .day?: self.buildDeferredSteps()
        case .periodic?: self.buildPeriodicSteps()
        }
    }
}

extension InternalTransferOperative: OperativeSignatureCapable {
    
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        switch self.operativeData.time {
        case .day?, .periodic?:
            self.signScheduledInternalTransfer(completion: completion)
        case .now, .none:
            self.signInternalTransfer(completion: completion)
        }
    }
    
    private func signInternalTransfer(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard
            let originAccount = self.operativeData.selectedAccount,
            let destinationAccount = self.operativeData.destinationAccount,
            let amount = self.operativeData.amount,
            let signature: SignatureRepresentable = self.container?.get(),
            let transferTime = self.operativeData.time
        else {
            return completion(false, nil)
        }
        let input = SignInternalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: self.operativeData.concept ?? "",
            signature: signature,
            transferTime: transferTime
        )
        UseCaseWrapper(
            with: self.dependencies.resolve(for: SignInternalTransferUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
        )
    }
    
    private func signScheduledInternalTransfer(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard
            let originAccount = self.operativeData.selectedAccount,
            let destinationAccount = self.operativeData.destinationAccount,
            let amount = self.operativeData.amount,
            let signature: SignatureRepresentable = self.container?.get(),
            let transferTime = self.operativeData.time,
            let scheduledTransfer = self.operativeData.scheduledTransfer
        else {
            return completion(false, nil)
        }
        let input = SignScheduledInternalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: self.operativeData.concept ?? "",
            signature: signature,
            transferTime: transferTime,
            scheduledTransfer: scheduledTransfer
        )
        switch transferTime {
        case .day:
            self.signScheduledTransfer(with: self.dependencies.resolve(for: SignDeferredInternalTransferUseCase.self), input: input, completion: completion)
        case .periodic:
            self.signScheduledTransfer(with: self.dependencies.resolve(for: SignPeriodicInternalTransferUseCase.self), input: input, completion: completion)
        default:
            completion(false, nil)
        }
    }
    
    private func signScheduledTransfer(with useCase: UseCase<SignScheduledInternalTransferUseCaseInput, SignScheduledInternalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput>, input: SignScheduledInternalTransferUseCaseInput, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                self.container?.save(result.otp)
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError): completion(false, signatureError)
                default: completion(false, nil)
                }
            }
        )
    }
}

extension InternalTransferOperative: OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension InternalTransferOperative: OperativeOTPCapable {
    
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        switch self.operativeData.time {
        case .day?:
            self.confirmOtpDeferredTransfer(for: presenter, completion: completion)
        case .periodic?:
            self.confirmOtpPeriodicTransfer(for: presenter, completion: completion)
        case .now, .none:
            completion(true, nil)
        }
    }
    
    private func confirmOtpDeferredTransfer(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        self.confirmOtpTransfer(with: self.dependencies.resolve(firstTypeOf: ConfirmOTPDeferredInternalTransferUseCaseProtocol.self), code: presenter.code, completion: completion)
    }
    
    private func confirmOtpPeriodicTransfer(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        self.confirmOtpTransfer(with: self.dependencies.resolve(for: ConfirmOTPPeriodicInternalTransferUseCase.self), code: presenter.code, completion: completion)
    }
    
    private func confirmOtpTransfer(with useCase: UseCase<ConfirmOTPInternalTransferUseCaseInput, Void, GenericErrorOTPErrorOutput>, code: String, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let otpValidation: OTPValidationEntity = container?.getOptional() else {
            completion(false, nil)
            return
        }
        let input = ConfirmOTPInternalTransferUseCaseInput(originAccount: self.operativeData.selectedAccount, destinationAccount: self.operativeData.destinationAccount, time: self.operativeData.time, otpValidation: otpValidation, code: code, concept: self.operativeData.concept, scheduledTransfer: self.operativeData.scheduledTransfer, amount: self.operativeData.amount)
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: self.dependencies.resolve(for: UseCaseHandler.self),
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { errorResult in
                switch errorResult {
                case .error(let signatureError):
                    completion(false, signatureError)
                default:
                    completion(false, nil)
                }
            }
        )
    }
}

extension InternalTransferOperative: SCACapable {}

extension InternalTransferOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
        self.steps.append(SignatureStep(dependenciesResolver: dependencies))
    }
}

extension InternalTransferOperative: SCAOTPCapable {
    func prepareForOTP(_ otp: OTPValidationEntity?) {
        if let otp = otp {
            self.container?.save(otp)
        }
        self.steps.append(OTPStep(dependenciesResolver: dependencies))
    }
}

extension InternalTransferOperative: OperativeOpinatorCapable {
    
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-traspasos-exito")
    }
}

extension InternalTransferOperative: OperativeGiveUpOpinatorCapable {
    
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-traspasos-abandono")
    }
}

extension InternalTransferOperative: OperativeBackToStepCapable {
    
    func stepAdded(_ step: OperativeStep) {
        switch step {
        case is InternalTransferAccountSelectorStep:
            self.isSelectedAccountStepVisible = true
        default:
            break
        }
    }
}

extension InternalTransferOperative: OperativeFinishingCoordinatorCapable {}

// MARK: - Tracker

extension InternalTransferOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
    
    var extraParametersForTracker: [String: String] {
        return [
            TrackerDimension.scheduledTransferType.key: self.operativeData.time?.trackerDescription ?? ""
        ]
    }
}

extension InternalTransferOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        return InternalTransferSignaturePage().page
    }
}

extension InternalTransferOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        return InternalTransferOTPPage().page
    }
}

// MARK: - Steps

// MARK: - Account Selector

final class InternalTransferAccountSelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: InternalTransferAccountSelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Destination account selector

private final class InternalTransferDestinationAccountSelectorStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: InternalTransferDestinationAccountSelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Amount And Type Selector

private final class InternalTransferAmountAndTypeSelectorStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: InternalTransferAmountAndTypeSelectorViewProtocol.self)
    }
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Confirmation

private final class InternalTransferConfirmationStep: OperativeStep {
    
    let dependenciesResolver: DependenciesResolver
    
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: InternalTransferConfirmationViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

// MARK: - Summary

private final class TransferSummaryStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension InternalTransferOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "toolbar_title_transfer"
    }
}

extension InternalTransferOperative: OperativeOTPNavigationCapable {
    var otpNavigationTitle: String {
        return "toolbar_title_transfer"
    }
}

extension InternalTransferOperative: OperativeFaqsCapable {
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        guard let container = self.container else { return nil }
        let parameter: InternalTransferOperativeData = container.get()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? nil
        return faqModel
    }
}

extension InternalTransferOperative: OperativeDialogFinishCapable {}
