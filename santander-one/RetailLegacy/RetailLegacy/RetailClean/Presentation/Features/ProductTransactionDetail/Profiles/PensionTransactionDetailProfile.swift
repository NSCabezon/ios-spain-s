import Foundation
import CoreFoundationLib
import CoreDomain

class PensionTransactionDetailProfile: BaseTransactionDetailProfile<Any, Any, StringErrorOutput>, TransactionDetailProfile {
    
    var navigator: OperativesNavigatorProtocol
    
    var title: String? {
        guard let transaction = transaction as? PensionTransaction else { return nil }
        return transaction.description.camelCasedString
    }
    
    var alias: String? {
        guard let product = product as? Pension else { return nil }
        return product.getAlias()
    }
    
    var amount: String? {
        guard let transaction = transaction as? PensionTransaction else { return nil }
        return transaction.amount.getFormattedAmountUIWith1M()
    }
    
    var showSeePdf: Bool? {
        return false
    }
    
    var titleLeft: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_operationDate")
    }
    
    var infoLeft: String? {
        guard let transaction = transaction as? PensionTransaction else { return nil }
        guard let operationDate = transaction.operationDate else { return nil }
        guard let dateString = dependencies.timeManager.toString(date: operationDate, outputFormat: TimeFormat.d_MMM_yyyy) else {
            return nil
        }
        return dateString
    }
    
    var titleRight: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_shares")
    }
    
    var infoRight: String? {
        guard let transaction = transaction as? PensionTransaction else { return nil }
        guard let shares = transaction.getSharesCountWith5Decimals() else { return nil }
        return shares
    }
    
    var singleInfoTitle: LocalizedStylableText? {
        return nil
    }
    
    var balance: String? {
        return nil
    }
    
    var showLoading: Bool? {
        return false
    }
    
    var showActions: Bool? {
        return true
    }
    
    var showShare: Bool? {
        return true
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    override init(product: GenericProductProtocol?, transaction: GenericTransactionProtocol, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, transactionDetailManager: ProductLauncherOptionsPresentationDelegate) {
        navigator = dependencies.navigatorProvider.pensionProfileNavigator
        super.init(product: product, transaction: transaction, dependencies: dependencies, errorHandler: errorHandler, transactionDetailManager: transactionDetailManager)
    }

    override func actions(withProductConfig productConfig: ProductConfig) {
        var isAllianz = false
        if let pension = product as? Pension {
            isAllianz = pension.isAllianz(filterWith: productConfig.allianzProducts)
        }
        var actions = [TransactionDetailActionType]()
        if productConfig.enabledPensionOperations == true && !isAllianz {
            addExtraContributionOption(&actions)
            
            addPeriodicContributionOption(&actions)
        }
        addDetailOption(&actions)
        
        completionActions?(actions)
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        return nil
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
        
        return stringToShare
    }
}

extension PensionTransactionDetailProfile {
    
    fileprivate func addExtraContributionOption(_ actions: inout [TransactionDetailActionType]) {
        let extraContributionOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_extraContribution")) { [weak self] in
            guard let pension = self?.product as? Pension, let delegate = self?.transactionDetailManager else { return }
            self?.launchExtraordinaryContribution(pension: pension, delegate: delegate)
        }
        
        actions.append(extraContributionOption)
    }
    
    fileprivate func addPeriodicContributionOption(_ actions: inout [TransactionDetailActionType]) {
        let periodicContributionOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_periodicContribution")) { [weak self] in
            guard let pension = self?.product as? Pension, let strongSelf = self else { return }
            self?.launch(forPension: pension, withDelegate: strongSelf)
        }
        actions.append(periodicContributionOption)
    }
    
    fileprivate func addDetailOption(_ actions: inout [TransactionDetailActionType]) {
        let detailOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_detailPlan")) { [weak self] in
            guard let product = self?.product else { return }
            self?.transactionDetailManager?.goToDetail(product: product, productDetail: self?.productDetail, productHome: .pensions)
        }
        actions.append(detailOption)
    }
    
}

extension PensionTransactionDetailProfile: ProductLauncherPresentationDelegate {
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

extension PensionTransactionDetailProfile: ExtraordinaryContributionLauncher {}

extension PensionTransactionDetailProfile: PeriodicalContributionLauncher {
    var navigatorOperative: OperativesNavigatorProtocol {
         return navigator
    }
}
