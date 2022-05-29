protocol CardActivator: class {

    /// Delegate responsible to activate card
    ///
    /// - Parameter card: card to activate
    func activate(card: Card)
}

class CardModelView<P: Card>: ProductBaseModelView<P, ItemCardViewCell>, CardFormatterHelpers {
    private let cardActivator: CardActivator

    init(_ product: P, _ privateComponent: PresentationComponent, _ cardActivator: CardActivator) {
        self.cardActivator = cardActivator
        super.init(product, privateComponent)
        home = .cards
    }
    
    override var movements: Int? {
        return product.movements
    }

    override func getName() -> String {
        return product.getAliasCamelCase()
    }
    
    override func getSubName() -> String {
        return getStyledSubNameFor(product, stringLoader: dependencies.stringLoader).text
    }

    override func getQuantity() -> String {
        return product.getAmountUI()
    }

    private var activateTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("pg_button_activateCard")
    }

    private func cardTitle() -> LocalizedStylableText {
        if product.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if product.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }

    override func bind(viewCell: ItemCardViewCell) {
        super.bind(viewCell: viewCell)
        viewCell.setQuantityTitle(cardTitle())
        viewCell.setActivateTitle(activateTitle)
        let isDisabled = product.isInactive || product.isTemporallyOff || product.isContractBlocked
        viewCell.isGrayedOut(isDisabled)
        viewCell.isActivatePending(product.isInactive)
        viewCell.setStyledSubName(subname: getStyledSubNameFor(product, stringLoader: dependencies.stringLoader))
        dependencies.imageLoader.load(relativeUrl: product.buildImageRelativeUrl(true), imageView: viewCell.getCardImageView(), placeholder: "defaultCard")
        viewCell.didSelectActivate = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardActivator.activate(card: strongSelf.product)
        }
    }
    
    override func configure(viewCell: ItemCardViewCell) {
        updateMovements(cell: viewCell)
    }
    
    private func updateMovements(cell: ItemCardViewCell) {
        if let movements = movements, movements > 0 {
            cell.setTransferCount(count: movements > 99 ? "99+": "\(movements)")
        } else {
            cell.setTransferCount(count: nil)
        }
    }

}
