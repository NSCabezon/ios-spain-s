import Foundation

public struct ModifyPeriodicTransferDTO: Codable {
    public var signatureDTO: SignatureDTO?
    public var amountDTO: AmountDTO?
    public var dataToken: String?
    public var nameFirstHolder: String?
    public var sepaType: String?
    public var fullNameBeneficiary: String?
    public var nextExecutionDate: Date?
    public var concept: String?
    public var residenceIndicator: Bool?
    public var beneficiaryIBAN: IBANDTO?
    public var dateStartValidity: Date?
    public var dateEndValidity: Date?
    public var dateIndicator: InstructionStatusDTO?
    public var periodicityIndicator: InstructionStatusDTO?
    public var periodicityTime: String?
    public var actingNumber: String?
    public var actingBeneficiary: InstructionStatusDTO?
    public var naturalezaPago: InstructionStatusDTO?
    public var indOperationType: String?

    public init() {}
}
