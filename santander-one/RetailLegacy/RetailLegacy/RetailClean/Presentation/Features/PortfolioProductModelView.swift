import Foundation

class PortfolioProductModelView: TableModelViewItem<PortfolioProductViewCell> {
    var isFirstTransaction = false
    var shouldDisplayDate = false
    let productItem: PortfolioProduct
    
    init(product: PortfolioProduct, privateComponent: PresentationComponent) {
        self.productItem = product
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: PortfolioProductViewCell) {
        viewCell.amount = productItem.amount
        viewCell.title = productItem.getAliasCamelCase()
        viewCell.subtitle = productItem.subtitle
        viewCell.tapable = productItem.isActionAsociated
    }

}

extension PortfolioProductModelView: DateProvider {

    var transactionDate: Date? {
        return nil
    }
    
}
