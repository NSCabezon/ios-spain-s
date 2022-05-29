import Foundation

public struct ValidateMobileRechargeDTO: Codable {
    public var signatureWithTokenDTO: SignatureWithTokenDTO?
    public var availableAmount: AmountDTO?
    public var holder: String?
    public var cardDescription: String?
    public var expirationDate: Date?

    public init() {}
}
