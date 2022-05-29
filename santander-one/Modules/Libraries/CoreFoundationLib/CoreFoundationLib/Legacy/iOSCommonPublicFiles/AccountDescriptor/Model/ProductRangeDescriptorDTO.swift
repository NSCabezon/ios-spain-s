import Foundation

public struct ProductRangeDescriptorDTO: Codable {
    public let type: String?
    public let fromSubtype: String?
    public let toSubtype: String?
    
    public init(type: String? = nil, fromSubtype: String? = nil, toSubtype: String? = nil) {
        self.type = type
        self.fromSubtype = fromSubtype
        self.toSubtype = toSubtype
    }
}
