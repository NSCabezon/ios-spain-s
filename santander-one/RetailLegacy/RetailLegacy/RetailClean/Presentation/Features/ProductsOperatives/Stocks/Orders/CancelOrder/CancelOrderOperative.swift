import CoreFoundationLib

class CancelOrderOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.cancelOrderOperativeFinishedNavigator
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    var shouldShowProgress: Bool {
        return false
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as OperativeSimpleSignature)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let operativeData: CancelOrderOperativeData = container.provideParameter()
        let stockAccount = operativeData.stockAccount
        let order = operativeData.order
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
        let useCase = dependencies.useCaseProvider.confirmCancelOrderUseCase(input: ConfirmCancelOrderUseCaseInput(stockAccount: stockAccount, order: order, signature: signatureFilled.signature))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return .empty
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        return nil
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return nil
    }
}
