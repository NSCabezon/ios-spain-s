//

import Foundation

class ImpositionsTransactionsViewModel: TableModelViewItem<ImpositionTransactionViewCell> {
    
    var impositionTransaction: ImpositionTransaction
    var isFirstTransaction: Bool
    var showsDate: Bool = true
    
    init(_ impositionTransaction: ImpositionTransaction, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.impositionTransaction = impositionTransaction
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ImpositionTransactionViewCell) {
        viewCell.isFirstTransaction = isFirstTransaction
        viewCell.showsDate = showsDate
        viewCell.month = dependencies.timeManager.toString(date: impositionTransaction.operationDate, outputFormat: .MMM)?.uppercased()
        viewCell.day = dependencies.timeManager.toString(date: impositionTransaction.operationDate, outputFormat: .d)
        viewCell.concept = impositionTransaction.description.camelCasedString
        viewCell.transactionAmount = impositionTransaction.amount
    }
}

extension ImpositionsTransactionsViewModel: DateProvider {
    
    var transactionDate: Date? {
        return impositionTransaction.operationDate
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
