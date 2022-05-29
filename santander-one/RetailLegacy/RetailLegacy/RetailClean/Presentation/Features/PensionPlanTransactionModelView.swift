import Foundation

class PensionPlanTransactionModelView: TableModelViewItem<PensionPlanViewCell> {
    
    var pensionTransaction: PensionTransaction
    var isFirstTransaction: Bool
    var showsDate: Bool = true
    
    init(_ pensionTransaction: PensionTransaction, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.pensionTransaction = pensionTransaction
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PensionPlanViewCell) {
        viewCell.isFirstTransaction = isFirstTransaction
        viewCell.showsDate = showsDate
        viewCell.month = dependencies.timeManager.toString(date: pensionTransaction.operationDate, outputFormat: .MMM)?.uppercased()
        viewCell.day = dependencies.timeManager.toString(date: pensionTransaction.operationDate, outputFormat: .d)
        viewCell.concept = pensionTransaction.description.camelCasedString
        viewCell.transactionAmount = pensionTransaction.amount
    }
    
}

extension PensionPlanTransactionModelView: DateProvider {
    
    var transactionDate: Date? {
        return pensionTransaction.operationDate
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
