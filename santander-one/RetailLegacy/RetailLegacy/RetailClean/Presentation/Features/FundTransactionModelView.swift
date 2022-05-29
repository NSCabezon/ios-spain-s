import Foundation

class FundTransactionModelView: TableModelViewItem<FundViewCell> {
    
    var fundTransaction: FundTransaction
    var isFirstTransaction: Bool
    var showsDate: Bool = true
    
    init(_ fundTransaction: FundTransaction, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.fundTransaction = fundTransaction
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: FundViewCell) {
        viewCell.isFirstTransaction = isFirstTransaction
        viewCell.showsDate = showsDate
        viewCell.month = dependencies.timeManager.toString(date: fundTransaction.operationDate, outputFormat: .MMM)?.uppercased()
        viewCell.day = dependencies.timeManager.toString(date: fundTransaction.operationDate, outputFormat: .d)
        viewCell.concept = fundTransaction.description.camelCasedString
        viewCell.transactionAmount = fundTransaction.amount
    }
}

extension FundTransactionModelView: DateProvider {

    var transactionDate: Date? {
        return fundTransaction.operationDate
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
