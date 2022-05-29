//

import Foundation

struct BizumGetMultimediaContactsParams: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let contacts: [String]
}

struct BizumGetMultimediaContentParams: Codable {
    let cmc: String
    let language: String
    let emitterUserId: String
    let operationId: String
}
