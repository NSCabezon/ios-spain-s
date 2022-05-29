import CoreFoundationLib

// MARK: Fractioned payments
extension WhatsNewLastMovementsViewModel {
    var unreadFractionedMovements: (accounts: [UnreadMovementItem], cards: [UnreadMovementItem]) {
        return (accounts: getAccountFractionableMovements(), cards: getCardFractionableMovements())
    }
    
    var fractionedPaymentsSum: (accounts: NSAttributedString, cards: NSAttributedString) {
        let totalFractionedAccounts = self.getAccountFractionableMovements().map({
                guard let amountValue = $0.amount?.value else { return 0.0 }
                return amountValue
            }).reduce(Decimal(0), +)
        let totalFractionedCards = self.getCardFractionableMovements().map({
                guard let amountValue = $0.amount?.value else { return 0.0 }
                return amountValue
            }).reduce(Decimal(0), +)
        let totalAccountsAttributed = self.formattedMoneyFrom(totalFractionedAccounts, negativeSign: true, size: 14.0)
        let totalCardsAttributed = self.formattedMoneyFrom(totalFractionedCards, negativeSign: true, size: 14.0)
        return (accounts: totalAccountsAttributed, cards: totalCardsAttributed)
    }
    
    func getAccountFractionableMovements() -> [UnreadMovementItem] {
        return accountFractionableMovements.map({ accountTransaction in
            let alias = "\(accountTransaction.accountEntity.alias ?? "") \(accountTransaction.accountEntity.getIBANShort)"
            let unreadItemCrossSelling = UnreadAccountItemCrossSellingViewModel(
                accountTransaction: accountTransaction,
                crossSellingParams: clickToActionValuesForAccounts,
                offers: offers)
            return UnreadMovementItem(
                concept: accountTransaction.accountTransactionEntity.dto.description,
                date: accountTransaction.accountTransactionEntity.operationDate,
                amount: accountTransaction.accountTransactionEntity.amount,
                imageUrl: "icnLogoSanSmall",
                alias: alias,
                shortContract: accountTransaction.accountEntity.getIBANShort,
                type: .account,
                movementId: accountTransaction.accountTransactionEntity.hashValue,
                crossSelling: unreadItemCrossSelling,
                isFractional: true)
        })
    }
    
    func getCardFractionableMovements() -> [UnreadMovementItem] {
        return cardFractionableMovements.map({ cardTransaction in
            let unreadItemCrossSelling = UnreadCardItemCrossSellingViewModel(
                cardTransaction: cardTransaction,
                crossSellingParams: clickToActionValuesForCards,
                offers: offers)
            return UnreadMovementItem(concept: cardTransaction.cardTransactionEntity.description,
                                          date: cardTransaction.cardTransactionEntity.operationDate,
                                          amount: cardTransaction.cardTransactionEntity.amount,
                                          imageUrl: baseUrl + cardTransaction.cardEntity.buildImageRelativeUrl(miniature: true),
                                          alias: cardTransaction.cardEntity.getAliasCamelCase(),
                                          shortContract: cardTransaction.cardEntity.shortContract,
                                          type: .card,
                                          movementId: cardTransaction.cardTransactionEntity.hashValue,
                                          crossSelling: unreadItemCrossSelling,
                                          isFractional: true)
        })
    }
}

private extension WhatsNewLastMovementsViewModel {
    func formattedMoneyFrom(_ amount: Decimal, negativeSign: Bool = false, size: CGFloat) -> NSAttributedString {
        var amountEntity = AmountEntity(value: amount)
        if negativeSign { amountEntity = amountEntity.changedSign }
        let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .bold, size: size))
        let formmatedDecorator = decorator.formatAsMillionsWithoutDecimals()
        return formmatedDecorator ?? NSAttributedString()
    }
}
