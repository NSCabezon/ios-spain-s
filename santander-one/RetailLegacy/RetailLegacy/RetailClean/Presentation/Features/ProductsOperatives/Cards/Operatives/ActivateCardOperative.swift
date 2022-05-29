import CoreFoundationLib
import Foundation

class ActivateCardOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    let dependencies: PresentationComponent
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    
    var isShareable: Bool = false
    var needsReloadGP: Bool = true
    var steps = [OperativeStep]()
    var opinatorPage: OpinatorPage? {
        return .activateCard
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.ActivateCardSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.ActivateCardSummary().page
    }
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupActivateCardUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: ActivateCardOperativeData = container.provideParameter()
                operativeData.list = result.cards
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { _ in
                completion(false, (title: nil, message: "deeplink_alert_errorActivateCard"))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: ActivateCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        UseCaseWrapper(
            with: dependencies.useCaseProvider.setupActivateCardUseCase(input: SetupActivateCardUseCaseInput(card: card)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.expirationDate = result.expirationDate
                operativeData.activateCard = result.activateCard
                guard let signature = result.activateCard.signature else {
                    delegate.hideOperativeLoading {
                        delegate.errorOperativeHandler.showGenericError()
                    }
                    return
                }
                container.saveParameter(parameter: signature)
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
        let signatureFilled: SignatureFilled<Signature> = containerParameter()
        let operativeData: ActivateCardOperativeData = containerParameter()
        
        guard let card = operativeData.productSelected, let expirationDate = operativeData.expirationDate else { return }
        let useCase = dependencies.useCaseProvider.confirmActivateCardUseCase(input: ConfirmActivateCardUseCaseInput(signature: signatureFilled.signature, card: card, expirationDate: expirationDate))
        
        UseCaseWrapper(with: useCase,
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: presenter,
                       onSuccess: { [weak self] result in
                        operativeData.errorDesc = result.errorDesc
                        self?.container?.saveParameter(parameter: operativeData)
                        completion(true, nil)
                        },
                       onError: { error in
                        completion(false, error)
                        }
        )
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_activateCard")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        let activateCardData: ActivateCardOperativeData = containerParameter()
        return dependencies.stringLoader.getString(activateCardData.errorDesc ?? "")
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let stringLoader = dependencies.stringLoader
        let operativeData: ActivateCardOperativeData = containerParameter()
        
        guard let card = operativeData.productSelected else { return nil }
        
        let activatedCard = SimpleSummaryData(field: stringLoader.getString("summary_item_activateCard"), value: card.getAliasAndInfo())
        let date = SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? "")
        
        return [activatedCard, date]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        let stringLoader = dependencies.stringLoader
        let operativeData: ActivateCardOperativeData = containerParameter()
        
        switch operativeData.launchedFrom {
        case .pg, .deepLink:
            return stringLoader.getString("generic_button_globalPosition")            
        case .home, .personalArea:
            return stringLoader.getString("generic_button_continue")
        }
    }
}
