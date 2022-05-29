//

import Foundation
import CoreFoundationLib

class InternalTransfer: OperativeParameter {
    var originAccount: Account?
    var destinationAccount: Account?
    var amount: Amount?
    var concept: String?
    var signature: Signature?
}

/// Defines an internal transfer operative
/// It needs as operative parameter, at least, the following parameters:
/// - InternalTransferOperativeData(accounts: [Account], account: Account?)
class InternalTransferOperative: Operative {
    
    let dependencies: PresentationComponent

    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .internalTransfer
    }
    
    var opinatorPage: OpinatorPage? {
        let parameter: InternalTransferOperativeData = containerParameter()
        switch parameter.time {
        case .now?:
            return .internalTransfer
        case .day?:
            return .deferredInternalTransfer
        case .periodic?:
            return .periodicInternalTransfer
        case .none:
            return .internalTransfer
        }
    }
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    var pdfTitle: String? {
        return "toolbar_title_detailTransfer"
    }
    
    var pdfContent: String? {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let originAccount = parameter.productSelected, let destinationAccount = parameter.internalTransfer?.destinationAccount, let time = parameter.time else { return nil }
        let date: Date?
        switch parameter.time {
        case .now?:
            date = Date()
        case .day(let day)?:
            date = day
        case .periodic(let startDate, _, _, _)?:
            date = startDate
        case .none:
            date = nil
        }
        let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        builder.addHeader(title: "pdf_title_summaryTransfer", office: nil, date: date)
        builder.addAccounts(originAccount: originAccount, destinationAccount: destinationAccount)
        builder.addTransferInfo([
           (key: "summary_item_amount", value: parameter.internalTransfer?.amount),
           (key: "summary_item_concept", value: parameter.internalTransfer?.concept.map({ $0.isEmpty ? dependencies.stringLoader.getString("onePay_label_notConcept").text : $0 })),
           (key: "summary_item_periodicity", value: time.isPeriodic() ? parameter.time.map(periodicity) : nil),
           (key: "summary_item_transactionDate", value: !time.isPeriodic() ? dependencies.timeManager.toString(date: parameter.transferAccount?.issueDate, outputFormat: .dd_MMM_yyyy) : nil),
           (key: "summary_item_startDate", value: time.isPeriodic() ? dependencies.timeManager.toString(date: parameter.transferAccount?.issueDate, outputFormat: .dd_MMM_yyyy) : nil),
           (key: "summary_item_endDate", value: time.isPeriodic() ? endDate(time) : nil)
        ])
        builder.addExpenses([
            (key: "summary_item_commission", value: parameter.transferAccount?.bankChargeAmount),
            (key: "summary_item_mailExpenses", value: parameter.transferAccount?.expensesAmount),
            (key: "summary_item_amountToDebt", value: parameter.transferAccount?.netAmount)
        ])
        return builder.build()
    }
    
     func rebuildSteps() {
        let parameter: InternalTransferOperativeData = containerParameter()
        switch parameter.time {
        case .now?:
            buildSteps()
        case .day?:
            buildStepsForDeferred()
        case .periodic?:
            buildStepsForPeriodic()
        default:
            break
        }
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupLocalTransfersUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: InternalTransferOperativeData = container.provideParameter()
                operativeData.list = result.accounts
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { _ in
                completion(false, (title: nil, message: "deeplink_alert_errorTransferAccounts"))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupLocalTransfersUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                container.saveParameter(parameter: result.operativeConfig)
                success()
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let internalTransfer: InternalTransfer = parameter.internalTransfer, let time = parameter.time else {
            completion(false, nil)
            return
        }
        if time != .now, parameter.scheduledTransfer == nil {
            completion(false, nil)
            return
        }
        guard
            let originAccount = internalTransfer.originAccount,
            let destinationAccount = internalTransfer.destinationAccount,
            let amount = internalTransfer.amount
        else {
            completion(false, nil)
            return
        }
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let confirmData = ConfirmLocalTransferUseCaseInput(
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: internalTransfer.concept ?? "",
            signature: signatureFilled.signature,
            transferTime: time,
            scheduledTransfer: parameter.scheduledTransfer
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmLocalTransferUseCase(input: confirmData),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { [weak self] response in
                switch time {
                case .now:
                    completion(true, nil)
                case .day, .periodic:
                    if let otp = response.otp {
                        self?.container?.saveParameter(parameter: otp)
                        completion(true, nil)
                    }
                    completion(false, nil)
                }
            },
            onError: { error in
                completion(false, error)
            }
        )
    }
    
    func performOTP(for presenter: GenericOtpDelegate, completion: @escaping (Bool, GenericErrorOTPErrorOutput?) -> Void) {
        let parameter: InternalTransferOperativeData = containerParameter()
        let otpFilled: OTPFilled = containerParameter()
        let otp: OTP = containerParameter()
        var validation = otpFilled.validation
        let otpCode = otpFilled.value
        guard let internalTransfer: InternalTransfer = parameter.internalTransfer, let time = parameter.time, let scheduledTransfer =  parameter.scheduledTransfer else { return }
        guard
            let originAccount = internalTransfer.originAccount,
            let destinationAccount = internalTransfer.destinationAccount,
            let amount = internalTransfer.amount
            else {
                completion(false, nil)
                return
        }
        
        if validation == nil {
            switch otp {
            case .userExcepted(let innerValidation):
                validation = innerValidation
            case .validation(let innerValidation):
                validation = innerValidation
            }
        }
    
        let inputData = ConfirmOTPInternalScheduledTransferUseCaseInput(
            otpValidation: validation,
            code: otpCode,
            originAccount: originAccount,
            destinationAccount: destinationAccount,
            amount: amount,
            concept: internalTransfer.concept ?? "",
            transferTime: time,
            scheduledTransfer: scheduledTransfer
        )
        
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmOTPInternalScheduledTransferUseCase(input: inputData),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter.errorOtpHandler,
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { error in
                    completion(false, error)
            }
        )
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let parameter: InternalTransferOperativeData = containerParameter()
        switch parameter.time {
        case .now?:
            return dependencies.stringLoader.getString("summary_title_foundTransfer")
        case .day?:
            return dependencies.stringLoader.getString("summary_title_transferDone")
        case .periodic?:
            return dependencies.stringLoader.getString("summary_title_transferDone")
        case .none:
            return dependencies.stringLoader.getString("summary_title_foundTransfer")
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        let parameter: InternalTransferOperativeData = containerParameter()
        switch parameter.time {
        case .now?:
            return dependencies.stringLoader.getString("summary_subtitle_transferAccount")
        case .day?:
            return dependencies.stringLoader.getString("summary_subtitle_transferDone")
        case .periodic?:
            return dependencies.stringLoader.getString("summary_subtitle_transferDone")
        case .none:
            return dependencies.stringLoader.getString("summary_subtitle_transferAccount")
        }
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard let transferAccount: TransferAccount = parameter.transferAccount else { return nil }
        guard let internalTransfer: InternalTransfer = parameter.internalTransfer else { return nil }
        guard
            let originAccount = internalTransfer.originAccount,
            let destinationAccount = internalTransfer.destinationAccount,
            let amount = internalTransfer.amount
        else {
            return nil
        }
    
        var concept: String = dependencies.stringLoader.getString("onePay_label_notConcept").text
        
        if let updateConcept = internalTransfer.concept, !updateConcept.isEmpty {
            concept = updateConcept
        }
        
       let stringLoader = dependencies.stringLoader
        
        guard  let time = parameter.time else { return nil }
    
        switch time {
        case .now:
            return [
                SimpleSummaryData(field: stringLoader.getString("summary_item_type"), value: stringLoader.getString("toolbar_title_transfer").text),
                SimpleSummaryData(field: stringLoader.getString("summary_item_originAccountTransfer"), value: originAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_destinationAccountsTransfer"), value: destinationAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getAbsFormattedAmountUI()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_concept"), value: concept),
                SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: transferAccount.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""),
                SimpleSummaryData(field: stringLoader.getString("summary_item_commission"), value: transferAccount.bankChargeAmount.getAbsFormattedAmountUI()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_mailExpenses"), value: transferAccount.expensesAmount.getAbsFormattedAmountUI()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_amountToDebt"), value: transferAccount.netAmount.getAbsFormattedAmountUI())
            ]
        case .day:
            return [
                SimpleSummaryData(field: stringLoader.getString("summary_item_type"), value: stringLoader.getString("transfer_label_programmedTransfer").text),
                SimpleSummaryData(field: stringLoader.getString("summary_item_originAccountTransfer"), value: originAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_destinationAccountsTransfer"), value: destinationAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getAbsFormattedAmountUI()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_concept"), value: concept),
                SimpleSummaryData(field: stringLoader.getString("summary_item_periodicity"), value: stringLoader.getString("confirmation_label_delayed").text),
                SimpleSummaryData(field: stringLoader.getString("summary_item_issuanceDate"), value: dependencies.timeManager.toString(date: transferAccount.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""),
                SimpleSummaryData(field: stringLoader.getString("summary_item_commission"), value: transferAccount.bankChargeAmount.getAbsFormattedAmountUI())
            ]
        case .periodic:
            return [
                SimpleSummaryData(field: stringLoader.getString("summary_item_type"), value: stringLoader.getString("transfer_label_programmedTransfer").text),
                SimpleSummaryData(field: stringLoader.getString("summary_item_originAccountTransfer"), value: originAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_destinationAccountsTransfer"), value: destinationAccount.getAliasAndInfo()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getAbsFormattedAmountUI()),
                SimpleSummaryData(field: stringLoader.getString("summary_item_concept"), value: concept),
                SimpleSummaryData(field: stringLoader.getString("summary_item_periodicity"), value: periodicity(time)),
                SimpleSummaryData(field: stringLoader.getString("summary_item_startDate"), value: dependencies.timeManager.toString(date: transferAccount.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""),
                SimpleSummaryData(field: stringLoader.getString("summary_item_endDate"), value: endDate(time) ?? ""),
                SimpleSummaryData(field: stringLoader.getString("summary_item_commission"), value: transferAccount.bankChargeAmount.getAbsFormattedAmountUI())
            ]
        }
    }
    
    private func periodicity(_ periodicity: OnePayTransferTime) -> String {
        let periodicity: String
        let parameter: InternalTransferOperativeData = containerParameter()
        switch parameter.time {
        case .day?:
            periodicity = dependencies.stringLoader.getString("summary_label_delayed").text
        case .periodic(_, _, let periodicityValue, _)?:
            switch periodicityValue {
            case .monthly: periodicity = dependencies.stringLoader.getString("summary_label_monthly").text
            case .quarterly: periodicity = dependencies.stringLoader.getString("summary_label_quarterly").text
            case .biannual: periodicity = dependencies.stringLoader.getString("summary_label_sixMonthly").text
            case .weekly: periodicity = dependencies.stringLoader.getString("summary_label_weekly").text
            case .bimonthly: periodicity = dependencies.stringLoader.getString("summary_label_bimonthly").text
            case .annual: periodicity = dependencies.stringLoader.getString("summary_label_annual").text
            }
        case .now?:
            periodicity = dependencies.stringLoader.getString("summary_label_standar").text
        default:
            periodicity = dependencies.stringLoader.getString("summary_label_standar").text
        }
        return periodicity
    }
    
    private func endDate(_ time: OnePayTransferTime) -> String? {
        let issueDate: String?
        switch time {
        case .periodic(_, let endDate, _, _):
            switch endDate {
            case .never:
                issueDate = dependencies.stringLoader.getString("detailsOnePay_label_indefinite").text
            case .date(let endDate):
                issueDate = dependencies.timeManager.toString(date: endDate, outputFormat: .dd_MMM_yyyy) ?? ""
            }
        default:
            issueDate = nil
        }
        return issueDate
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        let stringLoader = dependencies.stringLoader
        let operativeData: InternalTransferOperativeData = containerParameter()
        
        switch operativeData.origin {
        case .pg, .deepLink:
            return stringLoader.getString("generic_button_globalPosition")
        case .home, .personalArea:
            return stringLoader.getString("generic_button_continue")
        }
    }
    
    // MARK: - Tracker
    
    var screenIdProductSelection: String? {
        return TrackerPagePrivate.InternalTransferOriginAccountSelection().page
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.InternalTransferSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.InternalTransferSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: InternalTransferOperativeData = container.provideParameter()
        guard let amount = operativeData.internalTransfer?.amount else {
            return nil
        }
        return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName, TrackerDimensions.scheduledTransferType: operativeData.time?.trackerDescription ?? ""]
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        let parameter: InternalTransferOperativeData = containerParameter()
        return [TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? ""]
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        let parameter: InternalTransferOperativeData = containerParameter()
        return [TrackerDimensions.scheduledTransferType: parameter.time?.trackerDescription ?? ""]
    }
}

private extension InternalTransferOperative {
    
    private func buildSteps() {
        
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Account.self)
        add(step: factory.createStep() as InternalTransferAccountDestinationSelectionStep)
        add(step: factory.createStep() as InternalTransferInsertAmountStep)
        add(step: factory.createStep() as InternalTransferConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    private func buildStepsForDeferred() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Account.self)
        add(step: factory.createStep() as InternalTransferAccountDestinationSelectionStep)
        add(step: factory.createStep() as InternalTransferInsertAmountStep)
        add(step: factory.createStep() as InternalDeferredTransferConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    private func  buildStepsForPeriodic() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Account.self)
        add(step: factory.createStep() as InternalTransferAccountDestinationSelectionStep)
        add(step: factory.createStep() as InternalTransferInsertAmountStep)
        add(step: factory.createStep() as InternalPeriodicTransferConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
}

/// The destination account selection step
/// - Input parameters: InternalTransferOperativeData(accounts: [Account], account: Account?)
/// - Output parameters: InternalTransferOperativeData(accounts: [Account], account: Account?, internalTransfer: InternalTransfer(originAccount: selectedProduct, destinationAccount: selectedDestinationAccount))
struct InternalTransferAccountDestinationSelectionStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.accountDestinationSelectionPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

/// The view for adding amount and concept step
/// - Input parameters: InternalTransferOperativeData(accounts: [Account], account: Account?, internalTransfer: InternalTransfer(originAccount: selectedProduct, destinationAccount: selectedDestinationAccount))
/// - Output parameters: InternalTransferOperativeData(accounts: [Account], account: Account?, internalTransfer: InternalTransfer(originAccount: selectedProduct, destinationAccount: selectedDestinationAccount, amount: amount, concept: concept))
struct InternalTransferInsertAmountStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.insertAmountPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

/// The internal transfer confirmation step
/// - Input parameters: InternalTransferOperativeData(accounts: [Account], account: Account?, internalTransfer: InternalTransfer(originAccount: selectedProduct, destinationAccount: selectedDestinationAccount, amount: amount, concept: concept))
/// - Output parameters: InternalTransferOperativeData(accounts: [Account], account: Account?, internalTransfer: InternalTransfer(originAccount: selectedProduct, destinationAccount: selectedDestinationAccount, amount: amount, concept: concept)) & Signature
struct InternalTransferConfirmationStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.confirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct InternalDeferredTransferConfirmationStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.confirmationDeferredInternalTransferPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct InternalPeriodicTransferConfirmationStep: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.accountOperatives.confirmationPeriodicInternalTransferPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
