import Foundation
import CoreFoundationLib

class CardModifyPaymentFormOperative: Operative {
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .changePaymentMethod
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.CreditCardChangePayMethodSummary().page
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as SelectCardModifyPaymentFormStep)
        add(step: factory.createStep() as ModifyPaymentConfirmationStep)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CardModifyPaymentFormOperativeData = container.provideParameter()
        guard let card = operativeData.productSelected else { return }
        let useCase = dependencies.useCaseProvider.setupCardModifyPaymentFormUseCase(input: SetupCardModifyPaymentFormUseCaseInput(card: card))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { response in
            let cardModifyPaymentForm = CardModifyPaymentForm(
                card: card,
                cardDetail: response.cardDetail,
                currentChangePayment: response.changePayment,
                newPaymentMethodStatus: response.changePayment.paymentMethodStatus)
            operativeData.cardModifyPaymentForm = cardModifyPaymentForm
            container.saveParameter(parameter: operativeData)
            container.saveParameter(parameter: response.operativeConfig)
            success()
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
        })
    }
    
    func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: CardModifyPaymentFormOperativeData = container.provideParameter()
        let input = PreSetupCardModifyPaymentFormUseCaseInput(card: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.preSetupCardModifyPaymentFormUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let operativeData: CardModifyPaymentFormOperativeData = container.provideParameter()
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
        return dependencies.stringLoader.getString("summary_label_payMethod")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: CardModifyPaymentFormOperativeData = containerParameter()
        let builder = CardModifyPaymentOperativeSummaryItemDataBuilder(parameter: parameter, dependencies: dependencies)
        builder.addCard()
            .addHolder()
            .addOldPayment()
            .addNewPayment()
            .addDate()
        return builder.build()
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

// MARK: Steps
struct SelectCardModifyPaymentFormStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.selectCardModifyFormPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ModifyPaymentConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.confirmationCardModifyFormPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

// MARK: - SummaryItemBuilder
private class CardModifyPaymentOperativeSummaryItemDataBuilder {
    let parameter: CardModifyPaymentFormOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(parameter: CardModifyPaymentFormOperativeData, dependencies: PresentationComponent) {
        self.parameter = parameter
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addCard() -> CardModifyPaymentOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_card"), value: "\(parameter.cardModifyPaymentForm?.card.getAliasAndInfo() ?? "")", fieldIdentifier: "changeWayToPaySummary_card_field", valueIdentifier: "changeWayToPaySummary_card_value"))
        return self
    }
    
    @discardableResult
    func addHolder() -> CardModifyPaymentOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_holder"), value: "\(parameter.cardModifyPaymentForm?.cardDetail?.holder?.camelCasedString ?? "")", fieldIdentifier: "changeWayToPaySummary_holder_field", valueIdentifier: "changeWayToPaySummary_holder_value"))
        return self
    }
    
    @discardableResult
    func addOldPayment() -> CardModifyPaymentOperativeSummaryItemDataBuilder {
        if let paymentMethodStatus = parameter.cardModifyPaymentForm?.currentChangePayment?.paymentMethodStatus {
            let previousDescription = PaymentMethodDescription(dependencies: dependencies, paymentMethodStatus: paymentMethodStatus, title: Int(parameter.cardModifyPaymentForm?.oldAmount?.value?.doubleValue ?? 0.0), subtitle: Int(parameter.cardModifyPaymentForm?.oldPaymentMethod?.minAmortAmount?.value?.doubleValue ?? 0.0))
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_previousPay"), value: "\(previousDescription.paymentMethodDescription() ?? "")", fieldIdentifier: "changeWayToPaySummary_oldPayment_field", valueIdentifier: "changeWayToPaySummary_oldPayment_value"))
        }
        return self
    }
    
    @discardableResult
    func addNewPayment() -> CardModifyPaymentOperativeSummaryItemDataBuilder {
        if let paymentMethodStatus = parameter.cardModifyPaymentForm?.newPaymentMethodStatus {
            let newDescription = PaymentMethodDescription(dependencies: dependencies, paymentMethodStatus: paymentMethodStatus, title: Int(parameter.cardModifyPaymentForm?.amount?.value?.doubleValue ?? 0.0), subtitle: Int(parameter.cardModifyPaymentForm?.newPaymentMethod?.minAmortAmount?.value?.doubleValue ?? 0.0))
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_newPay"), value: "\(newDescription.paymentMethodDescription() ?? "")", fieldIdentifier: "changeWayToPaySummary_newPayment_field", valueIdentifier: "changeWayToPaySummary_newPayment_value"))
        }
        return self
    }
    
    @discardableResult
    func addDate() -> CardModifyPaymentOperativeSummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.dd_MMM_yyyy) ?? "", fieldIdentifier: "changeWayToPaySummary_date_field", valueIdentifier: "changeWayToPaySummary_card_value"))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
