import Foundation

public struct GroupEntityDTO: Codable {
    public let entityCode: String?
    
    public init(entityCode: String? = nil) {
        self.entityCode = entityCode
    }
}
