import Foundation

class CardSearchHeaderViewModel: HeaderViewModel<GenericOperativeCardHeaderView>, CardFormatterHelpers {
    
    var card: Card
    private let dependencies: PresentationComponent
    
    init(card: Card, dependencies: PresentationComponent) {
        self.card = card
        self.dependencies = dependencies
    }
    
    override func configureView(_ view: GenericOperativeCardHeaderView) {
        view.titleLabel.set(localizedStylableText: .plain(text: card.getAlias().uppercased()))
        view.subtitleLabel.set(localizedStylableText: getStyledSubNameFor(card, stringLoader: dependencies.stringLoader))
        view.rightInfoLabel.set(localizedStylableText: cardTitle())
        view.amountLabel.set(localizedStylableText: .plain(text: card.getAmountUI()))
        dependencies.imageLoader.load(relativeUrl: card.buildImageRelativeUrl(true), imageView: view.cardImageView, placeholder: "defaultCard")
    }
    
    private func cardTitle() -> LocalizedStylableText {
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
}
