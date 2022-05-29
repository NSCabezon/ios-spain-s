import CoreDomain

public struct CardDTO: BaseProductDTO, Hashable {
    public var alias: String?
    public var contract: ContractDTO?
    public var ownershipTypeDesc: OwnershipTypeDesc?
    public var currency: CurrencyDTO?
    public var ownershipType: String?
    public var PAN: String?
    public var cardTypeDescription: String?
    public var cardContractStatusType: CardContractStatusType?                                  
    public var statusDescription: String?
    public var allowsDirectMoney: Bool?
    public var productSubtypeDTO : ProductSubtypeDTO?
    public var eCashInd: Bool = false
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var situation: CardContractStatusType?
    public var cardType: String?
    public var productId: ProductID?
    public var inactive: Bool? = false
    public var formattedPAN: String? {
        return PAN?.replace(" ", "")
    }
    public var cardBalanceDTO: CardBalanceDTO?
    public var dataDTO: CardDataDTO?
    public var temporallyOff: Bool? = false
    public struct ProductIDCardDTO: Codable, Hashable {
        public var id: String?
        public var systemId: Int?
    }
    
    public init() {}
        
    
    public static func == (lhs: CardDTO, rhs: CardDTO) -> Bool {
        guard let lhsPAN = lhs.PAN else {
            return false
        }
        guard let rhsPAN = rhs.PAN else {
            return false
        }
        return lhsPAN.replace(" ", "") == rhsPAN.replace(" ", "")
    }
    
    public func hash(into hasher: inout Hasher) {
        guard let PAN = PAN, let hash = Int(PAN) else { return hasher.combine(0) }
        return hasher.combine(hash)
    }
}

extension CardDTO: CardRepresentable {
 
    public var visualCode: String? {
        dataDTO?.visualCode
    }
    
    public var stampedName: String? {
        dataDTO?.stampedName
    }
    
    public var description: String? {
        dataDTO?.description
    }
    
    public var isVisible: Bool {
        false
    }
    
    public var boxType: UserPrefBoxType {
        .account
    }
    
    public var productIdRepresentable: String {
        "Card"
    }
    
    public var productIdentifier: String? {
        contract?.formattedValue
    }
    
    public var isCreditCard: Bool {
        guard let type = cardType?.uppercased() else {
            let firstChar = cardTypeDescription?.prefix(1).lowercased()
            return firstChar?.elementsEqual("c") ?? false
        }
        return type.elementsEqual("C")
    }
    
    public var isPrepaidCard: Bool {
        guard let type = cardType?.uppercased() else {
            let firstChar = cardTypeDescription?.prefix(1).lowercased()
            return firstChar?.elementsEqual("p") ?? false
        }
        return type.elementsEqual("P")
    }
    
    public var isDebitCard: Bool {
        guard let type = cardType?.uppercased() else {
            let firstChar = cardTypeDescription?.prefix(1).lowercased()
            return firstChar?.elementsEqual("d") ?? false
        }
        return type.elementsEqual("D")
    }
        
    public var pan: String? {
        get {
            return formattedPAN
        }
        set(newValue) {
            PAN = newValue
        }
       
    }
    
    public var isTemporallyOff: Bool? {
        get {
            return temporallyOff ?? false
        }
        set(newValue) {
            temporallyOff = newValue
        }
    }
    
    public var detailUI: String? {
        PAN?.trim() ?? ""
    }

    public var expirationDate: String? {
        dataDTO?.cardSuperSpeedDTO?.expirationDate
    }
    
    public var currencyRepresentable: CurrencyRepresentable? {
        currency
    }
    
    public var trackId: String {
        if isCreditCard {
            return "credito"
        } else if isDebitCard {
            return "debito"
        } else {
            return "prepago"
        }
    }
    
    public var productSubtypeRepresentable: ProductSubtypeRepresentable? {
        productSubtypeDTO
    }
    
    public var contractRepresentable: ContractRepresentable? {
        contract
    }
    
    public var creditLimitAmountRepresentable: AmountRepresentable? {
        cardBalanceDTO?.creditLimitAmount
    }
    
    public var currentBalanceRepresentable: AmountRepresentable? {
        cardBalanceDTO?.currentBalance
    }
    
    public var availableAmountRepresentable: AmountRepresentable? {
        cardBalanceDTO?.availableAmount
    }
    
    public var isContractActive: Bool {
        if let type = cardContractStatusType {
            return type == .active
        }
        return false
    }

    public var isContractInactive: Bool {
        if let type = cardContractStatusType {
            return type == .inactive
        }
        return false
    }

    public var isContractBlocked: Bool {
        if let type = cardContractStatusType {
            return type == CardContractStatusType.blocked
        }
        return false
    }

    public var isContractCancelled: Bool {
        if let type = cardContractStatusType {
            return type == CardContractStatusType.cancelled
        }
        return false
    }

    public var isContractReplacement: Bool {
        if let type = cardContractStatusType {
            return type == CardContractStatusType.replacement
        }
        return false
    }

    public var isContractIssued: Bool {
        if let type = cardContractStatusType {
            return type == CardContractStatusType.issued
        }
        return false
    }

    public var isContractHolder: Bool {
        let titularRetail = OwnershipType.holder.rawValue == ownershipType
        let titularPB = OwnershipTypeDesc.holder.rawValue == ownershipTypeDesc?.rawValue
        return titularRetail || titularPB
    }
        
    public var isOwnerSuperSpeed: Bool {
        dataDTO?.cardSuperSpeedDTO?.qualityParticipation == OwnershipType.holder.rawValue
    }
    public var dailyCurrentLimitAmountRepresentable: AmountRepresentable? {
        dataDTO?.dailyCurrentLimitAmount
    }
    public var dailyMaximumLimit: AmountRepresentable? {
        dataDTO?.dailyMaximumLimitAmount
    }
    public var atmLimitRepresentable: AmountRepresentable? {
        dataDTO?.dailyATMCurrentLimitAmount
    }
    public var dailyATMMaximumLimitAmountRepresentable: AmountRepresentable? {
        dataDTO?.dailyATMMaximumLimitAmount
    }
    
    public var isBeneficiary: Bool {
        ownershipType == "17"
    }
}

extension CardDTO {
    public struct ProductID: Codable, Hashable {
        public var id: String?
        public var systemId: Int?
        
        public init(id: String?, systemId: Int?) {
            self.id = id
            self.systemId = systemId
        }
    }
}
