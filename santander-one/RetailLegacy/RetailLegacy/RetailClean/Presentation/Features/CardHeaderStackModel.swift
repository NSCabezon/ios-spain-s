import Foundation

class CardHeaderStackModel: StackItem<CardHeaderStackView> {
    // MARK: - Private attributes
    
    private let cardTitle: String
    private let cardDescription: String
    private let titleAmount: LocalizedStylableText
    private let amount: String?
    private let imageURL: String?
    private let imageLoader: ImageLoader
    private let identifier: String?
    
    // MARK: - Public methods
    
    init(cardTitle: String, cardDescription: String, titleAmount: LocalizedStylableText, amount: String?, imageURL: String?, imageLoader: ImageLoader, identifier: String? = nil, insets: Insets = Insets(left: 14, right: 20, top: 20, bottom: 0)) {
        self.cardTitle = cardTitle
        self.cardDescription = cardDescription
        self.amount = amount
        self.titleAmount = titleAmount
        self.imageURL = imageURL
        self.imageLoader = imageLoader
        self.identifier = identifier
        super.init(insets: insets)
    }
    
    override func bind(view: CardHeaderStackView) {
        view.titleLabel.text = cardTitle.uppercased()
        view.subtitleLabel.text = cardDescription
        view.rightInfoLabel.set(localizedStylableText: titleAmount)
        view.amountLabel.isHidden = amount?.isEmpty == true
        view.rightInfoLabel.isHidden = amount?.isEmpty == true
        view.amountLabel.text = amount
        if let imageURL = imageURL {
            imageLoader.load(relativeUrl: imageURL, imageView: view.cardImageView, placeholder: "defaultCard")
        }
        if let identifier = identifier { view.setAccessibilityIdentifiers(identifier: identifier) }
    }
}
