import Foundation

public struct PayLaterDTO: Codable {
    public var enrollmentDate: Date?
    public var situationDesc: String?
    public var productName: String?
    public var paymentMethodDesc: String?
    public var holderName: String?
    public var debts: [DebtDTO] = []
    
    public init() {}
}
