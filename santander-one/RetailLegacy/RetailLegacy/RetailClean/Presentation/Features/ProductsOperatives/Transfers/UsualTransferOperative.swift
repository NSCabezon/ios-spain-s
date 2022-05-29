import CoreFoundationLib
import Operative

class UsualTransferOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable: Bool {
        return getSummaryState() == .success
    }
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    var opinatorPage: OpinatorPage? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let type = parameter.type else { return nil }
        switch type {
        case .national, .sepa:
            return .usualTransfer
        case .noSepa:
            return .noSepaUsualTransfer
        }
    }
    
    private var sca: SCA? {
        let scaEntity: LegacySCAEntity? = self.container?.provideParameterOptional()
        return scaEntity?.sca
    }
    
    private var stepFactory: OperativeStepFactory? {
        guard let presenterProvider = container?.presenterProvider else {
            return nil
        }
        return OperativeStepFactory(presenterProvider: presenterProvider)
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func commonsSteps() {
        guard let factory = self.stepFactory else { return }
        let accountParameter: ProductSelection<Account> = containerParameter()
        if !accountParameter.isProductSelectedWhenCreated {
            add(step: factory.createStep() as UsualTransferAccountSelectorStep) //Put this step to use the account selector of Transfer module
        }
        add(step: factory.createStep() as UsualTransferSelectorStep)
        let parameter: UsualTransferOperativeData = containerParameter()
        if parameter.type == .national {
            add(step: factory.createStep() as UsualTransferSubtypeSelectorStep)
        }
        add(step: factory.createStep() as UsualTransferConfirmationStep)
    }
    
    func buildSteps() {
        guard let factory = self.stepFactory else { return }
        self.commonsSteps()
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func rebuildSteps() {
        guard let factory = self.stepFactory else { return }
        self.commonsSteps()
        self.sca?.prepareForVisitor(self)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let type = parameter.type, let originAccount = parameter.account, let amount = parameter.amount, let subType = parameter.subType else {
            completion(false, nil)
            return
        }
        let input = ConfirmUsualTransferUseCaseInput(signature: signatureFilled.signature, type: type, subtype: subType, originAccount: originAccount, amount: amount, favourite: parameter.originTransfer, concept: parameter.concept, beneficiaryMail: parameter.beneficiaryMail)
        let usecase = dependencies.useCaseProvider.getConfirmUsualTransferUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { result in
            parameter.transferConfirmAccount = result.transferConfirmAccount
            self.container?.saveParameter(parameter: parameter)
            if subType == .immediate {
                self.performCheckInternal(for: presenter, completion: completion)
            } else {
                parameter.summaryState = .success
                self.container?.saveParameter(parameter: parameter)
                completion(true, nil)
            }
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getRichSharingText() -> String? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard
            let originAccountIBAN = parameter.productSelected?.getAsteriskIban(),
            let destinationIBAN = parameter.iban?.getAsterisk(),
            let payer = parameter.payer
        else {
            return nil
        }
        let builder = TransferEmailBuilder(stringLoader: dependencies.stringLoader)
        let concept: String
        if let transferConcept = parameter.concept, !transferConcept.isEmpty {
            concept = transferConcept
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer", [StringPlaceholder(.name, payer), StringPlaceholder(.value, destinationIBAN), StringPlaceholder(.value, concept)]).text)
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            builder.addHeader(title: dependencies.stringLoader.getString("mail_subtitle_transfer_withoutConcept", [StringPlaceholder(.name, payer), StringPlaceholder(.value, destinationIBAN)]).text)
        }
        builder.addTransferInfo([
            EmailInfo(key: "summary_item_payer", value: payer, detail: originAccountIBAN),
            EmailInfo(key: "summary_item_beneficiary", value: parameter.name, detail: destinationIBAN),
            EmailInfo(key: "summary_item_amount", value: parameter.amount, detail: nil),
            EmailInfo(key: "summary_item_concept", value: parameter.concept.map({ $0.isEmpty ? dependencies.stringLoader.getString("onePay_label_notConcept").text : $0 }), detail: nil),
            EmailInfo(key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.issueDate, outputFormat: .dd_MMM_yyyy), detail: nil),
            EmailInfo(key: "summary_item_commission", value: parameter.transferNational?.bankChargeAmount, detail: nil),
            EmailInfo(key: "summary_item_mailExpenses", value: parameter.transferNational?.expensesAmount, detail: nil),
            EmailInfo(key: "summary_item_amountToDebt", value: parameter.transferNational?.netAmount, detail: nil)
        ])
        return builder.build()
    }
    
    private func performCheckInternal(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let parameter: UsualTransferOperativeData = containerParameter()
        let stringLoader = dependencies.stringLoader
        LoadingCreator.setLoadingText(loadingText: LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_onePay")))
        guard let transferConfirmAccount = parameter.transferConfirmAccount else {
            completion(false, nil)
            return
        }
        let input = CheckStatusOnePayTransferUseCaseInput(transferConfirmAccount: transferConfirmAccount)
        let usecase = dependencies.useCaseProvider.getCheckStatusOnePayTransferUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { result in
            parameter.summaryState = result.status
            self.container?.saveParameter(parameter: parameter)
            completion(true, nil)
        }, onError: { error in
            presenter.onError(keyDesc: error?.getErrorDesc(), completion: {
                self.container?.reloadPGAndExit()
            })
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.setupUsualTransferUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: UsualTransferOperativeData = container.provideParameter()
            container.saveParameter(parameter: result.operativeConfig)
            operativeData.update(maxImmediateNationalAmount: result.maxAmount)
            container.saveParameter(parameter: operativeData)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: UsualTransferOperativeData = container.provideParameter()
        let input = PreSetupOnePayTransferCardUseCaseInput(account: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupOnePayTransferCardUseCase().setRequestValues(requestValues: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: UsualTransferOperativeData = container.provideParameter()
            operativeData.updatePre(accounts: result.accountVisibles, accountNotVisibles: result.accountNotVisibles, sepaList: result.sepaList, faqs: result.faqs)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { _ in
            completion(false, nil)
        })
    }
    
    private func getInmediateSummaryTitle() -> LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let summaryState = parameter.summaryState else {
            return .empty
        }
        switch summaryState {
        case .success:
            return dependencies.stringLoader.getString("summary_title_immediateOnePay")
        case .error:
            return dependencies.stringLoader.getString("summary_title_notImmediateOnePay")
        case .pending:
            return dependencies.stringLoader.getString("summary_title_pendingImmediateOnePay")
        }
    }
    
    private func getNationalSummaryTitle() -> LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let subType = parameter.subType else {
            return .empty
        }
        switch subType {
        case .standard:
            return dependencies.stringLoader.getString("summary_title_standardOnePay")
        case .immediate:
            return getInmediateSummaryTitle()
        case .urgent:
            return dependencies.stringLoader.getString("summary_title_expressOnePay")
        }
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let type = parameter.type else {
            return .empty
        }
        switch type {
        case .national:
            return getNationalSummaryTitle()
        case .sepa:
            return dependencies.stringLoader.getString("summary_title_standardOnePay")
        case .noSepa:
            return .empty
        }
    }
    
    private func getInmediateSummarySubtitle() -> LocalizedStylableText? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let summaryState = parameter.summaryState else {
            return nil
        }
        switch summaryState {
        case .success:
            return dependencies.stringLoader.getString("summary_subtitle_immediateOnePay")
        case .error:
            return dependencies.stringLoader.getString("summary_subtitle_errorImmediateOnePay")
        case .pending:
            return dependencies.stringLoader.getString("summary_title_processedOperation")
        }
    }
    
    private func getNationalSummarySubtitle() -> LocalizedStylableText? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let subType = parameter.subType else {
            return nil
        }
        switch subType {
        case .standard:
            return dependencies.stringLoader.getString("summary_subtitle_standardOnePay")
        case .immediate:
            return getInmediateSummarySubtitle()
        case .urgent:
            return dependencies.stringLoader.getString("summary_label_expressOnePay")
        }
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let type = parameter.type else {
            return nil
        }
        switch type {
        case .national:
            return getNationalSummarySubtitle()
        case .sepa:
            return dependencies.stringLoader.getString("summary_subtitle_intenationalOnePay")
        case .noSepa:
            return nil
        }
    }
    
    var pdfTitle: String? {
        return "toolbar_title_detailOnePay"
    }
    
    var pdfContent: String? {
        if getSummaryState() == .success {
            let parameter: UsualTransferOperativeData = containerParameter()
            switch parameter.type {
            case .national?, .sepa?:
                return getSepaPfdContent()
            case .noSepa?:
                return getNoSepaPfdContent()
            case .none:
                break
            }
        }
        return nil
    }
    
    private func getSepaPfdContent() -> String? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard
            let originAccountAlias = parameter.productSelected?.getAlias(),
            let originAccountIBAN = parameter.productSelected?.getAsteriskIban(),
            let destinationIBAN = parameter.iban?.getAsterisk()
        else {
            return nil
        }
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
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: date)
        builder.addAccounts(originAccountAlias: originAccountAlias, originAccountIBAN: originAccountIBAN, destinationAccountAlias: parameter.name ?? "", destinationAccountIBAN: destinationIBAN)
        builder.addTransferInfo([
            (key: "summary_item_amount", value: parameter.amount),
            (key: "summary_item_concept", value: parameter.concept.map({ $0.isEmpty ? dependencies.stringLoader.getString("onePay_label_notConcept").text : $0 })),
            (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: parameter.issueDate, outputFormat: .dd_MMM_yyyy))
        ])
        builder.addExpenses([
            (key: "summary_item_commission", value: parameter.transferNational?.bankChargeAmount),
            (key: "summary_item_mailExpenses", value: parameter.transferNational?.expensesAmount),
            (key: "summary_item_amountToDebt", value: parameter.transferNational?.netAmount)
        ])
        return builder.build()
    }
    
    private func getNoSepaPfdContent() -> String? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let summaryState = getSummaryState()
        switch summaryState {
        case .pending:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.UsualTransferImmediateSummaryPending().page, extraParameters: [:])
        case .error:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.UsualTransferImmediateSummaryKO().page, extraParameters: [:])
        case .success:
            let parameter: UsualTransferOperativeData = containerParameter()
            
            let concept: String
            if let transferConcept = parameter.concept, !transferConcept.isEmpty {
                concept = transferConcept
            } else {
                concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            }
            let accountText: String = parameter.iban?.formatted ?? ""
            let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
            return [
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_type"), value: dependencies.stringLoader.getString(parameter.subType?.description ?? "summary_label_standar").text),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: "\(parameter.productSelected?.getAlias() ?? "") | \(parameter.productSelected?.getIBANShort() ?? "")"),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: "\(parameter.name ?? "")"),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: parameter.amount?.getAbsFormattedAmountUI() ?? ""),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: parameter.transferNational?.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_commission"), value: parameter.transferNational?.bankChargeAmount?.getAbsFormattedAmountUI() ?? ""),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_mailExpenses"), value: parameter.transferNational?.expensesAmount?.getAbsFormattedAmountUI() ?? ""),
                SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amountToDebt"), value: parameter.transferNational?.netAmount?.getAbsFormattedAmountUI() ?? "")
            ]
        }
        return []
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    func getSummaryState() -> OperativeSummaryState {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let summaryState = parameter.summaryState else {
            return .error
        }
        switch summaryState {
        case .success:
            return .success
        case .pending:
            return .pending
        case .error:
            return .error
        }
    }
    
    // MARK: - Tracker
    var screenIdSignature: String? {
        return TrackerPagePrivate.UsualTransferSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.UsualTransferSummary().page
    }
    
    private func typeUsualTransferParameters() -> [String: String]? {
        let parameter: UsualTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?:
            return [
                TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
            ]
        default:
            return nil
        }
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeUsualTransferParameters()
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        let parameter: UsualTransferOperativeData = containerParameter()
        guard let amount = parameter.amount else { return nil }
        switch parameter.type {
        case .national?:
            return [
                TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? "",
                TrackerDimensions.amount: amount.getTrackerFormattedValue(),
                TrackerDimensions.currency: amount.currencyName
            ]
        default:
            return [
                TrackerDimensions.amount: amount.getTrackerFormattedValue(),
                TrackerDimensions.currency: amount.currencyName
            ]
        }
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeUsualTransferParameters()
    }
    
    func getTrackParametersOTP() -> [String: String]? {
        return typeUsualTransferParameters()
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return typeUsualTransferParameters()
    }
}

struct UsualTransferAccountSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack = true
    var showsCancel = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.usualTransferAccountSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct UsualTransferSubtypeSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.usualTransferSelectorSubtypePresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct UsualTransferSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.usualTransferAmountEntryPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct UsualTransferConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.usualTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

extension UsualTransferOperative: SCACapable {}

extension UsualTransferOperative: SCASignatureCapable {
    func prepareForSignature(_ signature: Signature) {
        guard let factory = self.stepFactory else { return }
        self.container?.saveParameter(parameter: signature)
        self.add(step: factory.createStep() as OperativeSimpleSignature)
    }
}
