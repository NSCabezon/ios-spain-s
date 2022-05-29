import CoreDomain

public struct LoanValidationDTO: Codable {
    public var signature: SignatureDTO?
    public var token: String?
    public var valueDate: String?
    public var settlementAmount: AmountDTO?
    public var finantialLossAmount: AmountDTO?
    public var compensationAmount: AmountDTO?
    public var insuranceFeeAmount: AmountDTO?

    public init() {}
}

extension LoanValidationDTO: LoanValidationRepresentable {
    public var signatureRepresentable: SignatureRepresentable? {
        return signature
    }
    
    public var settlementAmountRepresentable: AmountRepresentable? {
        return settlementAmount
    }

    public var finantialLossAmountRepresentable: AmountRepresentable? {
        return finantialLossAmount
    }

    public var compensationAmountRepresentable: AmountRepresentable? {
        return compensationAmount
    }

    public var insuranceFeeAmountRepresentable: AmountRepresentable? {
        return insuranceFeeAmount
    }
}
