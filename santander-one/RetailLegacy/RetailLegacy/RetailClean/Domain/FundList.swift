import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class FundList: GenericProductList<Fund> {
    
    static func create(_ from: [FundDTO]?) -> FundList {
        let list = from?.compactMap { Fund(dto: $0) } ?? []
        return self.init(list)
    }
    
    public func getTotalCounterValue(filter: OwnershipProfile?) -> Decimal {
        var value: Decimal = 0
        let products = getVisibles(filter)
        
        for product in products {
            if let counterAmountValue = product.getCounterValueAmountValue() {
                value += counterAmountValue
            } else {
                if let amountValue = product.getAmountValue(), product.getAmountCurrency() != nil, CoreCurrencyDefault.default == product.getAmountCurrency()?.currencyType {
                    value += amountValue
                }
            }
        }
        return value
    }

    func getAllianzFundsNumber() -> Int {
        return list.filter({ $0.isAllianz }).count
    }
}

extension FundList: OperativeParameter {}
