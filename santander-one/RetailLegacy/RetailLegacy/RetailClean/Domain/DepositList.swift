import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class DepositList: GenericProductList<Deposit> {
    
    static func create(_ from: [DepositDTO]?) -> DepositList {
        let list = from?.compactMap { Deposit.create($0) } ?? []
        return self.init(list)
    }
    
    public func getTotalCounterValue(filter: OwnershipProfile?) -> Decimal {
        var value: Decimal = 0
        let products = getVisibles(filter)
        
        for product in products {
            if let counterAmounValue = product.getCounterValueAmountValue() {
                value += counterAmounValue
            } else {
                if let amountValue = product.getAmountValue(), product.getAmountCurrency() != nil, CoreCurrencyDefault.default == product.getAmountCurrency()?.currencyType {
                    value += amountValue
                }
            }
        }
        return value
    }
}
