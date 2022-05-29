import Foundation

class FavoriteTransferRecipientViewModel: TableModelViewItem<FavoriteTransferRecipientViewCell> {
    private let title: LocalizedStylableText
    private let subtitle: LocalizedStylableText
    private let country: LocalizedStylableText
    private let currency: LocalizedStylableText
    
    init(title: LocalizedStylableText, subtitle: LocalizedStylableText, country: LocalizedStylableText, currency: LocalizedStylableText, dependencies: PresentationComponent) {
        self.title = title
        self.subtitle = subtitle
        self.currency = currency
        self.country = country
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: FavoriteTransferRecipientViewCell) {
        viewCell.setTitle(title)
        viewCell.setSubtitle(subtitle)
        viewCell.setCountry(country)
        viewCell.setCurrency(currency)
    }
    
}
