//

import Foundation

struct BizumSendImageTextErrorDTO: Codable {
    let appName: String
    let timeStamp: Double
    let errorName: String
    let status: Int
    let internalCode: Int
    let shortMessage: String
    let detailedMessage: String
}
