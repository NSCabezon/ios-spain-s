import Foundation

class FavoriteTransferRecipientStackModel: StackItem<FavoriteTransferRecipientStackView> {
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let country: LocalizedStylableText
    private let currency: LocalizedStylableText
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, country: LocalizedStylableText, currency: LocalizedStylableText, insets: Insets = Insets(left: 10, right: 10, top: 7, bottom: 7)) {
        self.title = title
        self.subtitle = subtitle
        self.currency = currency
        self.country = country
        super.init(insets: insets)
    }
    
    override func bind(view: FavoriteTransferRecipientStackView) {
        view.setTitle(title)
        view.setSubtitle(subtitle)
        view.setCountry(country)
        view.setCurrency(currency)
    }
    
}
