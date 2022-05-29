import Foundation
import CoreFoundationLib
import CoreDomain

class FundTransactionDetailProfile: BaseTransactionDetailProfile<GetFundTransactionDetailUseCaseInput, GetFundTransactionDetailUseCaseOkOutput, GetFundTransactionDetailUseCaseErrorOutput>, FundTransactionProfileProtocol {
    var isShowStatus: Bool?
    var status: LocalizedStylableText?
    var navigator: OperativesNavigatorProtocol
    
    override var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().fundsHome
    }
    
    private var presenterOffers: [PullOfferLocation: Offer] = [:]

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.FundsDetailTransaction().page
    }

    // MARK: -

    override init(product: GenericProductProtocol?, transaction: GenericTransactionProtocol, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, transactionDetailManager: ProductLauncherOptionsPresentationDelegate) {
        navigator = dependencies.navigatorProvider.fundProfileNavigator
        super.init(product: product, transaction: transaction, dependencies: dependencies, errorHandler: errorHandler, transactionDetailManager: transactionDetailManager)
        getLocations()
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
        
    func goToDetail() {
        guard let product = product else { return }
        transactionDetailManager?.goToDetail(product: product, productDetail: productDetail, productHome: .funds)
    }
    
    var title: String? {
        guard let transaction = transaction as? FundTransaction else { return nil }
        return transaction.description.camelCasedString
    }
    var alias: String? {
        guard let product = product as? Fund else { return nil }
        return product.getAlias()
    }
    var amount: String? {
        guard let transaction = transaction as? FundTransaction else { return nil }
        return transaction.amount.getFormattedAmountUIWith1M()
    }
    var showSeePdf: Bool? {
        return false
    }
    var titleLeft: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_operationDate")
    }
    
    var infoLeft: String? {
        guard let transaction = transaction as? FundTransaction else { return nil }
        guard let operationDate = transaction.operationDate else { return nil }
        guard let dateString = dependencies.timeManager.toString(date: operationDate, outputFormat: .d_MMM_yyyy) else {
            return nil
        }
        return dateString
    }
    
    var titleRight: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_valueDate")
    }
    
    var infoRight: String? {
        guard let transaction = transaction as? FundTransaction else { return nil }
        guard let valueDate = transaction.valueDate else { return nil }
        guard let dateString = dependencies.timeManager.toString(date: valueDate, outputFormat: .d_MMM_yyyy) else {
            return nil
        }
        return dateString
    }
    
    var singleInfoTitle: LocalizedStylableText? {
        return nil
    }
    
    var balance: String? {
        return nil
    }
    
    var showLoading: Bool? {
        return true
    }
    
    var showActions: Bool? {
        return true
    }
    
    var showShare: Bool? {
        return true
    }
    
    override func actions(withProductConfig productConfig: ProductConfig) {
        var actions = [TransactionDetailActionType]()
        var isAllianz = false
        if let fund = product as? Fund {
            isAllianz = fund.isAllianz
        }
        let isBySubscriptionUserConditions = productConfig.fundOperationsSubcriptionNativeMode == true && (!isAllianz && (productConfig.isPB == false || productConfig.isDemo == true))
        let isByTransferUserConditions = productConfig.fundOperationsTransferNativeMode == true && (!isAllianz && (productConfig.isPB == false || productConfig.isDemo == true))
        let isBySubcriptionNativeMode = productConfig.fundOperationsSubcriptionNativeMode != true && presenterOffers[.FONDO_SUSCRIPCION] != nil
        let isByTransferNativeMode = productConfig.fundOperationsTransferNativeMode != true && presenterOffers[.FONDO_TRASPASO] != nil
        
        if isBySubcriptionNativeMode || isBySubscriptionUserConditions {
            addSubscriptionOption(productConfig, &actions)
        }        
        if isByTransferNativeMode || isByTransferUserConditions {
            addTransferOption(productConfig, &actions)
        }
        addDetailOption(&actions)
        completionActions?(actions)
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        let input = GetFundTransactionDetailUseCaseInput(fund: product as! Fund, fundTransaction: transaction as! FundTransaction)
        return dependencies.useCaseProvider.getFundTransactionDetailUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func transactionDetailFrom(response: GetFundTransactionDetailUseCaseOkOutput) -> GenericTransactionProtocol? {
        return response.fundTransactionDetail
    }
    
    override func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
        guard let detail = transactionDetail as? FundTransactionDetail else { return nil }
        return getTransaction(withDetail: detail)
    }
    
    func getTransaction(withDetail transaction: FundTransactionDetail) -> [TransactionLine] {
        var info = [TransactionLine]()
        
        if let transactionDTO = self.transaction as? FundTransaction {
            let shareValues = (dependencies.stringLoader.getString("transaction_label_shares"), transactionDTO.getSharesCountWith5Decimals())
            
            let expenses = (dependencies.stringLoader.getString("transaction_label_operationExpenses"),
                            getOperationExpensive(withDecimal: transaction.operationExpenses))
            info.append((shareValues, expenses))
        }

        if let associatedAccount = transaction.linkedAccount {
            info.append(((dependencies.stringLoader.getString("transaction_label_associatedAccount"), associatedAccount), nil))
        }
        
        isShowStatus = true
        if let statusKey = transaction.status {
            let statusValue = dependencies.stringLoader.getString(statusKey).text
            status = dependencies.stringLoader.getString("transaction_label_status", [StringPlaceholder(StringPlaceholder.Placeholder.value, statusValue)])
        }
        shareableInfo = info
        
        return shareableInfo
    }
    
    func getOperationExpensive(withDecimal decimalExpense: Amount?) -> String {
        guard let expense = decimalExpense else { return "" }
        return expense.getFormattedAmountUI(2)
    }
    
    func stringToShare() -> String? {
        var stringToShare = ""
        if let title = title {
            stringToShare.append("\(title)\n")
        }
        if let amount = amount {
            let titleAmount = dependencies.stringLoader.getString("summary_item_quantity").text
            stringToShare.append("\(titleAmount) \(amount)\n")
        }
        if let titleLeft = titleLeft, let infoLeft = infoLeft {
            stringToShare.append("\(titleLeft.text) \(infoLeft)\n")
        }
        
        if let titleRight = titleRight, let infoRight = infoRight {
            stringToShare.append("\(titleRight.text) \(infoRight)\n")
        }
        
        for line in shareableInfo {
            stringToShare.append("\(line.0.title.text) \(line.0.info)\n")
            if let second = line.1 {
                stringToShare.append("\(second.title.text) \(second.info)\n")
            }
        }
        if let status = status {
            stringToShare.append("\(dependencies.stringLoader.getString("transaction_label_status")) \(status)\n")
        }
        return stringToShare
    }
}

extension FundTransactionDetailProfile {
    
    fileprivate func addSubscriptionOption(_ productConfig: ProductConfig, _ actions: inout [TransactionDetailActionType]) {
        let subscriptionOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_newSubscription")) { [weak self] in
            if productConfig.fundOperationsSubcriptionNativeMode == false {
                //TODO: Pendiente
                return
            } else {
                guard let delegate = self?.transactionDetailManager else {
                    return
                }
                self?.showFundSubscription(fund: self?.product as? Fund, delegate: delegate)
            }
        }
        
        actions.append(subscriptionOption)
    }
    
    fileprivate func addTransferOption(_ productConfig: ProductConfig, _ actions: inout [TransactionDetailActionType]) {
        let transferOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_transferFounds")) { [weak self] in
            if productConfig.fundOperationsTransferNativeMode == false {
                //TODO: Pendiente
                return
            } else {
                guard let fund = self?.product as? Fund, let strongSelf = self else { return }
                self?.launchTransfer(forFund: fund, withProductList: nil, withDelegate: strongSelf)
            }
        }
        
        actions.append(transferOption)
    }
    
    fileprivate func addDetailOption(_ actions: inout [TransactionDetailActionType]) {
        let detailOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_detailFound")) { [weak self] in
            self?.goToDetail()
        }
        
        actions.append(detailOption)
    }
    
}

extension FundTransactionDetailProfile: ProductLauncherPresentationDelegate {
    func showAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        transactionDetailManager?.showAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
    
    func startLoading() {
        transactionDetailManager?.startLoading()
    }
    
    func endLoading(completion: (() -> Void)?) {
        transactionDetailManager?.endLoading(completion: completion)
    }
    
    func showAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        transactionDetailManager?.showAlert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel)
    }
}

extension FundTransactionDetailProfile: FundOperativeLauncher, FundOperativeDeepLinkLauncher {}

extension FundTransactionDetailProfile: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
}
