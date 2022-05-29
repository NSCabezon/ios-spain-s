import Foundation

public struct DemoMode: Codable {
    public let demoUser: String
    
    public init(_ demoUser: String) {
        self.demoUser = demoUser
    }
}
