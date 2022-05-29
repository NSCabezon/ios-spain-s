import CoreDomain

public struct LoanDTO: BaseProductDTO {
    public var alias: String?
    public var contract: ContractDTO?
    public var ownershipTypeDesc: OwnershipTypeDesc?
    public var currency: CurrencyDTO?
    public var currentBalance: AmountDTO?
    public var availableAmount: AmountDTO?
    public var repaymentAmount: AmountDTO?
    public var contractStatusDesc: String?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    
    public var productId: ProductID?
    
    // Contravalores
    public var counterValueAvailableBalanceAmount: AmountDTO?
    public var counterValueCurrentBalanceAmount: AmountDTO?
    
    public init() {}
}

extension LoanDTO {
    public struct ProductID: Codable, Hashable {
        public var id: String?
        public var systemId: Int?
        
        public init(id: String?, systemId: Int?) {
            self.id = id
            self.systemId = systemId
        }
    }
}

extension LoanDTO: LoanRepresentable {
    public var productIdentifier: String? {
        return contract?.formattedValue
    }
    
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    
    public var contractDisplayNumber: String? {
        return contractDescription
    }
    
    public var typeOwnershipDesc: String? {
        return ownershipTypeDesc?.rawValue
    }
    
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    
    public var currentBalanceAmountRepresentable: AmountRepresentable? {
        return currentBalance
    }
    
    public var availableAmountRepresentable: AmountRepresentable? {
        return availableAmount
    }
    
    public var counterAvailableBalanceAmountRepresentable: AmountRepresentable? {
        return counterValueAvailableBalanceAmount
    }
    
    public var counterCurrentBalanceAmountRepresentable: AmountRepresentable? {
        return counterValueCurrentBalanceAmount
    }
    
    public var appIdentifier: String {
        return contract?.formattedValue ?? ""
    }
}
