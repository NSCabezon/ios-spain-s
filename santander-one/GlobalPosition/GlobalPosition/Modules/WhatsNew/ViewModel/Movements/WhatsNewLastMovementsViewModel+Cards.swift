import CoreFoundationLib

extension WhatsNewLastMovementsViewModel {
    var defaultMinimimAmount: Double {
        60.0
    }
    
    func isCardTransactionElegibleForFraccionate(transaction: CardTransactionWithCardEntity) -> Bool {
        return isEasyPayEnabledForCardTransaction(transaction: transaction)
    }
    
    func isAccountTransactionElegibleForFractionate(transaction: AccountTransactionWithAccountEntity) -> Bool {
        let fundableType = isFundableForAccountTransaction(transaction: transaction)
        return isEasyPayEnabledForAccountTransaction(transaction: transaction, fundableType: fundableType)
    }
    
    func isEasyPayEnabledForCardTransaction(transaction: CardTransactionWithCardEntity) -> Bool {
        guard self.clickToActionValuesForCards.easyPayEnabled == true,
            transaction.cardEntity.isCreditCard else { return false }
        let value = Double((transaction.cardTransactionEntity.amount?.value ?? 0) as NSNumber)
        return value < 0 && abs(value) >= defaultMinimimAmount
    }
    
}
