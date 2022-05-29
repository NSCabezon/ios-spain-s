import UIKit

class PortfolioProductTitleModelView: TableModelViewItem<PortfolioProductTitleViewCell> {
    var isFirstTransaction = false
    var shouldDisplayDate = false
    let title: LocalizedStylableText
    let diferentCurrency: LocalizedStylableText
    let amount: String?
    let isFirstElement: Bool
    
    init(title: LocalizedStylableText, diferentCurrency: LocalizedStylableText, amount: String?, isFirstElement: Bool, privateComponent: PresentationComponent) {
        self.title = title
        self.diferentCurrency = diferentCurrency
        self.amount = amount
        self.isFirstElement = isFirstElement
        super.init(dependencies: privateComponent)
    }

    override func bind(viewCell: PortfolioProductTitleViewCell) {
        viewCell.title = title
        viewCell.isFirstTitle = isFirstElement
        if let amount = amount {
            viewCell.amount = amount
            viewCell.isAmountTotal = true
        } else {
            viewCell.diferentCurrency = diferentCurrency
            viewCell.isAmountTotal = false
        }
    }
    
    override var height: CGFloat? {
        return isFirstElement ? 44.0 : 56.0
    }
}

extension PortfolioProductTitleModelView: DateProvider {
    
    var transactionDate: Date? {
        return nil
    }
    
}
