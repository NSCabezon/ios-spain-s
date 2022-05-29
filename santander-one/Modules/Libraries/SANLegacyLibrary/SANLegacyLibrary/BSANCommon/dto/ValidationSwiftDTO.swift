import CoreDomain

public struct ValidationSwiftDTO: Codable {
    public var settlementAmountPayer: AmountDTO?
    public var chargeAmount: AmountDTO?
    public var accountType: String?
    public var modifyDate: Date?
    public var beneficiaryBic: String?
    public var swiftIndicator: Bool?
    
    public init() {}
    
    public init(settlementAmountPayer: AmountDTO, chargeAmount: AmountDTO, accountType: String, modifyDate: Date, beneficiaryBic: String, swiftIndicator: Bool) {
        self.settlementAmountPayer = settlementAmountPayer
        self.chargeAmount = chargeAmount
        self.accountType = accountType
        self.modifyDate = modifyDate
        self.beneficiaryBic = beneficiaryBic
        self.swiftIndicator = swiftIndicator
    }
}

extension ValidationSwiftDTO: ValidationSwiftRepresentable {
    public var settlementAmountPayerRepresentable: AmountRepresentable? {
        return settlementAmountPayer
    }

    public var chargeAmountRepresentable: AmountRepresentable? {
        return chargeAmount
    }
}
