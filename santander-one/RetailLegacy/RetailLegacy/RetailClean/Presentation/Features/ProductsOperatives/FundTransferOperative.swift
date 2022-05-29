import CoreFoundationLib
import Foundation

class FundTransferOperative: MifidLauncherOperative {
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
        return .fundTransfer
    }
    var mifidState: MifidState = .unknown
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.FundTransferSummary().page
    }
    var screenIdSignature: String? {
        return TrackerPagePrivate.FundTransferSignature().page
    }
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        guard let fundTransferType = fundTransferTransaction.fundTransferType else {
            return nil
        }
        switch fundTransferType {
        case .total:
            let fund: Fund = container.provideParameter()
            guard let amount = fund.getAmount() else {
                return nil
            }
            return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName, TrackerDimensions.operationType: fundTransferType.trackerId]
        case .partialAmount:
            guard let amount = fundTransferTransaction.amount else {
                return nil
            }
            return [TrackerDimensions.amount: amount.getTrackerFormattedValue(), TrackerDimensions.currency: amount.currencyName, TrackerDimensions.operationType: fundTransferType.trackerId]

        case .partialShares:
            guard let shares = fundTransferTransaction.shares else {
                return nil
            }
            return [TrackerDimensions.participations: shares.getTrackerFormattedValue(with: 5), TrackerDimensions.operationType: fundTransferType.trackerId]
        }
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        add(step: factory.createStep() as DestinationFundSelection)
        add(step: factory.createStep() as TransferTypeSelection)
        add(step: factory.createStep() as TransferConfirmation)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let fundTransfer: FundTransfer = container.provideParameter()
        let fund: Fund = container.provideParameter()
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()

        guard let fundTransferType = fundTransferTransaction.fundTransferType else {
            completion(false, nil)
            return
        }

        switch fundTransferType {
        case .total:
            let confirmUseCaseInput = ConfirmTotalFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund, fundTransfer: fundTransfer, signature: signatureFilled.signature)
            let useCase = dependencies.useCaseProvider.confirmTotalFundTransferUseCase(input: confirmUseCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        case .partialAmount:
            guard let amount: Amount = fundTransferTransaction.amount else {
                completion(false, nil)
                return
            }

            let confirmUseCaseInput = ConfirmPartialAmountFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund, fundTransfer: fundTransfer, amount: amount, signature: signatureFilled.signature)
            let useCase = dependencies.useCaseProvider.confirmPartialAmountFundTransferUseCase(input: confirmUseCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        case .partialShares:
            let confirmUseCaseInput = ConfirmPartialSharesFundTransferUseCaseInput(originFund: fund, destinationFund: fundTransferTransaction.destinationFund, fundTransfer: fundTransfer, signature: signatureFilled.signature)
            let useCase = dependencies.useCaseProvider.confirmPartialSharesFundTransferUseCase(input: confirmUseCaseInput)
            UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
                completion(true, nil)
            }, onError: { error in
                completion(false, error)
            })
        }
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_foundTransfer")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let fund: Fund = container.provideParameter()
        let fundDetail: FundDetail = container.provideParameter()
        let fundTransferTransaction: FundTransferTransaction = container.provideParameter()
        let destinationFund: Fund = fundTransferTransaction.destinationFund
        let fundTransfer: FundTransfer = container.provideParameter()
        let account: Account? = container.provideParameterOptional()
        
        let stringLoader = dependencies.stringLoader
        
        guard let fundTransferType = fundTransferTransaction.fundTransferType else {
            return nil
        }
        
        var amountInfo: SimpleSummaryData {
            switch fundTransferType {
            case .total:
                return SimpleSummaryData(field: stringLoader.getString("summary_item_total"), value: fund.getAmountUI())
            case .partialAmount:
                return SimpleSummaryData(field: stringLoader.getString("summary_item_quantity"), value: fundTransferTransaction.amount?.getFormattedAmountUIWith1M() ?? "")
            case .partialShares:
                return SimpleSummaryData(field: stringLoader.getString("summary_item_participations"), value: fundTransferTransaction.shares?.getFormattedValue(5) ?? "")
            }
        }
        
        let origin = SimpleSummaryData(field: stringLoader.getString("summary_item_originFund"), value: fund.getAliasAndInfo())
        let destination = SimpleSummaryData(field: stringLoader.getString("summary_item_destinationFund"), value: destinationFund.getAliasAndInfo())
        let holder = SimpleSummaryData(field: stringLoader.getString("summary_item_holder"), value: fundDetail.getHolder()?.camelCasedString ?? "")
        let description = SimpleSummaryData(field: stringLoader.getString("summary_item_description"), value: fundTransfer.fundTransferDTO.fundDescription ?? "")
        let associatedAccount = SimpleSummaryData(field: stringLoader.getString("summary_item_associatedAccount"), value: account?.getAliasAndInfo() ?? IBAN.create(fromText: fundTransferTransaction.associatedAccount).getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text))
        let lastSubscriptionDate = SimpleSummaryData(field: stringLoader.getString("summary_item_dateTransfer"), value: dependencies.timeManager.toString(date: fundTransferTransaction.valueDate ?? Date(), outputFormat: TimeFormat.d_MMM_yyyy) ?? "")
        
        return [amountInfo, origin, destination, holder, description, associatedAccount, lastSubscriptionDate]
    }

    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct DestinationFundSelection: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.fundOperatives.fundTransferDestinationSelectionPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct TransferTypeSelection: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {        
        return presenterProvider.fundOperatives.fundTransferTypeSelectionPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct TransferConfirmation: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.fundOperatives.fundTransferConfirmation
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

extension FundTransferType {
    var trackerId: String {
        switch self {
        case .total:
            return "total"
        case .partialAmount:
            return "parcial importe"
        case .partialShares:
            return "parcial participaciones"
        }
    }
}
