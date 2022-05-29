import Foundation

class OrderModelView: TableModelViewItem<OrderViewCell> {
    var isFirstTransaction = false
    var shouldDisplayDate = false
    private let stringLoader: StringLoader

    let productItem: Order
    
    init(product: Order, privateComponent: PresentationComponent) {
        self.productItem = product
        self.stringLoader = privateComponent.stringLoader
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: OrderViewCell) {
        viewCell.isFirstCell = isFirstTransaction
        viewCell.shouldDisplayDate = shouldDisplayDate
        viewCell.ticker = productItem.ticker
        viewCell.sideTitle = stringLoader.getString(productItem.type.orderDescriptionKey)
        viewCell.status = stringLoader.getString(productItem.situation.situationKey)
        viewCell.orderStatus(status: productItem.situation)
        viewCell.cellStatus(productItem.detailRequestStatus)
        viewCell.subtitleLabel.text = productItem.title
        viewCell.dayLabel.text = dependencies.timeManager.toString(date: productItem.date, outputFormat: .d)
        viewCell.monthLabel.text = dependencies.timeManager.toString(date: productItem.date, outputFormat: .MMM)?.uppercased()
    }
    
}

extension OrderModelView: DateProvider {
    
    var transactionDate: Date? {
        return productItem.date
    }
    
}
