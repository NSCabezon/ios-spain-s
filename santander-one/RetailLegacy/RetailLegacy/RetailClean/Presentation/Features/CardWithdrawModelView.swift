import UIKit

class CardWithdrawModelView: TableModelViewItem<SelectableCardViewCell>, CardFormatterHelpers {
    
    var card: Card
    private let showAvailableMoney: Bool
    
    init(_ card: Card, _ showAvailableMoney: Bool = true, _ privateComponent: PresentationComponent) {
        self.card = card
        self.showAvailableMoney = showAvailableMoney
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: SelectableCardViewCell) {
        viewCell.name = card.getAliasUpperCase()
        viewCell.subname = getStyledSubNameFor(card, stringLoader: dependencies.stringLoader).text
        if showAvailableMoney {
            viewCell.quantity = card.getAmountUI()
            viewCell.quantityTitle = dependencies.stringLoader.getString(card.isPrepaidCard ?  "pg_label_balanceDots" : "pg_label_outstandingBalanceDots").text
        } else {
            viewCell.hideAvailableMoney()
        }
        dependencies.imageLoader.load(relativeUrl: card.buildImageRelativeUrl(true), imageView: viewCell.cardItemImageView, placeholder: "defaultCard")
    }
}
