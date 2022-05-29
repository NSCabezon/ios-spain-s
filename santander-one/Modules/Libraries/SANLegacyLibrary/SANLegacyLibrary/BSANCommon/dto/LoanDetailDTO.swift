import Foundation
import CoreDomain

public struct LoanDetailDTO: Codable {
    public var holder: String?
    public var initialAmount: AmountDTO?
    public var interestType: String?
    public var interestTypeDesc: String?
    public var feePeriodDesc: String?
    public var openingDate: Date?
    public var initialDueDate: Date?
    public var currentDueDate: Date?
    public var linkedAccountContract: ContractDTO?
    public var linkedAccountDesc: String?
    public var revocable: Bool?
    public var amortizable: Bool?
    public var nextInstallmentDate: Date?
    public var currentInterestAmount: String?
    public var lastOperationDate: Date?

    public init() {}
    
    private enum CodingKeys: String, CodingKey {
        case holder
        case initialAmount
        case interestType
        case interestTypeDesc
        case feePeriodDesc
        case openingDate
        case initialDueDate
        case currentDueDate
        case linkedAccountContract
        case linkedAccountDesc
        case revocable
        case amortizable
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(holder, forKey: .holder)
        try container.encode(initialAmount, forKey: .initialAmount)
        try container.encode(interestType, forKey: .interestType)
        try container.encode(interestTypeDesc, forKey: .interestTypeDesc)
        try container.encode(feePeriodDesc, forKey: .feePeriodDesc)
        try container.encode(openingDate, forKey: .openingDate)
        try container.encode(initialDueDate, forKey: .initialDueDate)
        try container.encode(currentDueDate, forKey: .currentDueDate)
        try container.encode(linkedAccountContract, forKey: .linkedAccountContract)
        try container.encode(linkedAccountDesc, forKey: .linkedAccountDesc)
        try container.encode(revocable, forKey: .revocable)
        try container.encode(amortizable, forKey: .amortizable)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        holder = try values.decode(String?.self, forKey: .holder)
        initialAmount = try values.decode(AmountDTO?.self, forKey: .initialAmount)
        do {
            interestType = try values.decode(String.self, forKey: .interestType)
        } catch {
            do {
                let interestTypeDecimal = try values.decode(Decimal.self, forKey: .interestType)
                interestType = "\(interestTypeDecimal)"
            } catch {
                interestType = nil
            }
        }
        interestType = try values.decode(String?.self, forKey: .interestType)
        interestTypeDesc = try values.decode(String?.self, forKey: .interestTypeDesc)
        feePeriodDesc = try values.decode(String?.self, forKey: .feePeriodDesc)
        openingDate = try values.decode(Date?.self, forKey: .openingDate)
        initialDueDate = try values.decode(Date?.self, forKey: .initialDueDate)
        currentDueDate = try values.decode(Date?.self, forKey: .currentDueDate)
        linkedAccountContract = try values.decode(ContractDTO?.self, forKey: .linkedAccountContract)
        linkedAccountDesc = try values.decode(String?.self, forKey: .linkedAccountDesc)
        revocable = try values.decode(Bool?.self, forKey: .revocable)
        amortizable = try values.decodeIfPresent(Bool.self, forKey: .amortizable)
    }
}

extension LoanDetailDTO: LoanDetailRepresentable {
    public var initialAmountRepresentable: AmountRepresentable? {
        return initialAmount
    }
    
    public var linkedAccountContractRepresentable: ContractRepresentable? {
        return linkedAccountContract
    }
    
    public var formatPeriodicity: String? {
        return feePeriodDesc
    }
}
