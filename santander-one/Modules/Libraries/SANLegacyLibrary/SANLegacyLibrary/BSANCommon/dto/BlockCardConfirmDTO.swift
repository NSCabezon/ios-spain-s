import Foundation

public struct BlockCardConfirmDTO: Codable {
    public var deliveryAddress: String?
    public var blockTime: Date?
    
    public init() {}
}
