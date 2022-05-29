//

import Foundation
import CoreFoundationLib

class ModifyPeriodicTransferOperative: Operative {
    
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
        let parameter: ModifyPeriodicTransferOperativeData = container.provideParameter()
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupModifyPeriodicTransferUseCase(input: SetupModifyPeriodicTransferUseCaseInput(scheduledTransferDetail: parameter.scheduledTransferDetail, scheduledTransfer: parameter.transferScheduled)),
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
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let modifyPeriodicTransfer = parameter.modifyPeriodicTransfer, let modifiedData = parameter.modifiedData, let country = parameter.country else { return completion(false, nil) }
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        modifyPeriodicTransfer.signature = signatureFilled.signature
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getValidatePeriodicTransferUseCase(input: ValidatePeriodicTransferUseCaseInput(account: parameter.account, scheduledTransfer: parameter.transferScheduled, scheduledTransferDetail: parameter.scheduledTransferDetail, modifyPeriodicTransfer: modifyPeriodicTransfer, modifiedData: modifiedData, country: country)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { [weak self] result in
                self?.container?.saveParameter(parameter: result.otp)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let modifyPeriodicTransfer = parameter.modifyPeriodicTransfer, let modifiedData = parameter.modifiedData, let country = parameter.country else { return completion(false, nil) }
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
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmPeriodicTransferUseCase(input: ConfirmPeriodicTransferUseCaseInput(account: parameter.account, scheduledTransfer: parameter.transferScheduled, scheduledTransferDetail: parameter.scheduledTransferDetail, modifyPeriodicTransfer: modifyPeriodicTransfer, modifiedData: modifiedData, otpValidation: validation, code: otpCode ?? "", country: country)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            }
        )
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_standardProgrammedOneaPay")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_subtitle_paidOnePay")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let builder = ModifyPeriodicTransferOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
        builder.addType()
            .addOriginAccount()
            .addDestinationAccount()
            .addBeneficiary()
            .addAmount()
            .addConcept()
            .addPeriodicity()
            .addStartAndEndDate()
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
        add(step: factory.createStep() as ModifyPeriodicTransferStep)
        add(step: factory.createStep() as ModifyPeriodicTransferConfirmationStep)
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
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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

struct ModifyPeriodicTransferStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.modifyPeriodicTransferPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ModifyPeriodicTransferConfirmationStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.modifyPeriodicTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder

private class ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
    
    let parameter: ModifyPeriodicTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: ModifyPeriodicTransferOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addType() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_type"), value: dependencies.stringLoader.getString("summary_label_standardProgrammed").text))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        let accountText: String = parameter.modifiedData?.iban.formatted ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addOriginAccount() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: parameter.account.getAliasAndInfo()))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: "\(parameter.scheduledTransferDetail.beneficiaryName ?? "")"))
        return self
    }
    
    @discardableResult
    func addAmount() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: parameter.modifiedData?.amount.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addConcept() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
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
    func addPeriodicity() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        let periodicity: String
        switch parameter.modifiedData?.periodicity {
        case .monthly?: periodicity = dependencies.stringLoader.getString("summary_label_monthly").text
        case .quarterly?: periodicity = dependencies.stringLoader.getString("summary_label_quarterly").text
        case .biannual?: periodicity = dependencies.stringLoader.getString("summary_label_sixMonthly").text
        default: periodicity = ""
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: periodicity))
        return self
    }
    
    @discardableResult
    func addStartAndEndDate() -> ModifyPeriodicTransferOperativeSummaryItemDataBuilder {
        guard let startDate = parameter.modifiedData?.startDate, let endDate = parameter.modifiedData?.endDate else { return self }
        let issueDate = dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_startDate"), value: issueDate ?? ""))
        let endDateValue: String
        switch endDate {
        case .never:
            endDateValue = dependencies.stringLoader.getString("detailsOnePay_label_indefinite").text
        case .date(let endDate):
            endDateValue = dependencies.timeManager.toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_endDate"), value: endDateValue))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
