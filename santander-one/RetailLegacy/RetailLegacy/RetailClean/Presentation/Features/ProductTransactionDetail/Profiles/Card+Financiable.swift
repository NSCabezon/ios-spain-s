import Foundation

protocol CardFinanciable {
    var easyPayMinimumAmount: Double { get }
}

extension CardFinanciable {
    
    func isCardTransactionFinanciable(transaction: CardTransaction) -> Bool {
        let amount = transaction.amount
        guard let value = amount.value?.doubleValue else {
            return false
        }
        let commercialSegment: Double = easyPayMinimumAmount
        return amount.currency?.currencyType == .eur && value < 0 && abs(commercialSegment) <= abs(value)
    }
    
    func isCardFinanciable(_ card: Card) -> Bool {
        return card.isCreditCard && card.isCardContractHolder
    }    
    
}
