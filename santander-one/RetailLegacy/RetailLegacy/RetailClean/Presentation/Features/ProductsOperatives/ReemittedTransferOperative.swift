//

import CoreFoundationLib

class ReemittedTransferOperative: OnePayTransferOperative {
    
    override var opinatorPage: OpinatorPage? {
        guard let container = container else { return nil }
        let operativeData: ReemittedTransferOperativeData = container.provideParameter()
        switch operativeData.type {
        case .national?:
            return .reemittedTransfer
        default:
            return .internationalReemittedTransfer
        }
    }
    
    override var giveUpOpinatorPage: OpinatorPage? {
        return .reemittedTransfer
    }
        
    private var sca: SCA? {
        let scaEntity: LegacySCAEntity? = self.container?.provideParameterOptional()
        return scaEntity?.sca
    }
    
    func commonsSteps() {
        guard let factory = self.stepFactory else { return }
        let accountParameter: ProductSelection<Account> = containerParameter()
        if !accountParameter.isProductSelectedWhenCreated {
            add(step: factory.createStep() as ReemittedTransferAccountSelectorStep) //Put this step to use the account selector of Transfer module
        }
        add(step: factory.createStep() as ReemittedTransferAmountEntryStep)
        add(step: factory.createStep() as ReemittedTransferSubtypeSelectorStep)
        add(step: factory.createStep() as ReemittedTransferConfirmationStep)
    }
    
    override func buildSteps() {
        guard let factory = self.stepFactory else { return }
        self.commonsSteps()
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeOTP)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    override func rebuildSteps() {
        guard let factory = self.stepFactory else { return }
        self.commonsSteps()
        self.sca?.prepareForVisitor(self)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    override func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        super.performSetup(for: delegate, container: container) {
            let operativeData: ReemittedTransferOperativeData = container.provideParameter()
            operativeData.country = operativeData.sepaList?.getSepaCountryInfo(operativeData.transferDetail.beneficiary?.countryCode)
            operativeData.currency = operativeData.sepaList?.getSepaCurrencyInfo(operativeData.transfer.amount?.currency?.currencyName)
            container.saveParameter(parameter: operativeData)
            success()
        }
    }
    
    override func trackSummaryState() {
        let summaryState = getSummaryState()
        switch summaryState {
        case .pending:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.ReemittedTransferImmediateSummaryPending().page, extraParameters: [:])
        case .error:
            dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.ReemittedTransferImmediateSummaryKO().page, extraParameters: [:])
        case .success:
            break
        }
    }
    
    // MARK: - Tracker
    
    override var screenIdSignature: String? {
        return TrackerPagePrivate.ReemittedTransferSignature().page
    }
    
    override var screenIdSummary: String? {
        return TrackerPagePrivate.ReemittedTransferSummary().page
    }
    
    override var screenIdOtp: String? {
        return TrackerPagePrivate.ReemittedTransferOTP().page
    }
    
    private func typeReemitedTransferParameters() -> [String: String]? {
        let parameter: ReemittedTransferOperativeData = containerParameter()
        switch parameter.type {
        case .national?:
            return [
                TrackerDimensions.transferType: parameter.subType?.trackerDescription ?? ""
            ]
        default: return nil
        }
    }
    
    override var extraParametersForTrackerError: [String: String]? {
        return typeReemitedTransferParameters()
    }
    
    override func getTrackParametersSummary() -> [String: String]? {
        let operativeData: ReemittedTransferOperativeData = containerParameter()
        guard let amount = operativeData.amount else {
            return nil
        }
        let parameters: [String: String] = typeReemitedTransferParameters() ?? [:]
        var summaryParameters = [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
        for (key, value) in parameters {
            summaryParameters[key] = value
        }
        return summaryParameters
    }
    
    override func getTrackParametersSignature() -> [String: String]? {
        return typeReemitedTransferParameters()
    }
    
    override func getTrackParametersOTP() -> [String: String]? {
        return typeReemitedTransferParameters()
    }
    
    override func getExtraTrackShareParametersSummary() -> [String: String]? {
        return typeReemitedTransferParameters()
    }
}

struct ReemittedTransferAccountSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack = true
    var showsCancel = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.reemittedTransferAccountSelectorPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ReemittedTransferAmountEntryStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.reemittedTransferAmountEntryPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ReemittedTransferSubtypeSelectorStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.reemittedTransferSelectorSubtypePresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ReemittedTransferConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.reemittedTransferConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
