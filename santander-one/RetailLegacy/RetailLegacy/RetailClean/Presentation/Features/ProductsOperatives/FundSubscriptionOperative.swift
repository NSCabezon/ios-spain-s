import CoreFoundationLib
import Foundation

class FundSubscriptionOperative: MifidLauncherOperative {
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = true
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toInvestmentFundsHomeNavigator
    }
    var opinatorPage: OpinatorPage? {
        return .fundSubscription
    }
    var mifidState: MifidState = .unknown
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.FundSubscriptionSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.FundSubscriptionSignature().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction else {
            return nil
        }
        let type = fundSubscriptionTransaction.fundSubscriptionType
        switch type {
        case .amount:
            guard let amount = operativeData.amount else {
                return nil
            }
            return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName, TrackerDimensions.operationType: type.trackerId]
        
        case .participation:
            guard let shares = operativeData.shares else {
                return nil
            }
            return [TrackerDimensions.participations: shares.getTrackerFormattedValue(with: 5), TrackerDimensions.operationType: type.trackerId]
        }
    }
    
    // MARK: -
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        addProductSelectionStep(of: Fund.self)
        add(step: factory.createStep() as SubscriptionToFund)
        add(step: factory.createStep() as FundSubscriptionConfirmationStep)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected else {
            return
        }
        let useCase = dependencies.useCaseProvider.setupFundSubscriptionUseCase(input: SetupFundSubscriptionUseCaseInput(fund: fund))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            let operativeData: FundSubscriptionOperativeData = container.provideParameter()
            container.saveParameter(parameter: result.operativeConfig)
            operativeData.update(fundDetail: result.fundDetail, account: result.account)
            container.saveParameter(parameter: operativeData)
            success()
        }, onError: { _ in
            delegate.hideOperativeLoading {
                delegate.showOperativeAlertError(keyTitle: nil, keyDesc: "generic_alert_notAvailableTemporarilyOperation", completion: nil)
            }
        })
    }
    
   func performPreSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, completion: @escaping (Bool, ErrorOperativePreSetup?) -> Void) {
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        let input = PreSetupFundSubscriptionUseCaseInput(fund: operativeData.productSelected)
        let usecase = dependencies.useCaseProvider.preSetupFundSubscriptionUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: {result in
            let operativeData: FundSubscriptionOperativeData = container.provideParameter()
            operativeData.updatePre(funds: result.funds)
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
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            completion(false, nil)
            return
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction, let fundSubscription = operativeData.fundSubscription, let fund = operativeData.productSelected else {
            completion(false, nil)
            return
        }
        let filledSignature: SignatureFilled<Signature> = container.provideParameter()
        switch fundSubscriptionTransaction.fundSubscriptionType {
        case .amount:
            guard let amount = operativeData.amount else {
                completion(false, nil)
                return
            }
            let confirmUseCaseInput = ConfirmFundSubscriptionAmountUseCaseInput(fund: fund, amount: amount, fundSubscription: fundSubscription, signature: filledSignature.signature)
            let useCase = dependencies.useCaseProvider.confirmFundSubscriptionAmountUseCase(input: confirmUseCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { response in
                let operativeData: FundSubscriptionOperativeData = container.provideParameter()
                operativeData.fundSubscriptionConfirm = response.fundSubscriptionConfirm
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        case .participation:
            guard let shares = operativeData.shares else {
                completion(false, nil)
                return
            }
            let confirmUseCaseInput = ConfirmFundSubscriptionSharesUseCaseInput(fund: fund, sharesNumber: shares, fundSubscription: fundSubscription, signature: filledSignature.signature)
            let useCase = dependencies.useCaseProvider.confirmFundSubscriptionSharesUseCase(input: confirmUseCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { response in
                let operativeData: FundSubscriptionOperativeData = container.provideParameter()
                operativeData.fundSubscriptionConfirm = response.fundSubscriptionConfirm
                container.saveParameter(parameter: operativeData)
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        }
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_foundSubscription")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let operativeData: FundSubscriptionOperativeData = container.provideParameter()
        guard let fund = operativeData.productSelected, let fundDetail = operativeData.fundDetail, let fundSubscriptionTransaction = operativeData.fundSubscriptionTransaction, let fundSubscriptionConfirm = operativeData.fundSubscriptionConfirm, let fundSubscription = operativeData.fundSubscription else {
            return nil
        }
        let account = operativeData.account
        
        let stringLoader = dependencies.stringLoader
        
        let fundInfo = SimpleSummaryData(field: stringLoader.getString("summary_item_found"), value: fund.getAliasAndInfo())
        
        let amount: SimpleSummaryData
        
        switch fundSubscriptionTransaction.fundSubscriptionType {
        case .amount:
            amount = SimpleSummaryData(field: stringLoader.getString("summary_item_quantity"), value: fundSubscriptionTransaction.amount?.getFormattedAmountUI() ?? "")
        case .participation:
            amount = SimpleSummaryData(field: stringLoader.getString("summary_item_participations"), value: fundSubscriptionTransaction.shares?.getFormattedValue(5) ?? "")
        }
        
        let holder = SimpleSummaryData(field: stringLoader.getString("summary_item_holder"), value: fundDetail.getHolder()?.capitalized ?? "")
        let description = SimpleSummaryData(field: stringLoader.getString("summary_item_description"), value: (fund as? FundDetail)?.getDescription() ?? "")
        let associatedAccount = SimpleSummaryData(field: stringLoader.getString("summary_item_associatedAccount"), value: account?.getAliasAndInfo() ?? IBAN.create(fromText: fundSubscriptionTransaction.associatedAccount).getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text))
        
        let placeHolder = StringPlaceholder(StringPlaceholder.Placeholder.date, dependencies.timeManager.toString(date: fundSubscription.fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueDate, outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        let settlementAmount = Amount.createFromDTO(fundSubscription.fundSubscriptionDTO.fundSubscriptionResponseData?.settlementValueAmount)
        let lastLiquidatedValue = SimpleSummaryData(field: stringLoader.getString("summary_item_lastedLiquidationDate", [placeHolder]), value: settlementAmount.getFormattedAmountUIWith1M())
        let lastSubscriptionDate = SimpleSummaryData(field: stringLoader.getString("summary_item_dateSubscription"), value: dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        let lastChargeDate = SimpleSummaryData(field: stringLoader.getString("summary_item_date"), value: dependencies.timeManager.toString(date: fundSubscriptionConfirm.fundSubscriptionConfirmDTO.accountChargeDate, outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        let lastRequestDate = SimpleSummaryData(field: stringLoader.getString("summary_item_dateSuolicitud"), value: dependencies.timeManager.toString(date: fundSubscriptionConfirm.fundSubscriptionConfirmDTO.applyDate, outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        
        return [fundInfo, amount, holder, description, associatedAccount, lastLiquidatedValue, lastSubscriptionDate, lastChargeDate, lastRequestDate]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("foundSubscription_text_infoSummary")
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct SubscriptionToFund: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.fundOperatives.fundSubscriptionPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct FundSubscriptionConfirmationStep: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.fundOperatives.fundSubscriptionConfirmationPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

extension FundSubscriptionType {
    var trackerId: String {
        switch self {
        case .amount:
            return "importe"
        case .participation:
            return "participaciones"
        }
    }
}
