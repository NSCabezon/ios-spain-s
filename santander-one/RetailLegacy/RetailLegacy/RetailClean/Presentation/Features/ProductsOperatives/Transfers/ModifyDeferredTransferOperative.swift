import CoreDomain
import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ModifyDeferredTransferOperative: Operative {
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var opinatorPage: OpinatorPage? {
        return .modifyScheduledTransfer
    }
    var giveUpOpinatorPage: OpinatorPage? {
        return .modifyScheduledTransfer
    }
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let parameter: ModifyDeferredTransferOperativeData = container.provideParameter()
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupModifyDeferredTransferUseCase(input: SetupModifyDeferredTransferUseCaseInput(scheduledTransferDetail: parameter.scheduledTransferDetail, scheduledTransfer: parameter.transferScheduled)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                parameter.country = result.country
                parameter.currency = result.currency
                container.saveParameter(parameter: result.operativeConfig)
                container.saveParameter(parameter: parameter)
                success()
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else { return }
        
        let parameter: ModifyDeferredTransferOperativeData = container.provideParameter()
        guard let modifyDeferredTransfer = parameter.modifyDeferredTransfer,
            let beneficiaryIBANDTO = parameter.modifiedData?.iban.ibanDTO,
            let nextExecutionDate = parameter.modifiedData?.date,
            let transferAmount = parameter.modifiedData?.amount.amountDTO
            else { return }
        
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
        modifyDeferredTransfer.signature = signatureFilled.signature
        
        let modifyScheduledTransferInput: ModifyScheduledTransferInput =
            ModifyScheduledTransferInput(beneficiaryIBAN: beneficiaryIBANDTO,
                                         nextExecutionDate: DateModel(date: nextExecutionDate),
                                         amount: transferAmount,
                                         concept: parameter.modifiedData?.concept ?? "",
                                         beneficiary: parameter.scheduledTransferDetail.beneficiaryName ?? "",
                                         transferOperationType: (parameter.country?.sepa ?? true) ? TransferOperationType.NATIONAL_SEPA : TransferOperationType.INTERNATIONAL_SEPA,
                                         startDateValidity: nil,
                                         endDateValidity: nil,
                                         periodicalType: nil,
                                         scheduledDayType: ScheduledDayDTO.none)
        parameter.modifyScheduledTransferInput = modifyScheduledTransferInput

        let input = ValidateDeferredTransferUseCaseInput(account: parameter.account, modifyScheduledTransferInput: modifyScheduledTransferInput, modifyDeferredTransfer: modifyDeferredTransfer, transferScheduledDetail: parameter.scheduledTransferDetail)
    
        let useCase = dependencies.useCaseProvider.getValidateDeferredTransferUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { result in
            container.saveParameter(parameter: result.otp)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        guard let container = container else { return }
        
        let parameter: ModifyDeferredTransferOperativeData = container.provideParameter()
        guard let modifyDeferredTransfer = parameter.modifyDeferredTransfer,
            let modifyScheduledTransferInput = parameter.modifyScheduledTransferInput
            else { return }
        
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        let otpCode = otpFilled.value
        let validation: OTPValidation
        if let otpFilledValidation = otpFilled.validation {
            validation = otpFilledValidation
        } else {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
        
        let input = ConfirmDeferredTransferUseCaseInput(account: parameter.account, modifyScheduledTransferInput: modifyScheduledTransferInput, modifyDeferredTransfer: modifyDeferredTransfer, transferScheduled: parameter.transferScheduled, transferScheduledDetail: parameter.scheduledTransferDetail, otp: validation, code: otpCode)
        
        let useCase = dependencies.useCaseProvider.getConfirmDeferredTransferUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter.errorOtpHandler, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_standardProgrammedOneaPay")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_subtitle_paidOnePay")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let builder = ModifyDeferredTransferOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
        builder.addType()
            .addOriginAccount()
            .addDestinationAccount()
            .addBeneficiary()
            .addAmount()
            .addConcept()
            .addPeriodicity()
            .addEmissionDate()
            .addComission()
        return builder.build()
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    private func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as ModifyDeferredTransferStep)
        add(step: factory.createStep() as ModifyDeferredTransferConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.ModifyScheduledTransferSignature().page
    }
    
    var screenIdOtp: String? {
        return TrackerPagePrivate.ModifyScheduledTransferOTP().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ModifyScheduledTransferSummary().page
    }
    
    private var typeModifyTransferParameters: [String: String]? {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let typePeriodicTransfer = parameter.transferScheduled.periodicTrackerDescription
        return [TrackerDimensions.scheduledTransferType: typePeriodicTransfer]
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeModifyTransferParameters
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return typeModifyTransferParameters
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return typeModifyTransferParameters
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return typeModifyTransferParameters
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeModifyTransferParameters
    }
}

struct ModifyDeferredTransferStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.modifyDeferredTransferPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ModifyDeferredTransferConfirmationStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.modifyDeferredTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder
private class ModifyDeferredTransferOperativeSummaryItemDataBuilder {
    
    let parameter: ModifyDeferredTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: ModifyDeferredTransferOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addType() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_type"), value: dependencies.stringLoader.getString("summary_label_standardProgrammed").text))
        return self
    }
    
    @discardableResult
    func addOriginAccount() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: parameter.account.getAliasAndInfo()))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        let accountText: String = parameter.modifiedData?.iban.description ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: "\(parameter.scheduledTransferDetail.beneficiaryName ?? "")"))
        return self
    }
    
    @discardableResult
    func addAmount() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: parameter.modifiedData?.amount.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addConcept() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        let concept: String
        if let transferConcept = parameter.modifiedData?.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept))
        return self
    }
    
    @discardableResult
    func addPeriodicity() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: dependencies.stringLoader.getString("summary_label_delayed").text))
        return self
    }
    
    @discardableResult
    func addEmissionDate() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        guard let date = parameter.modifiedData?.date else { return self }
        let emissionDate = dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_issuanceDate"), value: emissionDate ?? ""))
        return self
    }
    
    @discardableResult
    func addComission() -> ModifyDeferredTransferOperativeSummaryItemDataBuilder {
        // Pendiente de la decisión del banco, por ahora se pasa cero euros
        let zeroAmount: String = Amount.zero().getFormattedAmountUI(2)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_commission"), value: zeroAmount))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
