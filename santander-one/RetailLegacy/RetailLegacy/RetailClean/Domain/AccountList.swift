import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class AccountList: GenericProductList<Account> {
    
    static func createFrom(_ accountDTOs: [AccountDTO]?, _ accountDescriptorsDTOs: [AccountDescriptorDTO]?) -> AccountList {
        let accounts = accountDTOs?.map { Account.create($0) } ?? []
        return AccountList(accounts, accountDescriptorsDTOs ?? [])
    }
    
    var accountDescriptors: [AccountDescriptorDTO]
    
    convenience init(_ list: [Account], _ descriptors: [AccountDescriptorDTO]) {
        self.init(list)
        accountDescriptors = descriptors
    }
    
    required init(_ list: [Account]) {
        accountDescriptors = []
        super.init(list)
    }
    
    private func isCreditAccount(_ account: Account) -> Bool {
        if accountDescriptors.isEmpty {
            return false
        }
        
        if let productSubtypeDTO = account.productSubtype {
            return accountDescriptors.contains(where: {$0.type == productSubtypeDTO.productType && $0.subType == productSubtypeDTO.productSubtype})
        }

        return false
    }
    
    func getTotalAmountWithoutCreditAccounts(_ currency: CurrencyType) throws -> Decimal {
        var value: Decimal = 0
        let products = getVisibles()
        
        for product in products {
            if !isCreditAccount(product) {
                value += try getAmountNode(currency, product)
            }
        }
        return value
    }
    
    func getTotalAmountFromCreditsAccounts(_ currency: CurrencyType) throws -> Decimal {
        var value: Decimal = 0
        let products = getVisibles()
        
        for  product in products {
            if isCreditAccount(product) {
                value += try getAmountNode(currency, product)
            }
        }
        return value
    }
    
    func getTotalCounterValueFromCreditsAccounts(filter: OwnershipProfile?) -> Decimal {
        return getCounterValue(WithCreditAccount: true, filter: filter)
    }
    
    func getTotalCounterValueWithoutCreditsAccounts(filter: OwnershipProfile?) -> Decimal {
        return getCounterValue(WithCreditAccount: false, filter: filter)
    }
    
    public func getTotalCounterValue(filter: OwnershipProfile?) -> Decimal {
        var value: Decimal = 0
        value += getTotalCounterValueWithoutCreditsAccounts(filter: filter)
        value += getTotalCounterValueFromCreditsAccounts(filter: filter)
        
        return value
    }
    
    private func getCounterValue(WithCreditAccount creditAccount: Bool, filter: OwnershipProfile?) -> Decimal {
        var value: Decimal = 0
        let products = getVisibles(filter)
        
        for product in products {
            if creditAccount == true {
                if isCreditAccount(product) {
                    value += getCounterValueAmountNode(product)
                }
            } else {
                if !isCreditAccount(product) {
                    value += getCounterValueAmountNode(product)
                }
            }
            
        }
        return value
    }
    
    //=================================
    // MARK: - Private Methods
    //=================================
   private func getCounterValueAmountNode(_ product: Account) -> Decimal {
        var value: Decimal = 0
        
        if let counterValueAmount = product.getCounterValueAmountValue() {
            value += counterValueAmount
        } else {
            if let amountValue = product.getAmountValue(), product.getAmountCurrency() != nil, CoreCurrencyDefault.default == product.getAmountCurrency()?.currencyType {
                value += amountValue
            }
        }
        return value
    }

    private func getAmountNode(_ currency: CurrencyType, _  product: Account) throws -> Decimal {
        var value: Decimal = 0
        
        if let amount = product.getAmount() {
            if amount.currency?.currencyType != currency {
                throw MultipleCurrencyException()
            }
            if let amountValue = amount.value {
                value += amountValue
            }
        }
        
        return value
    }
    
    func anyKidAccount() -> Bool {
        return list.filter({$0.isKidAccount()}).count > 0
    }
}

extension AccountList: OperativeParameter {}
