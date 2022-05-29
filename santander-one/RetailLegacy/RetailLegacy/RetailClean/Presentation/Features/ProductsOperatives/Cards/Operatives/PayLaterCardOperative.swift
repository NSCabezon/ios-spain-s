import Foundation
import CoreFoundationLib

class PayLaterCardOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .payLater
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.PayLaterSummary().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: PayLaterCardOperativeData = container.provideParameter()
        guard let amount = operativeData.payLaterCard?.amountToDefer else { return nil }
        return  [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
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
        
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as InputDataPayLaterCard)
        add(step: factory.createStep() as ConfirmationPayLaterCard)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: PayLaterCardOperativeData = container.provideParameter()
        let input = SetupPayLaterCardUseCaseInput(card: operativeData.productSelected)
        UseCaseWrapper(with: dependencies.useCaseProvider.setupPayLaterCardUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let payLaterCard = PayLaterCard(
                originCard: result.card,
                cardDetail: result.cardDetail,
                amountPercent: result.percentageAmount,
                payLater: result.payLater)
            operativeData.payLaterCard = payLaterCard
            container.saveParameter(parameter: operativeData)
            container.saveParameter(parameter: result.operativeConfig)
            success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: PayLaterCardOperativeData = container.provideParameter()
        let input = PreSetupPayLaterCardUseCaseInput(card: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.preSetupPayLaterCardUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let operativeData: PayLaterCardOperativeData = container.provideParameter()
            operativeData.updatePre(cards: result.cards)
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
        return dependencies.stringLoader.getString("summary_title_postponeReceipt")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let stringLoader = dependencies.stringLoader
        let operativeData: PayLaterCardOperativeData = containerParameter()
        guard
            let payLaterCard = operativeData.payLaterCard,
            let amountToDefer = payLaterCard.amountToDefer,
            let amountToPayLater = payLaterCard.amountToPayLater else { return nil }
        
        let card: Card = payLaterCard.originCard
        
        let cardSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_card"), value: card.getAliasAndInfo())
        let amountToDeferSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_payAmount"), value: amountToDefer.getAbsFormattedAmountUI())
        let amountToPayLaterSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_postponeAmount"), value: amountToPayLater.getAbsFormattedAmountUI())
        let dateSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_operationDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        
        return [cardSummary, amountToDeferSummary, amountToPayLaterSummary, dateSummary]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct InputDataPayLaterCard: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.inputDataPayLaterCardPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ConfirmationPayLaterCard: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.confirmationPayLaterCardPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
