import Foundation

public struct FrequentOperativePrefDTO: Codable {
    public let id: String
    public var isEnabled: Bool
    
    public init(id: String, isEnabled: Bool) {
        self.id = id
        self.isEnabled = isEnabled
    }
}
