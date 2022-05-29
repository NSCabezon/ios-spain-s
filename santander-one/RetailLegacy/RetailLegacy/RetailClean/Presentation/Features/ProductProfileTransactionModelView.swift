import Foundation

class ProductProfileTransactionModelView: TableModelViewItem<PortfolioProductTransactionViewCell> {
    
    var transaction: PortfolioProductTransaction
    var isFirstTransaction: Bool
    var showsDate: Bool = true
    
    init(_ transaction: PortfolioProductTransaction, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.transaction = transaction
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PortfolioProductTransactionViewCell) {
        viewCell.isFirstTransaction = isFirstTransaction
        viewCell.showsDate = showsDate
        viewCell.month = dependencies.timeManager.toString(date: transaction.operationDate, outputFormat: .MMM)?.uppercased()
        viewCell.day = dependencies.timeManager.toString(date: transaction.operationDate, outputFormat: .d)
        viewCell.concept = transaction.description.camelCasedString
        viewCell.transactionAmount = transaction.amount
    }
}

extension ProductProfileTransactionModelView: DateProvider {
    
    var transactionDate: Date? {
        return transaction.operationDate
    }
    
    var shouldDisplayDate: Bool {
        get {
            return showsDate
        }
        set {
            showsDate = newValue
        }
    }
    
}
