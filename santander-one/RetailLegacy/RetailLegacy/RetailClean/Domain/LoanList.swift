import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class LoanList: GenericProductList<Loan> {
    
    static func create(_ from: [LoanDTO]?) -> LoanList {
        let list = from?.compactMap { Loan(LoanEntity($0)) } ?? []
        return self.init(list)
    }
    
    public func getTotalCountervalue(filter: OwnershipProfile?) -> Decimal {
        var value: Decimal = 0
        let products = getVisibles(filter)
        
        for  product in products {
            if let counterValue = product.getCounterValueAmountValue() {
                value += counterValue
            } else {
                if let amountValue = product.getAmountValue(), product.getAmountCurrency() != nil, CoreCurrencyDefault.default == product.getAmountCurrency()?.currencyType {
                    value += amountValue
                }
            }
        }
        return value
        
    }

}
