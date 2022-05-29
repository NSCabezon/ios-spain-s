import UIKit

class TransactionMoreModelView: TableModelViewItem<TransactionMoreViewCell> {
    var shouldDisplayDate: Bool = false
    var isFirstTransaction: Bool = false
    override var height: CGFloat? {
        return 59
    }
    private let actionMore: (() -> Void)?
    private let date: Date
    
    init(actionMore: (() -> Void)?, date: Date, privateComponent: PresentationComponent) {
        self.actionMore = actionMore
        self.date = date
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: TransactionMoreViewCell) {
        viewCell.set(title: dependencies.stringLoader.getString("product_button_seeMore"))
        viewCell.delegate = self
    }
}

extension TransactionMoreModelView: TransactionMoreViewCellDelegate {
    func transactionMoreViewCellDidTouched() {
        actionMore?()
    }
}

extension TransactionMoreModelView: DateProvider {
    var transactionDate: Date? {
        return date
    }
}
