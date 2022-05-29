import CoreDomain

public struct CheckTransferStatusDTO: Codable {
    public var codInfo: String?
    public var statePayment: String?

    public init() {}
}

extension CheckTransferStatusDTO: CheckTransferStatusRepresentable {}
