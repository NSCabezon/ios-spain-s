import Foundation

class LiquidationTransactionViewModel: TableModelViewItem<ImpositionLiquidationViewCell> {
    var liquidation: Liquidation
    var isFirstTransaction: Bool
    var showsDate: Bool = false
    
    init(_ liquidation: Liquidation, _ isFirst: Bool, _ privateComponent: PresentationComponent) {
        self.liquidation = liquidation
        self.isFirstTransaction = isFirst
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ImpositionLiquidationViewCell) {
        viewCell.initialDateLabel.set(localizedStylableText: dependencies.stringLoader.getString("deposits_label_start"))
        viewCell.initialDateInfoLabel.text =  dependencies.timeManager.toString(date: liquidation.initialDate, outputFormat: .d_MMM_yyyy) ?? ""
        viewCell.endDateLabel.set(localizedStylableText: dependencies.stringLoader.getString("deposits_label_end"))
        viewCell.endDateInfoLabel.text = dependencies.timeManager.toString(date: liquidation.expirationDate, outputFormat: .d_MMM_yyyy) ?? ""
        viewCell.amountLabel.text = liquidation.liquidationAmount.getFormattedAmountUI(2)
    }
}

extension LiquidationTransactionViewModel: DateProvider {
    var transactionDate: Date? {
        return liquidation.initialDate
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
