import CoreFoundationLib
import Foundation

class ExtraordinaryContributionOperative: MifidLauncherOperative {
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
        return .pensionExtraordinaryContribution
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .pensionExtraordinaryContribution
    }
    var mifidState: MifidState = .unknown
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.PensionExtraordinaryContributionSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.PensionExtraordinaryContributionSignature().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        guard let extraContribution = operativeData.extraContributionPension else {
            return nil
        }
        let amount = extraContribution.amount
        return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Pension.self)
        add(step: factory.createStep() as SelectExtraordinaryContributionAmount)
        add(step: factory.createStep() as ConfirmExtraordinaryContribution)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        guard let extraContribution = operativeData.extraContributionPension else { return }
        let pension = extraContribution.originPension
        let amount = extraContribution.amount
        
        let input = ConfirmExtraordinaryContributionUseCaseInput(pension: pension, amount: amount, signatureToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.confirmExtraordinaryContributionUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: ExtraContributionPensionOperativeData = container.provideParameter()
        let input = SetupPensionExtraordinaryContributionUseCaseInput(pension: operativeData.productSelected)
        UseCaseWrapper(with: dependencies.useCaseProvider.setupPensionExtraordinaryContributionUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            container.saveParameter(parameter: result.operativeConfig)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: ExtraContributionPensionOperativeData = container.provideParameter()
        let input = PreSetupPensionExtraordinaryContributionUseCaseInput(pension: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.getPreSetupPensionExtraordinaryContributionUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let operativeData: ExtraContributionPensionOperativeData = container.provideParameter()
            operativeData.updatePre(pensions: result.pensions)
            container.saveParameter(parameter: operativeData)
            completion(true, nil)
        }, onError: { error in
            guard let errorDesc = error?.getErrorDesc() else {
                completion(false, nil)
                return
            }
            completion(false, (title: nil, message: errorDesc))
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_extraContribution")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let operativeData: ExtraContributionPensionOperativeData = containerParameter()
        guard let extraContribution = operativeData.extraContributionPension else { return [] }
        let pension = extraContribution.originPension
        let amount = extraContribution.amount
        let infoOperation = extraContribution.pensionInfoOperation
        let associatedAccount = extraContribution.account
        
        let stringLoader = dependencies.stringLoader
        
        let plan = SimpleSummaryData(field: stringLoader.getString("summary_item_plan"), value: pension.getAliasAndInfo())
        let ownerData = SimpleSummaryData(field: stringLoader.getString("summary_item_holder"), value: infoOperation.holder?.camelCasedString ?? "")
        let descriptionData = SimpleSummaryData(field: stringLoader.getString("summary_item_description"), value: infoOperation.description ?? "")
        let linkedAccountData = SimpleSummaryData(field: stringLoader.getString("summary_item_associatedAccount"), value: associatedAccount?.getAliasAndInfo() ?? infoOperation.associatedAccountIban.getAliasAndInfo(withCustomAlias: dependencies.stringLoader.getString("generic_summary_associatedAccount").text))
        let amountData = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getFormattedAmountUI())
        let dateData = SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? "")
        
        return [plan, ownerData, descriptionData, linkedAccountData, amountData, dateData]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return nil
    }
}

struct SelectExtraordinaryContributionAmount: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.pensionOperatives.extraordinaryContributionAmountPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ConfirmExtraordinaryContribution: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.pensionOperatives.extraordinaryContributionConfrimationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ExtraordinaryPensionParameter: OperativeParameter {
    let pensionList: PensionList?
}
