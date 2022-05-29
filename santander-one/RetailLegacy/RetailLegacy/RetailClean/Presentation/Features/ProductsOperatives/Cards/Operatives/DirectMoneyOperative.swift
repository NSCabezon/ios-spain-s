//

import Foundation
import CoreFoundationLib

class DirectMoneyOperative: Operative {
    let dependencies: PresentationComponent
    
    // MARK: - LifeCycle
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    let isShareable = true
    let needsReloadGP = true
    var steps: [OperativeStep] = []
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.defaultOperativeFinishedNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .directMoney
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.DirectMoneySignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.DirectMoneySummary().page
    }
        
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: DirectMoneyCardOperativeData = container.provideParameter()
        guard let amount = operativeData.amount else { return nil }
        return  [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName]
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getPreSetupDirectMoneyUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                let operativeData: DirectMoneyCardOperativeData = container.provideParameter()
                operativeData.list = result.cardList
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { error in
                guard let errorDesc = error?.getErrorDesc() else {
                    completion(false, nil)
                    return
                }
                completion(false, (title: nil, message: errorDesc))
            }
        )
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: DirectMoneyCardOperativeData = container.provideParameter()
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getSetupDirectMoneyUseCase(input: SetupDirectMoneyUseCaseInput(card: operativeData.card)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: delegate.errorOperativeHandler,
            onSuccess: { result in
                operativeData.directMoney = result.directMoney
                operativeData.cardDetail = result.cardDetail
                operativeData.iban = result.iban
                operativeData.account = result.account
                container.saveParameter(parameter: operativeData)
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
        let directMoneyData: DirectMoneyCardOperativeData = containerParameter()
        guard let amount = directMoneyData.amount, let card = directMoneyData.card else {
            return            
        }
        let input = ConfirmDirectMoneyUseCaseInput(card: card, amount: amount, signature: signatureFilled.signature)
        let usecase = dependencies.useCaseProvider.getConfirmDirectMoneyUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: {
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_directMoney")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let directMoneyData: DirectMoneyCardOperativeData = containerParameter()
        
        var items: [SummaryItemData] = []
        let stringLoader = dependencies.stringLoader
        
        if let amount = directMoneyData.amount {
            let amountItem = SimpleSummaryData(field: stringLoader.getString("summary_item_amount"), value: amount.getFormattedAmountUIWith1M())
            items.append(amountItem)
        }
        
        guard let card = directMoneyData.card, let iban = directMoneyData.iban else {
            return items
        }
        
        let originItem = SimpleSummaryData(field: stringLoader.getString("summary_item_originCard"), value: card.getAliasAndInfo())
        items.append(originItem)
        let accountDescription: String
        
        if let account: Account = directMoneyData.account {
            accountDescription = account.getAliasAndInfo()
        } else {
            accountDescription = iban.getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text)
        }
        let destinationItem = SimpleSummaryData(field: stringLoader.getString("summary_item_destinationAccounts"), value: accountDescription)
        items.append(destinationItem)
        
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy) ?? ""
        let dateItem = SimpleSummaryData(field: stringLoader.getString("summary_item_transactionDate"), value: date)
        items.append(dateItem)
        
        return items
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    // MARK: - Class Methods
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Card.self)
        add(step: factory.createStep() as DirectMoneyOperativeInputOperativeStep)
        add(step: factory.createStep() as DirectMoneyOperativeConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
}

struct DirectMoneyOperativeInputOperativeStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.directMoneyInputPresenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct DirectMoneyOperativeConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.directMoneyConfirmationPresenter
    }
    private let presenterProvider: PresenterProvider

    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
