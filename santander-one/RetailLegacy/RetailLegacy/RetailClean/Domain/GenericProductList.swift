import SANLegacyLibrary
import Foundation
import CoreFoundationLib

class GenericProductList<GP> where GP: GenericProduct {
        
    var list: [GP]
    
    required init(_ list: [GP]) {
        self.list = list
    }

    func getProductCount() -> Int {
        return list.count
    }

    func getVisibles() -> [GP] {
        return get(ordered: false, visibles: true, filter: nil)
    }
    
    func getNotVisibles() -> [GP] {
        return list.filter { !$0.isVisible() }
    }

    func getVisibles(_ filter: OwnershipProfile? = nil) -> [GP] {
        return get(ordered: false, visibles: true, filter: filter)
    }
    
    func isVisiblesEmpty(_ filter: OwnershipProfile? = nil) -> Bool {
        return getVisibles(filter).isEmpty
    }

    func getOrderedVisibles() -> [GP] {
        return get(ordered: true, visibles: true, filter: nil)
    }
    
    func get(ordered: Bool = false, visibles: Bool = false, filter: OwnershipProfile? = nil) -> [GP] {
        var result = list
        if visibles {
            result = result.filter { $0.isVisible() }
        }
        
        if ordered {
            result = result.sorted {
                $0.getPositionInList() < $1.getPositionInList()
            }
        }
        
        if let filter = filter {
            result = result.filter { filter.matchesFor($0) }
        }
        
        return result
    }

    func getTotal(_ currencyType: CurrencyType) throws -> Decimal {
        return try getTotalFiltered(nil, false, currencyType)
    }
    
    func getTotalFiltered(_ filter: OwnershipProfile?, _ counterValueEnabled: Bool, _ currencyType: CurrencyType) throws -> Decimal {
        return try getVisibles(filter).compactMap {
            if counterValueEnabled {
                if let value = $0.getCounterValueAmountValue() {
                    return value
                } else if $0.getAmount()?.currency?.currencyType == currencyType {
                    return $0.getAmount()?.value
                } else {
                    return nil
                }
            } else {
                guard $0.getAmount()?.currency?.currencyType == currencyType else {
                    throw MultipleCurrencyException()
                }
                return $0.getAmount()?.value
            }
        }.reduce(Decimal(0.0)) { $0 + $1 }
    }
    
    func getTotalAmount(_ filter: OwnershipProfile? = nil, _ counterValueEnabled: Bool) throws -> Amount {
        let amount: Decimal = try getTotalFiltered(filter, counterValueEnabled, CoreCurrencyDefault.default)
        return Amount.createFromDTO(AmountDTO(value: amount, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
    }
    
    func getMaxAmount(_ filter: OwnershipProfile?) -> Double {
        let products: [GP] = getVisibles(filter)
        return products.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).first?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getMinAmount(_ filter: OwnershipProfile?) -> Double {
        let products: [GP] = getVisibles(filter)
        return products.sorted(by: {($0.getAmountValue()?.doubleValue ?? 0 > $1.getAmountValue()?.doubleValue ?? 0)}).last?.getAmountValue()?.doubleValue ?? 0
    }
    
    func getAliases(_ filter: OwnershipProfile?) -> String {
        let products: [GP] = getVisibles(filter)
        return products.map({$0.getAlias() ?? ""}).joined(separator: ";")
    }
}
