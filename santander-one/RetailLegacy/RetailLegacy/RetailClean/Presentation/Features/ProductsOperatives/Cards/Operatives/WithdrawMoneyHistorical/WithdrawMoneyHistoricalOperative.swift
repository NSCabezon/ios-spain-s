import CoreFoundationLib

class WithdrawMoneyHistoricalOperative {
    var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var steps = [OperativeStep]()
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    private func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as WithdrawMoneyHistoricalStep)
    }
    
    var shouldShowProgress: Bool {
        return false
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.HistoricCashWithdrawlCodeSignature().page
    }
}

extension WithdrawMoneyHistoricalOperative: Operative {
    var isShareable: Bool {
        return false
    }
    var needsReloadGP: Bool {
        return false
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .cashWithdrawal
    }
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.withdrawHistoricalOperativeFinishedNavigator
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        let signatureFilled: SignatureFilled<SignatureWithToken> = containerParameter()
        let data: WithdrawMoneyHistoricalOperativeData = containerParameter()
        guard let card = data.card else { return }
        let input = ConfirmWithdrawMoneyHistoricalUseCaseInput(card: card, signatureWithToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.confirmWithdrawMoneyHistoricalUseCase(input: input)
        let container = self.container
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { result in
            container?.saveParameter(parameter: result.dispensationsList)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
}

extension WithdrawMoneyHistoricalOperative: NoSummaryOperative {}

struct WithdrawMoneyHistoricalStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.withdrawMoneyHistoricalPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
