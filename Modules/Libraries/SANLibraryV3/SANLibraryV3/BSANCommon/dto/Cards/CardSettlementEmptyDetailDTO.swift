//

import Foundation

public struct CardSettlementEmptyDetailDTO: Codable {
    public var errorCode: Int?
    
    private enum CodingKeys: String, CodingKey {
        case errorCode = "status"
    }
}
