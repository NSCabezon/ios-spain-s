import Foundation
import CoreFoundationLib

final class PayOffOperative: Operative {
    let dependencies: PresentationComponent
    
    // MARK: - LifeCycle
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    var isShareable = true
    var needsReloadGP = true
    var steps: [OperativeStep] = []
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toCardsHomeNavigator
    }
    
    var opinatorPage: OpinatorPage? {
        return .payOff
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.PayOffSummary().page
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.PayOffSignature().page
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else { return nil }
        let operativeData: PayOffCardOperativeData = container.provideParameter()
        guard let amount = operativeData.amount else { return nil }
        return  ["importe": amount.getTrackerFormattedValue(), "divisa": amount.currencyName]
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else { return }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as PayOffSetupOperativeStep)
        add(step: factory.createStep() as PayOffConfirmationOperativeStep)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: PayOffCardOperativeData = container.provideParameter()
        let input = PreSetupPayOffCardUseCaseInput(card: operativeData.productSelected)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.preSetupPayOffCardUseCase(input: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.list = result.cards
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
        }, onError: { _ in
            completion(false, (title: nil, message: "deeplink_alert_errorDepositCard"))
        }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: PayOffCardOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else {
            delegate.showOperativeAlertError(keyTitle: nil, keyDesc: nil, completion: nil)
            return
        }
        let useCase = dependencies.useCaseProvider.setupPayOffCardUseCase(input: SetupPayOffCardUseCaseInput(card: card))
        UseCaseWrapper(with: useCase,
                       useCaseHandler: dependencies.useCaseHandler,
                       errorHandler: delegate.errorOperativeHandler,
                       onSuccess: { response in
                        container.saveParameter(parameter: response.operativeConfig)
                        operativeData.cardDetail = response.cardDetail
                        operativeData.payOffAccount = response.account
                        success()
        }, onError: { error in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else { return }
        let operativeData: PayOffCardOperativeData = container.provideParameter()
        guard
            let card = operativeData.productSelected,
            let cardDetail = operativeData.cardDetail,
            let amount = operativeData.amount
            else {
                completion(false, nil)
                return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let input = ConfirmPayOffUseCaseInput(card: card,
                                              cardDetail: cardDetail,
                                              amount: amount,
                                              signatureWithToken: signatureFilled.signature)
        let useCase = dependencies.useCaseProvider.confirmPayOffUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_successCardEntry")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else { return nil }
        let stringLoader = dependencies.stringLoader
        let operativeData: PayOffCardOperativeData = container.provideParameter()
        guard
            let card = operativeData.productSelected,
            let cardDetail = operativeData.cardDetail,
            let amount = operativeData.amount
            else { return nil }
        let contract = cardDetail.contract
        let accountSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_originAccount"), value: operativeData.payOffAccount?.getAliasAndInfo() ?? contract.getAliasAndInfo(withCustomAlias: dependencies.stringLoader.getString("productDetail_label_associatedAccount").text), fieldIdentifier: "summary_label_accountField", valueIdentifier: "summary_label_accountValue")
        let cardToPayOffSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_distinationCard"), value: card.getAliasAndInfo(), fieldIdentifier: "summary_label_cardField", valueIdentifier: "summary_label_cardValue")
        let dateSummary = SimpleSummaryData(field: stringLoader.getString("stocksDetail_text_dateTable"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "", fieldIdentifier: "summary_label_dateField", valueIdentifier: "summary_label_dateValue")
        let amountSummary = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getFormattedValue(), fieldIdentifier: "summary_label_amountField", valueIdentifier: "summary_label_amountValue")
        return [accountSummary, cardToPayOffSummary, dateSummary, amountSummary]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
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

struct PayOffSetupOperativeStep: OperativeStep {
    private let presenterProvider: PresenterProvider
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.payOffSetupPresenter
    }
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct PayOffConfirmationOperativeStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.payOffResumePresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

class PayOffCardOperativeData: ProductSelection<Card> {
    var cardDetail: CardDetail?
    var payOffAccount: Account?
    var amount: Amount?
    
    init(cards: [Card], card: Card?) {
        super.init(list: cards, productSelected: card, titleKey: "toolbar_title_depositCard", subTitleKey: "deeplink_label_selectCard")
    }
}
