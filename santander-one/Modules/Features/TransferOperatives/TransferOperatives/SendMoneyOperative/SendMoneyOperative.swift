//
//  SendMoneyOperative.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib
import UI
import CoreDomain
import OneAuthorizationProcessor

final class SendMoneyOperative: Operative {
    enum OAPOperationType: String {
        case sendMoney = "SendMoney"
    }
    enum FinishingOption {
        case sendMoney
        case globalPosition
    }
    let dependencies: DependenciesInjector & DependenciesResolver
    weak var container: OperativeContainerProtocol?
    lazy var finishingCoordinator: OperativeFinishingCoordinator = {
        self.dependencies.resolve(for: SendMoneyOperativeFinishingCoordinatorProtocol.self)
    }()
    var steps: [OperativeStep] = []
    var progressBarType: ProgressBarType = .oneContinuous
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private lazy var sendMoneyModifierProtocol: SendMoneyModifierProtocol? = {
        self.dependencies.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }()
    private var shouldShowSelectAccount: Bool = false
    private lazy var deepLinkManager = self.dependencies.resolve(for: DeepLinkManagerProtocol.self)
    
    private var sca: SCA? {
        let scaRepresentable: SCARepresentable? = self.container?.getOptional()
        return scaRepresentable?.mapSCA()
    }
    
    init(dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.setupDependencies()
    }
}

private extension SendMoneyOperative {
    func buildSteps() {
        if self.operativeData.selectedAccount == nil || self.shouldShowSelectAccount {
            self.steps.append(SendMoneyAccountSelectorStep(dependenciesResolver: self.dependencies))
            self.shouldShowSelectAccount = true
        }
        self.steps.append(SendMoneyDestinationStep(dependenciesResolver: self.dependencies))
        if let amountStep = self.sendMoneyModifierProtocol?.getAmountStep(operativeData: self.operativeData, dependencies: self.dependencies) {
            self.steps.append(amountStep)
        }
        if let sendMoneyTransferTypeStep = self.sendMoneyModifierProtocol?.getTransferTypeStep(dependencies: self.dependencies) {
            self.steps.append(sendMoneyTransferTypeStep)
        }
        if self.operativeData.type != .noSepa {
            self.steps.append(SendMoneyConfirmationStep(dependenciesResolver: self.dependencies))
        } else {
            self.steps.append(SendMoneyConfirmationNoSepaStep(dependenciesResolver: self.dependencies) )
        }
        sca?.prepareForVisitor(self)
        if let scaSteps = self.sendMoneyModifierProtocol?.getScaSteps(dependencies: self.dependencies) {
            self.steps.append(contentsOf: scaSteps)
        }
        if self.operativeData.type != .noSepa {
            self.steps.append(SendMoneySummaryNationalSepaStep(dependenciesResolver: self.dependencies))
        } else {
            self.steps.append(SendMoneySummaryNoSepaStep(dependenciesResolver: self.dependencies))
        }
        if self.operativeData.didSwapCurrentStep {
            self.container?.updateLastViewController()
            self.operativeData.didSwapCurrentStep = false
            self.container?.save(self.operativeData)
        }
    }
    
    func setupDependencies() {
        self.setupPreSetup()
        self.setupAccountSelector()
        self.setupDestination()
        self.setupConfirmation()
        self.setupAmount()
        self.setupAmountNoSepa()
        self.setupOTP()
        self.setupElectronicSignature()
        self.setupSummary()
        self.setupDefaultUseCases()
    }
    
    func setupDefaultUseCases() {
        self.dependencies.register(for: ValidateGenericSendMoneyUseCaseProtocol.self) { dependenciesResolver in
            return ValidateGenericSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: ValidateScheduledSendMoneyUseCaseProtocol.self) { dependenciesResolver in
            return ValidateScheduledSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: TransferTypeValidationUseCaseProtocol.self) { dependenciesResolver in
            return TransferTypeValidationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyGetFeesUseCaseProtocol.self) { _ in
            return SendMoneyGetFeesDefaultUseCase()
        }
        self.dependencies.register(for: ValidateOTPNoSepaUseCaseProtocol.self) { _ in
            return ValidateOTPNoSepaDefaultUseCase()
        }
        self.dependencies.register(for: ConfirmSendMoneyNoSepaUseCaseProtocol.self) { _ in
            return ConfirmNoSepaSendMoneyDefaultUseCase()
        }
    }
    
    func setupPreSetup() {
        self.dependencies.register(for: PreSetupSendMoneyUseCaseProtocol.self) { dependenciesResolver in
            return PreSetupSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyUseCaseProviderProtocol.self) { dependenciesResolver in
            return SendMoneyUseCaseProvider(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: PredefinedSCASendMoneyUseCaseProtocol.self) { dependenciesResolver in
            return PredefinedSCASendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func setupAccountSelector() {
        self.dependencies.register(for: SendMoneyAccountSelectorPresenterProtocol.self) { dependenciesResolver in
            return SendMoneyAccountSelectorPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyAccountSelectorView.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SendMoneyAccountSelectorPresenterProtocol.self)
            let viewController = SendMoneyAccountSelectorViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupDestination() {
        self.dependencies.register(for: SendMoneyDestinationAccountPresenterProtocol.self) { dependenciesResolver in
            return SendMoneyDestinationAccountPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyDestinationAccountView.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SendMoneyDestinationAccountPresenterProtocol.self)
            let viewController = SendMoneyDestinationAccountViewController(presenter: presenter, dependenciesResolver: dependenciesResolver)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetAllTypesOfTransfersUseCaseProtocol.self) { dependenciesResolver in
            return GetAllTypesOfTransfersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: GetRecentTransferDetailUseCase.self) { dependenciesResolver in
            return GetRecentTransferDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: IbanValidationSendMoneyUseCaseProtocol.self) { resolver in
            return IbanLocalValidationSendMoneyUseCase(dependenciesResolver: resolver)
        }
        self.dependencies.register(for: SendMoneyDestinationUseCaseProtocol.self) { resolver in
            return SendMoneyDestinationDefaultUseCase()
        }
    }
    
    func setupAmount() {
        self.dependencies.register(for: SendMoneyAmountPresenterProtocol.self) { dependenciesResolver in
            return SendMoneyAmountPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyAmountView.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SendMoneyAmountPresenterProtocol.self)
            let viewController = SendMoneyAmountViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: SendMoneyAmountUseCaseProtocol.self) { _ in
            return SendMoneyAmountDefaultUseCase()
        }
    }
    
    func setupAmountNoSepa() {
        self.dependencies.register(for: SendMoneyAmountNoSepaPresenterProtocol.self) { dependenciesResolver in
            return SendMoneyAmountNoSepaPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyAmountNoSepaView.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: SendMoneyAmountNoSepaPresenterProtocol.self)
            let viewController = SendMoneyAmountNoSepaViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: SendMoneyAmountNoSepaUseCaseProtocol.self) { _ in
            return SendMoneyAmountNoSepaDefaultUseCase()
        }
    }
    
    func setupSummary() {
        self.dependencies.register(for: SendMoneySummaryNationalSepaView.self) { dependenciesResolver in
            let presenter = SendMoneySummaryNationalSepaPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = SendMoneySummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: SendMoneySummaryNoSepaView.self) { dependenciesResolver in
            let presenter = SendMoneySummaryNoSepaPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = SendMoneySummaryViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
        
    func setupConfirmation() {
        self.dependencies.register(for: SendMoneyConfirmationNationalSepaView.self) { dependenciesResolver in
            let presenter = SendMoneyConfirmationNationalSepaPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = SendMoneyConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: SendMoneyConfirmationNoSepaView.self) { dependenciesResolver in
            let presenter = SendMoneyConfirmationNoSepaPresenter(dependenciesResolver: dependenciesResolver)
            let viewController = SendMoneyConfirmationViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependencies.register(for: ConfirmGenericSendMoneyUseCaseProtocol.self) { dependenciesResolver in
            ConfirmGenericSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: ConfirmScheduledSendMoneyUseCaseProtocol.self) { dependenciesResolver in
            return ConfirmScheduledSendMoneyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: SendMoneyConfirmationUseCaseProtocol.self) { _ in
            return SendMoneyConfirmationDefaultUseCase()
        }
        self.dependencies.register(for: SendMoneyConfirmationNoSepaUseCaseProtocol.self) { _ in
            return SendMoneyConfirmationNoSepaDefaultUseCase()
        }
    }
    
    func setupOTP() {
        self.dependencies.register(for: OTPPresenterProtocol.self) { dependenciesResolver in
            OTPPresenter(dependencies: dependenciesResolver)
        }
        self.dependencies.register(for: OTPViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: OTPPresenterProtocol.self)
            let viewController = OneOTPViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
    
    func setupElectronicSignature() {
        self.dependencies.register(for: InternalSignaturePresenterProtocol.self) { dependenciesResolver in
            SignaturePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependencies.register(for: InternalSignatureViewProtocol.self) { dependenciesResolver in
            let presenter = dependenciesResolver.resolve(for: InternalSignaturePresenterProtocol.self)
            let viewController = OneElectronicSignatureViewController(presenter: presenter, dependenciesResolver: dependenciesResolver)
            presenter.view = viewController
            return viewController
        }
    }
    
    func checkOnlyAccount(output: PreSetupSendMoneyUseCaseOkOutput) -> Scenario<CheckOnlyAccountUseCaseInput, AccountRepresentable?, StringErrorOutput>? {
        let input = CheckOnlyAccountUseCaseInput(accountVisibles: output.accountVisibles, accountNotVisibles: output.accountNotVisibles)
        let useCase = CheckOnlyOneAccountUseCase()
        return Scenario(useCase: useCase, input: input)
    }
    
    func performNationalOTP(code: String, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let input = getConfirmOTPUseCaseInput(code: code)
        else {
            completion(false, nil)
            return
        }
        let provider = self.dependencies.resolve(for: SendMoneyUseCaseProviderProtocol.self)
        let useCase = provider.getConfirmSendMoneyUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] output in
                guard let self = self else {
                    completion(false, nil)
                    return
                }
                let operativeData = self.operativeData
                operativeData.transferConfirmAccount = output.transferConfirmAccount
                self.container?.save(operativeData)
                guard let checkStatusUseCase = provider.getCheckStatusUseCase(),
                   checkStatusUseCase.isImmediateTransfer(type: self.operativeData.selectedTransferType?.type.serviceString ?? "")
                else {
                    let operativeData = self.operativeData
                    operativeData.summaryState = .success()
                    self.container?.save(operativeData)
                    guard self.operativeData.type == .national,
                       self.operativeData.transferDateType == .now,
                       let loadFundableTypeUseCase = provider.getFundableTypeUseCase()
                    else {
                        completion(true, nil)
                        return
                    }
                    self.performLoadFundableType(loadFundableTypeUseCase) {
                        completion(true, nil)
                    }
                    return
                }
                self.performCheckStatus(checkStatusUseCase, completion: completion)
            }
            .onError { error in
                switch error {
                case .error(let error):
                    completion(false, error)
                default:
                    completion(false, nil)
                }
            }
    }
    
    func performSepaOTP(code: String, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let input = getConfirmOTPUseCaseInput(code: code)
        else {
            completion(false, nil)
            return
        }
        let provider = self.dependencies.resolve(for: SendMoneyUseCaseProviderProtocol.self)
        let useCase = provider.getConfirmSendMoneyUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess { [weak self] output in
                guard let self = self else {
                    completion(false, nil)
                    return
                }
                let operativeData = self.operativeData
                operativeData.transferConfirmAccount = output.transferConfirmAccount
                self.container?.save(operativeData)
                guard let checkStatusUseCase = provider.getCheckStatusUseCase(),
                   checkStatusUseCase.isImmediateTransfer(type: self.operativeData.selectedTransferType?.type.serviceString ?? "")
                else {
                    let operativeData = self.operativeData
                    operativeData.summaryState = .success()
                    self.container?.save(operativeData)
                    completion(true, nil)
                    return
                }
                self.performCheckStatus(checkStatusUseCase, completion: completion)
            }
            .onError { error in
                switch error {
                case .error(let error):
                    completion(false, error)
                default:
                    completion(false, nil)
                }
            }
    }
    
    func getConfirmOTPUseCaseInput(code: String) -> ConfirmOtpSendMoneyUseCaseInput? {
        let otpValidation: OTPValidationEntity? = self.container?.getOptional()
        guard let selectedAccount = self.operativeData.selectedAccount,
              let destinationIBAN = self.operativeData.destinationIBANRepresentable,
              let amount = self.operativeData.amount,
              let subtype = self.operativeData.selectedTransferType?.type,
              let otpValidationEntity = otpValidation
        else {
            return nil
        }
        return ConfirmOtpSendMoneyUseCaseInput(
            otpValidation: otpValidationEntity.otpValidationRepresentable,
            code: code,
            type: self.operativeData.type,
            subType: subtype,
            originAccount: selectedAccount,
            destinationIBAN: destinationIBAN,
            name: self.operativeData.destinationName,
            alias: self.operativeData.destinationAlias,
            isSpanishResident: true,
            saveFavorites: self.operativeData.saveToFavorite,
            beneficiaryMail: self.operativeData.beneficiaryMail,
            amount: amount,
            concept: self.operativeData.description,
            time: self.operativeData.transferFullDateType,
            scheduledTransfer: self.operativeData.scheduledTransfer)
    }
    
    func performCheckStatus(_ useCase: CheckStatusSendMoneyTransferUseCaseProtocol, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let transferConfirmAccount = self.operativeData.transferConfirmAccount else {
            completion(false, nil)
            return
        }
        let input = CheckStatusSendMoneyTransferUseCaseInput(transferConfirmAccount: transferConfirmAccount)
        useCase.setRequestValues(requestValues: input)
        Scenario(useCase: useCase,
                 input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                guard let self = self else {
                    completion(false, nil)
                    return
                }
                let operativeData = self.operativeData
                operativeData.summaryState = output.status
                self.container?.save(operativeData)
                completion(true, nil)
            }
            .onError { _ in
                completion(false, nil)
            }
    }
    
    func performLoadFundableType(_ useCase: LoadFundableTypeUseCaseProtocol, completion: @escaping () -> Void) {
        let input = LoadFundableTypeUseCaseInput(amount: self.operativeData.amount)
        useCase.setRequestValues(requestValues: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { output in
                let fundableType = output.fundableType ?? .notAllowed
                let operativeData = self.operativeData
                operativeData.easyPayFundableType = fundableType
                self.container?.save(operativeData)
                completion()
            }
            .onError { _ in
                completion()
            }
    }
    
    func performNoSepaOTP(code: String, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let provider = self.dependencies.resolve(for: SendMoneyUseCaseProviderProtocol.self)
        let useCase = provider.getConfirmSendMoneyNoSepaUseCase()
        let otpValidation: OTPValidationEntity? = self.container?.getOptional()
        guard let otpValidation = otpValidation else {
            return completion(false, nil)
        }
        Scenario(useCase: useCase, input: ConfirmNoSepaSendMoneyUseCaseInput(operativeData: self.operativeData, otpCode: code, otpValidation: otpValidation.otpValidationRepresentable))
            .execute(on: self.dependencies.resolve())
            .onSuccess { output in
                completion(true, nil)
            }
            .onError { error in
                switch error {
                case .error(let error):
                    completion(false, error)
                default:
                    completion(false, nil)
                }
            }
    }
}

// MARK: - Steps

final class SendMoneyAccountSelectorStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyAccountSelectorView.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var shouldCountForProgress: Bool {
        return false
    }
    
    var shouldCountForContinueButton: Bool {
        return false
    }
}

final class SendMoneyDestinationStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyDestinationAccountView.self)
    }
}

public final class SendMoneyAmountStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    public var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    public var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyAmountView.self)
    }
    public var floatingButtonTitleKey: String {
        return "sendMoney_button_amountAndDate"
    }
}

final class SendMoneyAmountNoSepaStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyAmountNoSepaView.self)
    }
    var floatingButtonTitleKey: String {
        return "sendMoney_button_amountAndDate"
    }
}

private final class SendMoneyConfirmationStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyConfirmationNationalSepaView.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var floatingButtonTitleKey: String {
        return "sendMoney_button_confirmation"
    }
}

private final class SendMoneyConfirmationNoSepaStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: true, showsCancel: true)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneyConfirmationNoSepaView.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var floatingButtonTitleKey: String {
        return "sendMoney_button_confirmation"
    }
}

private final class SendMoneySummaryNationalSepaStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: false, showsCancel: false)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneySummaryNationalSepaView.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var shouldCountForProgress: Bool {
        return false
    }
    
    var shouldCountForContinueButton: Bool {
        return false
    }
}

private final class SendMoneySummaryNoSepaStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: false, showsCancel: false)
    }
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: SendMoneySummaryNoSepaView.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    var shouldCountForProgress: Bool {
        return false
    }
    
    var shouldCountForContinueButton: Bool {
        return false
    }
}


extension SendMoneyOperative: OperativePresetupCapable {
    func performPreSetup(success: @escaping () -> Void, failed: @escaping (OperativeSetupError) -> Void) {
        guard let container = self.container else { return failed(OperativeSetupError(title: nil, message: nil))}
        let presetupUseCase = self.dependencies.resolve(firstTypeOf: PreSetupSendMoneyUseCaseProtocol.self)
        Scenario(useCase: presetupUseCase)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                self?.updateOperativeData(result)
            }.then(scenario: checkOnlyAccount)
            .onSuccess { [weak self] result in
                self?.saveOperativeDataSelected(result)
                success()
            }
            .onError { result in
                failed(OperativeSetupError(title: nil, message: result.getErrorDesc()))
            }
    }
}

// MARK: - OperativePresetupCapable private funcs
private extension SendMoneyOperative {
    
    func updateOperativeData(_ result: PreSetupSendMoneyUseCaseOkOutput) {
        guard let container = self.container else { return }
        let operativeData: SendMoneyOperativeData = container.get()
        let countryCode = self.dependencies.resolve(for: LocalAppConfig.self).countryCode
        let bankingUtils: BankingUtilsProtocol = self.dependenciesResolver.resolve()
        let country = result.sepaList.allCountriesRepresentable.first(where: { $0.code == countryCode})
        bankingUtils.setCountryCode(countryCode, isAlphanumeric: country?.isAlphanumeric, isSepaCountry: country?.sepa)
        operativeData.update(accounts: result.accountVisibles, accountNotVisibles: result.accountNotVisibles, sepaList: result.sepaList, faqs: result.faqs, countryCode: countryCode)
        self.container?.save(operativeData)
    }
    
    func saveOperativeDataSelected(_ result: AccountRepresentable?) {
        guard operativeData.selectedAccount == nil else {
            buildSteps()
            return
        }
        self.operativeData.selectedAccount = result != nil ? result : self.operativeData.mainAccount
        self.buildSteps()
    }
}

extension SendMoneyOperative: OperativeBackToStepCapable {
    func stepAdded(_ step: OperativeStep) {
        if step is SendMoneyAccountSelectorStep {
            self.shouldShowSelectAccount = true
        }
    }
}

extension SendMoneyOperative: OperativeFinishingCoordinatorCapable {}

extension SendMoneyOperative: OperativeRebuildStepsCapable {
    func rebuildSteps() {
        self.buildSteps()
    }
}

extension SendMoneyOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-transferencias-exito")
    }
}

extension SendMoneyOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        guard let sendMoneyModifierProtocol = self.sendMoneyModifierProtocol else {
            return GiveUpOpinatorInfoEntity(path: "")
        }
        return GiveUpOpinatorInfoEntity(path: (self.operativeData.selectedPayee != nil) ? sendMoneyModifierProtocol.favoriteGiveUpOpinator : sendMoneyModifierProtocol.giveUpOpinator)
    }
}

extension SendMoneyOperative: SCACapable {}

extension SendMoneyOperative: SCAOAPCapable {
    func prepareForOAP(_ authorizationId: String?) {
        guard let authorizationId = authorizationId else { return }
        dependencies.register(for: OneAuthorizationProcessorDelegate.self) { _ in
            return self
        }
        goToAuthorizationProcessor(authorizationId: authorizationId, scope: OAPOperationType.sendMoney.rawValue)
    }
}

extension SendMoneyOperative: OneAuthorizationProcessorLauncher {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
}

extension SendMoneyOperative: OneAuthorizationProcessorDelegate {
    func authorizationDidFinishSuccessfully() {
        guard let current = container?.currentStep() else { return }
        guard let useCase = self.dependenciesResolver.resolve(forOptionalType: SendMoneyConfirmationStepUseCaseProtocol.self) else {
            self.container?.stepFinished(presenter: current)
            return
        }
        guard let selectedAccount = self.operativeData.selectedAccount,
              let destinationIBANRepresentable = self.operativeData.destinationIBANRepresentable,
              let amount = self.operativeData.amount
        else { return }
        let input = SendMoneyConfirmationStepUseCaseInput(originAccount: selectedAccount,
                                                          destinationIBAN: destinationIBANRepresentable,
                                                          name: self.operativeData.destinationName,
                                                          alias: self.operativeData.destinationAlias ?? self.operativeData.selectedAccount?.alias,
                                                          amount: amount,
                                                          concept: self.operativeData.description,
                                                          type: self.operativeData.type,
                                                          subType: operativeData.selectedTransferType?.type,
                                                          scheduledTransfer: nil,
                                                          transactionType: self.operativeData.specialPricesOutput?.transactionTypeString,
                                                          payeeSelected: self.operativeData.selectedPayee,
                                                          time: self.operativeData.transferFullDateType)
        Scenario(useCase: useCase.setRequestValues(requestValues: input), input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { result in
                self.operativeData.summaryState = result
                self.container?.stepFinished(presenter: current)
            }
            .onError { _ in
                self.container?.showGenericError()
            }
    }
    
    func authorizationDidFinishWithError(_ error: Error) {
        self.container?.showGenericError()
    }
}

extension SendMoneyOperative: ShareOperativeCapable {

    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void) {
        let useCase = self.dependencies.resolve(for: GetGlobalPositionUseCaseAlias.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependencies.resolve())
            .onSuccess { response in
                let shareView = self.loadShareView(username: response.globalPosition.fullName)
                completion(.success((shareView, shareView.view)))
            }
            .onError { _ in
                completion(.failure(.generalError))
            }
    }

    private func loadShareView(username: String?) -> SendMoneyShareView {
        let shareView = SendMoneyShareView(dependenciesResolver: self.dependencies,
                                           summaryType: self.operativeData.type == .noSepa ? .noSepa : .nationalSepa ,
                                           operativeData: self.operativeData,
                                           fullName: username)
        shareView.modalPresentationStyle = .fullScreen
        shareView.loadViewIfNeeded()
        return shareView
    }
}

extension SendMoneyOperative: SCAOTPCapable {
    func prepareForOTP(_ otp: OTPValidationEntity?) {
        if let otp = otp {
            self.container?.save(otp)
        }
    }
}
extension SendMoneyOperative: OperativeOTPCapable {
    func performOTP(for presenter: OTPPresentationDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let code: String
        if let validation: OTPValidationEntity = self.container?.getOptional(), validation.isOTPExcepted {
            code = ""
        } else {
            code = presenter.code
        }
        switch operativeData.type {
        case .national: self.performNationalOTP(code: code, completion: completion)
        case .sepa: self.performSepaOTP(code: code, completion: completion)
        case .noSepa: self.performNoSepaOTP(code: code, completion: completion)
        }
    }
}

extension SendMoneyOperative: OperativeFaqsCapable {
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        self.operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.identifier, title: $0.question, description: $0.answer)
        } ?? nil
    }
}

extension SendMoneyOperative: OperativeSignatureCapable {
    
    func performSignature(for presenter: SignaturePresentationDelegate, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        switch self.operativeData.type {
        case .national: self.performNationalSignature(completion: completion)
        case .sepa: self.performSepaSignature(completion: completion)
        case .noSepa: self.performNoSepaSignature(completion: completion)
        }
    }
}

// MARK: - OperativeSignatureCapable private funcs
private extension SendMoneyOperative {
    
    func performNationalSignature(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let useCaseProvider: SendMoneyUseCaseProviderProtocol = self.dependenciesResolver.resolve()
        guard let input = getConfirmationInput() else {
            return completion(false, nil)
        }
        let useCase = useCaseProvider.getValidateOtpUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseScheduler.self))
            .onSuccess { [weak self] response in
                if let otp = response.otp {
                    self?.container?.save(OTPValidationEntity(otp))
                }
                return completion(true, nil)
            }
            .onError { error in
                guard case UseCaseError.error(let error) = error else {
                    return completion(false, nil)
                }
                return completion(false, error as? GenericErrorSignatureErrorOutput)
            }
    }
    
    func performSepaSignature(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let useCaseProvider: SendMoneyUseCaseProviderProtocol = self.dependenciesResolver.resolve()
        guard let input = getConfirmationInput() else {
            return completion(false, nil)
        }
        let useCase = useCaseProvider.getValidateOtpUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseScheduler.self))
            .onSuccess { [weak self] response in
                if let otp = response.otp {
                    self?.container?.save(OTPValidationEntity(otp))
                }
                return completion(true, nil)
            }
            .onError { error in
                guard case UseCaseError.error(let error) = error else {
                    return completion(false, nil)
                }
                return completion(false, error as? GenericErrorSignatureErrorOutput)
            }
    }
    
    func performNoSepaSignature(completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let signature: SignatureRepresentable = self.container?.get() else {
            completion(false, nil)
            return
        }
        let useCaseProvider: SendMoneyUseCaseProviderProtocol = self.dependenciesResolver.resolve()
        let useCase = useCaseProvider.getValidateOtpNoSepaUseCase()
        Scenario(useCase: useCase, input: ValidateOTPNoSepaInput(operativeData: self.operativeData, signatureRepresentable: signature))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] output in
                if let otp = output.otp {
                    self?.container?.save(OTPValidationEntity(otp))
                }
                completion(true, nil)
            }
            .onError { error in
                guard case UseCaseError.error(let error) = error else {
                    return completion(false, nil)
                }
                if let error = error as? GenericErrorSignatureErrorOutput, case .revoked = error.signatureResult {
                    self.container?.save(SendMoneyOperative.FinishingOption.globalPosition)
                }
                return completion(false, error as? GenericErrorSignatureErrorOutput)
            }
    }
    
    func getConfirmationInput() -> ConfirmNationalGenericSendMoneyInput? {
        guard let signature: SignatureRepresentable = self.container?.get(),
              let originAccount = self.operativeData.selectedAccount,
              let amount = self.operativeData.amount,
              let beneficiary = self.operativeData.destinationName,
              let iban = self.operativeData.destinationIBANRepresentable,
              let time = self.operativeData.transferDateType else {
                  return nil
              }
        return ConfirmNationalGenericSendMoneyInput(signature: signature,
                                                    type: operativeData.type,
                                                    originAccount: originAccount,
                                                    amount: amount,
                                                    beneficiary: beneficiary,
                                                    iban: iban,
                                                    saveAsUsual: self.operativeData.saveToFavorite,
                                                    concept: self.operativeData.description,
                                                    saveAsUsualAlias: self.operativeData.destinationAlias,
                                                    beneficiaryMail: self.operativeData.beneficiaryMail,
                                                    time: time,
                                                    dataToken: self.operativeData.scheduledTransfer?.dataMagicPhrase)
    }
}

extension SendMoneyOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
    }
}

// MARK: - OperativeGlobalPositionReloaderCapable
extension SendMoneyOperative: OperativeGlobalPositionReloaderCapable {}

extension SendMoneyOperative: OperativeTrackerCapable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve()
    }
    
    var extraParametersForTracker: [String : String] {
        let key = TransferOperativesConstant.SendMoneyTrackerConstants.parameterKey
        var parameters = [key: ""]
        if self.operativeData.type == .noSepa {
            parameters[key] = TransferOperativesConstant.SendMoneyTrackerConstants.valueNoSepa
        } else {
            parameters[key] = TransferOperativesConstant.SendMoneyTrackerConstants.valueSepa
        }
        return parameters
    }
}

extension SendMoneyOperative: OperativeSignatureTrackerCapable {
    var screenIdSignature: String {
        switch self.operativeData.type {
        case .national:
            return TransferOperativesConstant.SendMoneyTrackerConstants.SignaturePages.domestic
        case .sepa:
            return TransferOperativesConstant.SendMoneyTrackerConstants.SignaturePages.sepa
        case .noSepa:
            return TransferOperativesConstant.SendMoneyTrackerConstants.SignaturePages.noSepa
        }
    }
}

extension SendMoneyOperative: OperativeOTPTrackerCapable {
    var screenIdOtp: String {
        switch self.operativeData.type {
        case .national:
            return TransferOperativesConstant.SendMoneyTrackerConstants.OTPPages.domestic
        case .sepa:
            return TransferOperativesConstant.SendMoneyTrackerConstants.OTPPages.sepa
        case .noSepa:
            return TransferOperativesConstant.SendMoneyTrackerConstants.OTPPages.noSepa
        }
    }
}

extension SendMoneyOperative: OperativeProgressBarCapable {
    var customStepsNumber: Int {
        return self.sendMoneyModifierProtocol?.maxProgressBarSteps ?? .zero
    }
    
    var stepsCorrectionFactor: Int {
        return self.shouldShowSelectAccount ? .zero : 1
    }
}
