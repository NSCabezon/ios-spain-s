import Foundation
import CoreFoundationLib

class ImpositionsTransactionDetailProfile: BaseTransactionDetailProfile<Any, Any, StringErrorOutput>, TransactionDetailProfile {
        
    var title: String? {
        guard let transaction = transaction as? ImpositionTransaction else { return nil }
        return transaction.description.camelCasedString
    }
    
    var alias: String? {
        guard let product = product as? Imposition, let contract = product.getAlias() else { return  nil }
        return impositionUI(from: contract)
    }
    
    var amount: String? {
        guard let transaction = transaction as? ImpositionTransaction else { return nil }
        return transaction.amount.getFormattedAmountUIWith1M()
    }
    
    var showSeePdf: Bool? {
        return false
    }
    
    var titleLeft: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_operationDate")
    }
    
    var infoLeft: String? {
        return impositionDate()
       
    }
    
    var titleRight: LocalizedStylableText? {
        return dependencies.stringLoader.getString("transaction_label_valueDate")
    }
    
    var infoRight: String? {
        return impositionDate()
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
        return false
    }
    
    var showShare: Bool? {
        return true
    }
    
    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.DepositImpositionsTrasnferDetail().page
    }

    // MARK: -

    override func actions(withProductConfig productConfig: ProductConfig) {
        completionActions?([])
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        return nil
    }
    
    override func useCaseForProductDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        return nil
    }
    
    override func requestTransactionDetail(completion: @escaping ([TransactionLine]?) -> Void) {
        
        var info = [TransactionLine]()
        
        guard let product = product as? Imposition else {
            completion(nil)
            return
        }
        
        let impositionNumber = (dependencies.stringLoader.getString("transaction_label_impositionNumber"), product.subcontract)
        info.append((impositionNumber, nil))
        
        if let deposit = product.deposit {
            let subContract = (dependencies.stringLoader.getString("transaction_label_contractNumber"), deposit.getDetailUI() ?? "")
            info.append((subContract, nil))
            
            let productType = (dependencies.stringLoader.getString("transaction_label_deposit"), deposit.getAliasCamelCase())
            info.append((productType, nil))

        }
        shareableInfo = info
        
        completion(info)
    }
    
    override func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
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
        if let titleLeft = titleLeft?.text, let infoLeft = infoLeft {
            stringToShare.append("\(titleLeft) \(infoLeft)\n")
        }
        
        if let titleRight = titleRight?.text, let infoRight = infoRight {
            stringToShare.append("\(titleRight) \(infoRight)\n")
        }
        
        for line in shareableInfo {
            stringToShare.append("\(line.0.title.text) \(line.0.info)\n")
            if let second = line.1 {
                stringToShare.append("\(second.title.text) \(second.info)\n")
            }
        }

        return stringToShare
    }
    
    private func impositionDate() -> String? {
        guard let transaction = transaction as? ImpositionTransaction else { return nil }
        guard let operationDate = transaction.operationDate else { return nil }
        guard let dateString = dependencies.timeManager.toString(date: operationDate, outputFormat: TimeFormat.d_MMM_yyyy) else {
            return nil
        }
        return dateString
    }
    
    private func impositionUI(from subContract: String) -> String {
        let impositionsTitle = dependencies.stringLoader.getString("toolbar_title_imposition").uppercased()
        let impositionNumber = dependencies.stringLoader.getString("deposits_label_number", [StringPlaceholder(StringPlaceholder.Placeholder.number, subContract)])
        return "\(impositionsTitle.text) \(impositionNumber.text)"
    }
}
