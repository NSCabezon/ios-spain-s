import CoreDomain

public struct AccountDTO: BaseProductDTO {
    public var alias: String?
    public var contract: ContractDTO?
    public var accountId: String?
    public var ownershipTypeDesc: OwnershipTypeDesc?
    public var currency: CurrencyDTO? {
        return currentBalance?.currency
    }
    
    public var iban: IBANDTO?
    public var oldContract: ContractDTO?
    public var currentBalance: AmountDTO?
    public var availableAutAmount: AmountDTO?
    public var availableNoAutAmount: AmountDTO?
    public var limitAmount: AmountDTO?
    public var balanceIncludedPending: AmountDTO?
    public var overdraftRemaining: AmountDTO?
    public var earningsAmount: AmountDTO?
    public var ownershipType: String?
    public var tipoSituacionCto: String?
    public var productSubtypeDTO : ProductSubtypeDTO?
    public var client: ClientDTO?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var isMainAccount: Bool?
    
    // Contravalores
    public var countervalueCurrentBalanceAmount: AmountDTO?
    public var countervalueAvailableAutAmount: AmountDTO?
    public var countervalueAvailableNoAutAmount: AmountDTO?
    public var countervalueLimitAmount: AmountDTO?
    public var productId: ProductID?
    
    public init() {}
    
    public static func == (lhs: AccountDTO, rhs: AccountDTO) -> Bool {
        guard let lhsContract = lhs.contract, let rhsContract = rhs.contract else {
            return false
        }
        return lhsContract == rhsContract
    }
}

extension AccountDTO {
    public struct ProductID: Codable, Hashable {
        public var id: String?
        public var systemId: Int?
        
        public init(id: String?, systemId: Int?) {
            self.id = id
            self.systemId = systemId
        }
    }
}

extension AccountDTO: AccountRepresentable {
    public var countervalueCurrentBalanceAmountRepresentable: AmountRepresentable? {
        return countervalueCurrentBalanceAmount
    }
    public var countervalueAvailableNoAutAmountRepresentable: AmountRepresentable? {
        return countervalueAvailableNoAutAmount
    }
    public var earningsAmountRepresentable: AmountRepresentable? {
        return earningsAmount
    }
    public var productSubtypeRepresentable: ProductSubtypeRepresentable? {
        return productSubtypeDTO
    }
    public var availableAmountRepresentable: AmountRepresentable? {
        return availableAmount
    }
    public var availableNoAutAmountRepresentable: AmountRepresentable? {
        return availableNoAutAmount
    }
    public var overdraftRemainingRepresentable: AmountRepresentable? {
        return overdraftRemaining
    }
    public var ibanRepresentable: IBANRepresentable? {
        return iban
    }
    
    public var currentBalanceRepresentable: AmountRepresentable? {
        return currentBalance
    }
    
    public var currencyName: String? {
        return currentBalance?.currency?.currencyName
    }
    
    public var contractNumber: String? {
        return contract?.contractNumber
    }
    
    public var contractRepresentable: ContractRepresentable? {
        return contract
    }
    
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    
    public var getIBANShort: String {
        let ibanShort = ibanRepresentable?.ibanShort(
            showCountryCode: false,
            asterisksCount: 1,
            lastDigitsCount: 4
        )
        return ibanShort ?? "****"
    }
    
    public var getIBANPapel: String {
        guard let ibanPapel = ibanRepresentable?.ibanPapel else { return "****" }
        return ibanPapel
    }
    
    public var getIBANString: String {
        guard let ibanString = ibanRepresentable?.ibanString else { return "****" }
        return ibanString
    }
    
    public var availableAmount: AmountRepresentable? {
        return availableNoAutAmount
    }
    
    public var situationType: String? {
        return tipoSituacionCto
    }
    
    public var appIdentifier: String {
        return contract?.formattedValue ?? ""
    }
}
