import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class PensionList: GenericProductList<Pension> {
    static func create(_ from: [PensionDTO]?) -> PensionList {
        let list = from?.compactMap { Pension(dto: $0) } ?? []
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

}

extension PensionList: OperativeParameter {}
