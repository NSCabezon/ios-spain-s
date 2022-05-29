import Foundation

class PayOffHeaderAmountViewModel: TableModelViewItem<ConfirmationItemsListHeader> {
    private let title: String?
    private let titleIdentifier: String?
    
    init(_ title: String, identifier: String? = nil, _ privateComponent: PresentationComponent) {
        self.title = title
        self.titleIdentifier = identifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ConfirmationItemsListHeader) {
        viewCell.titleText = title
        if let identifier = titleIdentifier { viewCell.setAccessiblityIdentifiers(identifier: identifier) }
        viewCell.separator.isHidden = true
    }
}
