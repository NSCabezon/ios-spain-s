//
typealias PayOffConfirmationCardIdentifiers = (alias: String?, amount: String?, image: String?)

class PayOffConfirmationCardViewModel: TableModelViewItem<DepositMoneyIntoCardHeaderConfirmationTableViewCell> {
    
    let alias: String
    let amount: String
    let imageURL: String?
    let imageLoader: ImageLoader?
    let identifiers: PayOffConfirmationCardIdentifiers?
    
    init(alias: String, amount: String, imageURL: String, imageLoader: ImageLoader, identifiers: PayOffConfirmationCardIdentifiers? = nil, privateComponent: PresentationComponent) {
        self.alias = alias
        self.amount = amount
        self.imageURL = imageURL
        self.imageLoader = imageLoader
        self.identifiers = identifiers
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: DepositMoneyIntoCardHeaderConfirmationTableViewCell) {
        viewCell.aliasNameLabel.text = alias.uppercased()
        viewCell.amountLabel.text = amount
        if let identifiers = identifiers { viewCell.setAccessibilityIdentifiers(identifiers: identifiers) }
        imageLoader?.load(relativeUrl: imageURL ?? "", imageView: viewCell.cardImageView, placeholder: "defaultCard")
    }
}
