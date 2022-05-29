import CoreDomain

public struct IdActuantePayeeDTO: Codable {
    public var bankCode: String?
    public var actingTypeCode: String?
    public var actingNumber: String?

    public init() {}
}

extension IdActuantePayeeDTO: IdIssuerPayeeRepresentable {}
