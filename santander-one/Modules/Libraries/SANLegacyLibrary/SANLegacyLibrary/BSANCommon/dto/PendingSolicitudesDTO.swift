import Foundation

public struct PendingSolicitudeListDTO: Codable {
    public var solicitudesDTOs: [PendingSolicitudeDTO]?

    public init() {}
    
    public init(solicitudesDTOs: [PendingSolicitudeDTO]?) {
        self.solicitudesDTOs = solicitudesDTOs
    }
}

public struct PendingSolicitudeDTO: Codable  {
    public var identifier: String?
    public var name: String?
    public var startDate: Date?
    public var expirationDate: Date?
    public var businessCode: String?
    public var solicitudeState: String?
    public var solicitudeType: String?
    public var chanel: String?
    public var chanelDescription: String?
    public var rightWithdrawal: String?
    public var sign: String?

    public init() {}
}
