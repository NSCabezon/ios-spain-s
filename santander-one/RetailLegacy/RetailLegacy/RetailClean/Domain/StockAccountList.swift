import SANLegacyLibrary
import Foundation
import CoreFoundationLib
import CoreDomain

class StockAccountList: GenericProductList<StockAccount> {
    
    public var stockAccountType: StockAccountType = StockAccountType.CCV
    
    static func create(_ from: [StockAccountDTO]?, stockAccountType: StockAccountType?) -> StockAccountList {
        let list = from?.compactMap { StockAccount(dto: $0) } ?? []
        let outputList = self.init(list)
        if let stockAccountTypeStrong = stockAccountType {
            outputList.stockAccountType = stockAccountTypeStrong
        }
        
        return outputList
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

extension StockAccountList {
    func unique() -> StockAccountList {
        let output = StockAccountList([])
        output.stockAccountType = stockAccountType
        if stockAccountType == .CCV {
            for current in list {
                if let description = current.stockAccountDTO.contractDescription, !output.list.contains(where: {$0.stockAccountDTO.contractDescription == description}) {
                    output.list.append(current)
                }
            }
        } else {
            for current in list {
                if let contract = current.stockAccountDTO.contract, !output.list.contains(where: {$0.stockAccountDTO.contract == contract}) {
                    output.list.append(current)
                }
            }
        }
        
        return output
    }
}

extension StockAccountList: OperativeParameter {}
