class SelectableAccountViewModel: TableModelViewItem<SelectableProductViewCell> {
    
    var account: Account
    var baseIdentifier: String?
    
    init(_ account: Account, baseIdentifier: String? = nil,_ privateComponent: PresentationComponent) {
        self.account = account
        self.baseIdentifier = baseIdentifier
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableProductViewCell) {
        viewCell.alias = account.getAlias()?.uppercased()
        viewCell.identifier = account.getIBANPapel()
        viewCell.amount = account.getAmountUI()
        if let identifier = baseIdentifier { viewCell.setAccessibilityIdentifiers(identifier: identifier) }
    }
    
}
