import UIKit

class TransactionMoreEmptyModelView: TableModelViewItem<TransactionMoreEmptyViewCell> {
    var shouldDisplayDate: Bool = false
    var isFirstTransaction: Bool = false
    override var height: CGFloat? {
        return assignedHeight
    }
    var assignedHeight: CGFloat?
    private let actionMore: (() -> Void)?
    private let date: Date
    
    init(actionMore: (() -> Void)?, date: Date, privateComponent: PresentationComponent) {
        self.actionMore = actionMore
        self.date = date
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: TransactionMoreEmptyViewCell) {
        viewCell.set(title: dependencies.stringLoader.getString("product_button_seeMore"))
        viewCell.set(info: dependencies.stringLoader.getString("product_label_emptyListSCA"))
        viewCell.delegate = self
    }
}

extension TransactionMoreEmptyModelView: TransactionMoreViewCellDelegate {
    func transactionMoreViewCellDidTouched() {
        actionMore?()
    }
}

extension TransactionMoreEmptyModelView: DateProvider {
    var transactionDate: Date? {
        return date
    }
}
