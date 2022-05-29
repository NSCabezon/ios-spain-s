public protocol SharedPersistedUserDTOProtocol {
    var loginType: String { get }
    var login: String { get }
    var environmentName: String { get }
    var channelFrame: String? { get }
    var isPb: Bool { get }
    var userId: String? { get }
    var biometryData: Data? { get }
}

public struct SharedPersistedUserDTO: Codable {
    public let loginType: String
    public let login: String
    public let environmentName: String
    public let channelFrame: String?
    public let isPb: Bool
    public let name: String?
    public let bdpCode: String?
    public let comCode: String?
    public let isSmart: Bool
    public let userId: String?
    public let biometryData: Data?
}

extension SharedPersistedUserDTO: SharedPersistedUserDTOProtocol {}
