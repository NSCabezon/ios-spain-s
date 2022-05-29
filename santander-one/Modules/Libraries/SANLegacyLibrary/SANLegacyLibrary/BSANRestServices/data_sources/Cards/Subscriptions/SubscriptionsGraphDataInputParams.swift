import Foundation

public struct SubscriptionsGraphDataInputParams: Codable {
    let pan: String
    let instaId: String
    
    private enum CodingKeys: String, CodingKey {
        case pan = "pan"
        case instaId = "insta_id"
    }

    public init(pan: String, instaId: String) {
        self.pan = pan
        self.instaId = instaId
    }
}
