import SANLegacyLibrary
import CoreFoundationLib

class InsuranceSavingList: GenericProductList<InsuranceSaving> {
    
    static func create(_ from: [InsuranceDTO]?) -> InsuranceSavingList {
        return InsuranceSavingList(from?.compactMap { InsuranceSaving(dto: $0) } ?? [])
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
