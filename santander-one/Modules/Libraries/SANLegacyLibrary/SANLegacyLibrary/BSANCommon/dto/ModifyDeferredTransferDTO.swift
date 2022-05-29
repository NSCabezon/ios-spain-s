import Foundation

public struct ModifyDeferredTransferDTO: Codable {
    public var signatureDTO: SignatureDTO?
    public var amountDTO: AmountDTO?
    public var dataToken: String?
    public var nameFirstHolder: String?
    public var actingBeneficiary: InstructionStatusDTO?
    public var sepaType: String?
    public var fullNameBeneficiary: String?
    public var nextExecutionDate: Date?
    public var concept: String?
    public var residenceIndicator: Bool?
    public var beneficiaryIBAN: IBANDTO?
    public var operationType: InstructionStatusDTO?
    public var actingNumber: String?
    public var indOperationType: String?        

    public init() {}
}
