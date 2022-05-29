import UIKit

class FavoriteRecipientWithCurrencyStackModel: StackItem<FavoriteRecipientWithCurrencyStackView> {
    private let title: String
    private let alias: String
    private let country: String
    private let currency: String
    
    init(title: String, alias: String, country: String, currency: String, insets: Insets = Insets(left: 11, right: 10, top: 15, bottom: 4)) {
        self.title = title
        self.alias = alias
        self.country = country
        self.currency = currency
        super.init(insets: insets)
    }
    
    override func bind(view: FavoriteRecipientWithCurrencyStackView) {
        view.setCountry(country, withImageKey: "icnWorldRetail")
        view.setCurrency(currency, withImageKey: "icnBillRetail")
        view.setAlias(alias, withTitle: title)
        view.displayAsField(true)
        view.layoutIfNeeded()
    }
}
