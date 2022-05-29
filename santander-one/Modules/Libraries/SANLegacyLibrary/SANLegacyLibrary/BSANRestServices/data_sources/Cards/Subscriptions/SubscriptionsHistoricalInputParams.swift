import Foundation

public struct SubscriptionsHistoricalInputParams: Codable {
    let pan: String
    let instaId: String
    let startDate: String
    let endDate: String
    
    private enum CodingKeys: String, CodingKey {
        case pan = "pan"
        case instaId = "insta_id"
        case startDate = "fecini"
        case endDate = "fecfin"
    }

    public init(pan: String, instaId: String, startDate: String, endDate: String) {
        self.pan = pan
        self.instaId = instaId
        self.startDate = startDate
        self.endDate = endDate
    }
}
