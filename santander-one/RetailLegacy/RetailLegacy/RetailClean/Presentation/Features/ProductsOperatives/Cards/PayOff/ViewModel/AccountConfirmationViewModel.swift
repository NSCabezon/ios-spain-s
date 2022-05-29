typealias AccountConfirmationIdentifiers = (name: String?, identifier: String, amount: String?, amountInfo: String?)

class AccountConfirmationViewModel: TableModelViewItem<GenericConfirmationTableViewCell> {
    private let accountName: String
    private let ibanNumber: String?
    private let amount: String?
    private let identifiers: AccountConfirmationIdentifiers?
    
    init(accountName: String, ibanNumber: String?, amount: String?, identifiers: AccountConfirmationIdentifiers? = nil, privateComponent: PresentationComponent) {
        self.accountName = accountName
        self.ibanNumber = ibanNumber
        self.amount = amount
        self.identifiers = identifiers
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: GenericConfirmationTableViewCell) {
        viewCell.name = accountName.uppercased()
        viewCell.amount = amount ?? ""
        viewCell.identifier = ibanNumber ?? ""
        viewCell.amountInfo = nil
        if let identifiers = identifiers { viewCell.setAccessibilityIdentifiers(identifiers: identifiers) }
    }
}
