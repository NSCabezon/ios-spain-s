enum ConfirmationTableViewHeaderType {
    case first
    case alone
    case last
    case firstWithSeparator
}

class ConfirmationTableViewHeaderModel: TableModelViewItem<ConfirmationItemsListHeader> {
    
    private var title: String?
    private var descriptionText: String?
    private var type: ConfirmationTableViewHeaderType
    private var suffixIdentifier: String?
    
    init(_ title: String, description: String? = nil, type: ConfirmationTableViewHeaderType = .first, suffixIdentifier: String? = nil, _ privateComponent: PresentationComponent) {
        self.title = title
        self.descriptionText = description
        self.type = type
        self.suffixIdentifier = suffixIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: ConfirmationItemsListHeader) {
        viewCell.titleText = title
        viewCell.descriptionText = descriptionText
        viewCell.type = type
        if let suffixIdentifier = suffixIdentifier {
            viewCell.setAccessiblityIdentifiers(identifier: suffixIdentifier)
            
        }
    }
}
