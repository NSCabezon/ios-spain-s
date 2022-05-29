import Foundation
import CoreFoundationLib

class ChangeMassiveDirectDebitsOperative: BillOperative {
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let isShareable = true
    let needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toBillHomeOperativeFinishNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .changeMassiveDirectDebit
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Account.self)
        add(step: factory.createStep() as ProductSelectionStep<ChangeMassiveDirectDebitsDestinationProfile>)
        add(step: factory.createStep() as ConfirmChangeMassiveDirectDebitsStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupChangeMassiveDirectDebitsUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                self.filterMassiveDirectDebit(for: delegate, accounts: result.accounts, container: container, completion: completion)
            }, onError: { error in
                completion(false, (title: nil, message: error?.getErrorDesc()))
            }
        )
    }
    
    func filterMassiveDirectDebit(for delegate: OperativeLauncherPresentationDelegate, accounts: [Account], container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getFilterMassiveDirectDebitUseCase(input: FilterMassiveDirectDebitUseCaseInput(accounts: accounts)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: ChangeMassiveDirectDebitsOperativeData = container.provideParameter()
                operativeData.list = result.accounts
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            },
            onError: { error in
                completion(false, (title: nil, message: error?.getErrorDesc()))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupChangeMassiveDirectDebitsUseCase(),
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
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let parameter: ChangeMassiveDirectDebitsOperativeData = containerParameter()
        guard let account = parameter.destinationAccount else { return }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getConfirmChangeMassiveDirectDebitsUseCase(input: ConfirmChangeMassiveDirectDebitsUseCaseInput(originAccount: account, signature: signatureFilled.signature)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: presenter,
            onSuccess: { _ in
                completion(true, nil)
            },
            onError: { error in
                completion(false, error)
            }
        )
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_changeDirectDebit")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_text_directDebitDestinationAccount")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: ChangeMassiveDirectDebitsOperativeData = containerParameter()
        return [
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: "\(parameter.productSelected?.getAliasAndInfo() ?? "")"),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountBalance"), value: "\(parameter.productSelected?.getAmountUI() ?? "")"),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: "\(parameter.destinationAccount?.getAliasAndInfo() ?? "")"),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountBalance"), value: "\(parameter.destinationAccount?.getAmountUI() ?? "")"),
            SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: "\(dependencies.timeManager.toString(date: Date(), outputFormat: .dd_MMM_yyyy) ?? "")")
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
        return TrackerPagePrivate.ChangeMassiveDirectDebitsOriginAccount().page
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.ChangeMassiveDirectDebitsSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ChangeMassiveDirectDebitsSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return nil
    }
}

struct ConfirmChangeMassiveDirectDebitsStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.changeMassiveDirectDebitsConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
