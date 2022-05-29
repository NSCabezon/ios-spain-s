import Foundation

public struct PensionInfoOperationDTO: Codable {
    public var pensionProduct: ProductSubtypeDTO?
    public var pensionAccountAssociated: IBANDTO?
    public var holder: String?
    public var descPension: String?
    public var typePlan: String?
    public var currency: String?
    public var valueDate: Date?
    public var indPorMinReval: String?
    public var indRevalOblig: String?
    public var sharesNumber: Decimal?

    public init() {}
}
