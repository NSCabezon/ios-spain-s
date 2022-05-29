import Foundation
import CoreFoundationLib

class BillsAndTaxesOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = true
    let needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toBillHomeOperativeFinishNavigator
    }
    var operativeType: BillsAndTaxesTypeOperative? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        return type
    }
    var opinatorPage: OpinatorPage? {
        guard let operativeType = self.operativeType else { return nil }
        switch operativeType {
        case .bills:
            return .payBills
        case .taxes:
            return .payTaxes
        }
    }
    var pdfTitle: String? {
        return "toolbar_title_detailReceipt"
    }
    
    var navigationTitle: String? {
        guard let operativeType = self.operativeType else { return nil }
        var headerKey: String
        switch operativeType {
        case .bills:
            headerKey = "toolbar_title_payReceipts"
        case .taxes:
            headerKey = "toolbar_title_taxPayment"
        }
        return headerKey
    }
    
    var signatureNavigationTitle: String? {
        return navigationTitle
    }
    
    var otpNavigationTitle: String? {
        return navigationTitle
    }
    
    var pdfContent: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes = parameter.paymentBillTaxes else { return nil }
        guard let account = parameter.productSelected else { return nil }
        let amount = paymentBillTaxes.amount
        let issuingEntity = paymentBillTaxes.issuingDescription
        let entityCode = paymentBillTaxes.codeEntity
        let reference = paymentBillTaxes.reference
        let id = paymentBillTaxes.id
        let builder = BillPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        let date = Date()
        builder.addHeader(title: "pdf_label_makePayment", office: nil, date: date)
        builder.addAccountInfo(issuerName: issuingEntity, issuerCode: entityCode, account: account)
        builder.addTransferInfo([
            (key: "summary_item_reference", value: reference),
            (key: "summary_item_identifier", value: id),
            (key: "summary_item_paymentDate", value: dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) ?? ""),
            (key: "summary_item_amount", value: amount.getAbsFormattedAmountUI())
            ])
        return builder.build()
    }
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func rebuildSteps() {
        self.buildSteps()
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        if !operativeData.isProductSelectedWhenCreated {
            add(step: factory.createStep() as SelectorAccountPresenterStep)
        }
        add(step: factory.createStep() as ModeSelectorPresenterStep)
        if case .camera = operativeData.modeTypeSelector {
            add(step: factory.createStep() as BarcodeScannerPresenterStep)
        }
        add(step: factory.createStep() as ManualModeBillsAndTaxesPresenterStep)
        add(step: factory.createStep() as ConfirmBillsAndTaxesPresenterStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: BillAndTaxesOperativeData = container.provideParameter()
        let input = PreSetupBillsAndTaxesUseCaseInput(account: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupBillsAndTaxesUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: BillAndTaxesOperativeData = container.provideParameter()
            operativeData.faqs = result.faqs
            operativeData.updatePre(accounts: result.accounts, accountNotVisibles: result.accountNotVisibles)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { _ in
            completion(false, (title: nil, message: "deeplink_alert_errorSend"))
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.getSetupBillsAndTaxesUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            container.saveParameter(parameter: result.operativeConfig)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let parameter: BillAndTaxesOperativeData = self.containerParameter()
        guard let paymentBillTaxes: PaymentBillTaxes = parameter.paymentBillTaxes, let directDebit = parameter.directDebit else { return }
        
        let input = ConfirmBillsAndTaxesUseCaseInput(signatureWithToken: signatureFilled.signature, account: paymentBillTaxes.originAccount, paymentBillTaxes: paymentBillTaxes, directDebit: directDebit)
        
        let useCase = dependencies.useCaseProvider.confirmBillsAndTaxesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_payMade")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills:
             return dependencies.stringLoader.getString("summary_label_periodPayReceipts")
        case .taxes:
             return dependencies.stringLoader.getString("summary_label_periodPayTaxes")
        }
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes = parameter.paymentBillTaxes else { return nil }
        let account = paymentBillTaxes.originAccount.getAliasAndInfo()
        let amount = paymentBillTaxes.amount
        let issuingEntity = paymentBillTaxes.issuingDescription
        let entityCode = paymentBillTaxes.codeEntity
        let reference = paymentBillTaxes.reference
        let id = paymentBillTaxes.id
        
        return [
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: amount.getAbsFormattedAmountUI()),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_account"), value: account),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_EntityIssuing"), value: issuingEntity),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_issuingEntity"), value: entityCode),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_reference"), value: reference),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_identification"), value: id),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? "")
        ]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Tracker
    
    var screenIdProductSelection: String? {
        return TrackerPagePrivate.BillAndTaxesPayOriginAccountSelection().page
    }
    
    var screenIdSignature: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills:
            return TrackerPagePrivate.BillAndTaxesPayBillSignature().page
        case .taxes:
            return TrackerPagePrivate.BillAndTaxesPayTaxSignature().page
        }
    }
    
    var screenIdSummary: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills:
            return TrackerPagePrivate.BillAndTaxesPayBillSummary().page
        case .taxes:
            return TrackerPagePrivate.BillAndTaxesPayTaxSummary().page
        }
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let paymentBillTaxes = parameter.paymentBillTaxes else { return nil }
        let amount = paymentBillTaxes.amount
        return  [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
    var infoHelpButtonFaqs: [FaqsItemViewModel]? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        let faqModel = parameter.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
            } ?? nil
        return faqModel
    }
    
    func trackErrorEvent(page: String?, error: String?, code: String?) {
        guard let page = page else { return }
        var parmaters: [String: String] = extraParametersForTrackerError ?? [:]
        if var errorDesc = error {
            if let wsError = dependencies.stringLoader.getWsErrorIfPresent(errorDesc) {
                errorDesc = wsError.text
            }
            parmaters[TrackerDimensions.descError] = errorDesc
        }
        if let errorCode = code {
            parmaters[TrackerDimensions.codError] = errorCode
        }
        self.dependencies.trackerManager.trackEvent(screenId: page, eventId: TrackerPagePrivate.Generic.Action.error.rawValue, extraParameters: parmaters)
    }
}

struct SelectorAccountPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.accountSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct TypeSelectorPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.typeSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ModeSelectorPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.modeSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct BarcodeScannerPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.barcodeScannerPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ManualModeBillsAndTaxesPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.manualModePresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ConfirmBillsAndTaxesPresenterStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.billsAndTaxesOperatives.billsAndTaxesConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
