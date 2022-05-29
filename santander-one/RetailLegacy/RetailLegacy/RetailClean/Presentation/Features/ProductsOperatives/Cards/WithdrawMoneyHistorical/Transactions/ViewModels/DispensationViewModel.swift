import Foundation

class DispensationViewModel: TableModelViewItem<DispensationViewCell> {
    var isFirstTransaction = false
    var shouldDisplayDate = false
    private let stringLoader: StringLoader
    
    let productItem: Dispensation
    
    init(product: Dispensation, privateComponent: PresentationComponent) {
        self.productItem = product
        self.stringLoader = privateComponent.stringLoader
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: DispensationViewCell) {
        viewCell.isFirstCell = isFirstTransaction
        viewCell.shouldDisplayDate = shouldDisplayDate
        viewCell.title = dependencies.stringLoader.getString("historyWhitdraw_text_repayCashPoint")
        let amount = productItem.amount
        let value = -1 * abs( amount.value ?? Decimal(0) )
        let negativeAmount = Amount.createWith(value: value, amount: amount) ?? Amount.createWith(value: value)
        viewCell.amount = negativeAmount.getFormattedAmountUI()
        viewCell.dispensationStatus(statusText: stringLoader.getString(productItem.status.situationKey), status: productItem.status)
        viewCell.day = dependencies.timeManager.toString(date: productItem.releaseDate, outputFormat: .d)
        viewCell.month = dependencies.timeManager.toString(date: productItem.releaseDate, outputFormat: .MMM)?.uppercased()
    }
}

extension DispensationViewModel: DateProvider {
    
    var transactionDate: Date? {
        return productItem.releaseDate
    }
}
