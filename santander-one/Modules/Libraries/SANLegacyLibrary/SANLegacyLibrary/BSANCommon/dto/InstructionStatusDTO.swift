import CoreDomain

public struct InstructionStatusDTO: Codable {
    public static let defaultCompany = "0049"
    public static let requestAll = "WA"
    public static let requestPendingSignature = "W1"
    public static let statusCancelled = "11"
    public static let statusPendingSignature = "21"
    public static let statusExpired = "22"
    public static let statusPendingRegister = "23"

    public var company: String?
    public var alphanumericCode: String?

    public init() {}
}

extension InstructionStatusDTO: InstructionStatusRepresentable { }
