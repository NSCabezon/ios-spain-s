import CoreFoundationLib

extension WhatsNewLastMovementsViewModel {
    
    func isFundableForAccountTransaction(transaction: AccountTransactionWithAccountEntity) -> AccountEasyPayFundableType {
        guard let amount = transaction.accountTransactionEntity.amount else { return .notAllowed }
        return self.easyPayFundableType(for: amount, transaction: transaction.accountTransactionEntity,
                                   accountEasyPay: self.clickToActionValuesForAccounts.easyPay)
    }
    
    func isEasyPayEnabledForAccountTransaction(transaction: AccountTransactionWithAccountEntity, fundableType: AccountEasyPayFundableType) -> Bool {
        switch fundableType {
        case .low where offers.contains(location: AccountsPullOffers.lowEasyPayAmountDetail): return true
        case .high where offers.contains(location: AccountsPullOffers.highEasyPayAmountDetail): return true
        default: return false
        }
    }
    
}
