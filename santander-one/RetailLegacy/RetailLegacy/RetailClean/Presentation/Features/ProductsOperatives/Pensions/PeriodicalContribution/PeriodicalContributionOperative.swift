import CoreFoundationLib

class PeriodicalContributionOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toRetirementPlanHomeNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .pensionPeriodicalContribution
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.PensionPeriodicalContributionSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.PensionPeriodicalContributionSignature().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        let amount: Amount = containerParameter()
        return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        add(step: factory.createStep() as SetContributionAmount)
        add(step: factory.createStep() as ConfigureContributionQuote)
        add(step: factory.createStep() as PeriodicalContributionConfirmation)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()

        let pension: Pension = container.provideParameter()
        let amount: Amount = container.provideParameter()
        let configuration: ContributionConfiguration = container.provideParameter()
        let input = ConfirmPeriodicalContributionUseCaseInput(pension: pension, amount: amount, signatureToken: signatureFilled.signature, contributionConfiguration: configuration)
        let useCase = dependencies.useCaseProvider.confirmPeriodicalContributionUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_extraContribution")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let pension: Pension = container.provideParameter()
        let pensionInfoOperation: PensionInfoOperation = container.provideParameter()
        let amount: Amount = container.provideParameter()
        let configuration: ContributionConfiguration = container.provideParameter()
        let account: Account? = container.provideParameterOptional()
        
        let stringLoader = dependencies.stringLoader
        
        let pensionData = SimpleSummaryData(field: stringLoader.getString("summary_item_plan"), value: pension.getAliasAndInfo())
        let ownerData = SimpleSummaryData(field: stringLoader.getString("summary_item_holder"), value: pensionInfoOperation.holder?.capitalized ?? "")
        let linkedAccountData = SimpleSummaryData(field: stringLoader.getString("summary_item_associatedAccount"), value: account?.getAliasAndInfo() ?? pensionInfoOperation.associatedAccountIban.getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text))
        let amountData = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getFormattedAmountUI())
        let periodicityData = SimpleSummaryData(field: stringLoader.getString("summary_item_periodicity"), value: configuration.periodicity.localizedText(stringLoader: stringLoader).text)
        let startDateData = SimpleSummaryData(field: stringLoader.getString("summary_item_startDate"), value: dependencies.timeManager.toString(date: configuration.startDate, outputFormat: .d_MMM_yyyy) ?? "")
        let revaluationData = SimpleSummaryData(field: stringLoader.getString("summary_item_revalorization"), value: configuration.revaluation.localizedText(stringLoader: stringLoader).text)
        
        return [pensionData, ownerData, linkedAccountData, amountData, periodicityData, startDateData, revaluationData]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct SetContributionAmount: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.pensionOperatives.periodicalContributionAmountPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ConfigureContributionQuote: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.pensionOperatives.contributionQuoteConfigurationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct PeriodicalContributionConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.pensionOperatives.periodicalContributionConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
