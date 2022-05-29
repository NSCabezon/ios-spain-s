import Foundation
import CoreFoundationLib
import CoreDomain

class PortfolioProductTransactionDetailProfile: BaseTransactionDetailProfile<GetPortfolioProductTransactionDetailUseCaseInput, GetPortfolioProductTransactionDetailUseCaseOkOutput, GetPortfolioProductTransactionDetailUseCaseErrorOutput>, TransactionDetailProfile {
    var titleLeft: LocalizedStylableText?
    
    var infoLeft: String?
    
    var titleRight: LocalizedStylableText?
    
    var infoRight: String?
    
    var title: String? {
        guard let transaction = transaction as? PortfolioProductTransaction else { return nil }
        return transaction.description.camelCasedString
    }
    var alias: String? {
        guard let product = product as? PortfolioProduct else { return nil }
        return product.getAlias()
    }
    var amount: String? {
        guard let transaction = transaction as? PortfolioProductTransaction else { return nil }
        return transaction.amount.getFormattedAmountUIWith1M()
    }
    
    var showSeePdf: Bool? {
        return false
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
    
    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    override func actions(withProductConfig productConfig: ProductConfig) {
        var actions = [TransactionDetailActionType]()
        
        if let portfolioProduct = product as? PortfolioProduct {
            switch portfolioProduct.section {
            case .investmentFund:
                let investmentOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_detailFound")) { [weak self] in
                    self?.goToDetail()
                }
                actions.append(investmentOption)
            case .plans:
                let plansOption = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_detailPlan")) { [weak self] in
                    self?.goToDetail()
                }
                actions.append(plansOption)
            case .fixedIncome, .variableIncome, .derivative, .insurance:
                let option = TransactionDetailAction(title: dependencies.stringLoader.getString("transaction_buttonOption_detailPlan"), action: nil)
                actions.append(option)
            }
        }
        completionActions?(actions)
    }
    
    func goToDetail() {
        if let product = product {
            transactionDetailManager?.goToDetail(product: product, productDetail: productDetail, productHome: .portfolioProductDetail)
        }
    }
    
    override func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        let input = GetPortfolioProductTransactionDetailUseCaseInput(portfolioProductTransaction: transaction as! PortfolioProductTransaction)
        return dependencies.useCaseProvider.getPortfolioProductTransactionDetailUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func transactionDetailFrom(response: GetPortfolioProductTransactionDetailUseCaseOkOutput) -> GenericTransactionProtocol? {
        return response.portfolioProductTransactionDetail
    }
    
    override func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
        guard let detail = transactionDetail as? PortfolioProductTransactionDetail else { return nil }
        return getPortfolioProductTransaction(withDetail: detail)
    }
    
    private func getPortfolioProductTransaction(withDetail detail: GenericTransactionProtocol) -> [TransactionLine]? {
        guard let portfolioProductTransaction = self.transaction as? PortfolioProductTransaction else { return nil }
        guard let portfolioProductTransactionDetail = detail as? PortfolioProductTransactionDetail else { return nil }
        
        guard let operationDate = portfolioProductTransaction.operationDate else { return nil }
        guard let operationDateString = dependencies.timeManager.toString(date: operationDate, outputFormat: .d_MMM_yyyy) else {
            return nil
        }
        guard let valueDate = portfolioProductTransactionDetail.valueDate else { return nil }
        guard let valueDateString = dependencies.timeManager.toString(date: valueDate, outputFormat: .d_MMM_yyyy) else {
            return nil
        }
        
        let operationDateS = (dependencies.stringLoader.getString("transaction_label_operationDate"),
                             operationDateString)
        let valueDateS = (dependencies.stringLoader.getString("transaction_label_valueDate"),
                         valueDateString)
        let totalShares = (dependencies.stringLoader.getString("productDetail_label_shares"),
                       portfolioProductTransaction.getSharesCountWith5Decimals())
        let expensesAmount = (dependencies.stringLoader.getString("transaction_label_operationExpenses"),
                         getOperationExpensive(withDecimal: portfolioProductTransactionDetail.expensesAmount))
        
        shareableInfo = [(operationDateS, valueDateS), (totalShares, expensesAmount)]
        
        return shareableInfo
    }
    
    private func getOperationExpensive(withDecimal decimalExpense: Amount?) -> String {
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
        
        for line in shareableInfo {
            stringToShare.append("\(line.0.title.text) \(line.0.info)\n")
            if let second = line.1 {
                stringToShare.append("\(second.title.text) \(second.info)\n")
            }
        }
        return stringToShare
    }
}
