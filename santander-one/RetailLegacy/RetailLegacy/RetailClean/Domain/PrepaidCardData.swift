import SANLegacyLibrary

import Foundation

struct PrepaidCardData {
    let dto: PrepaidCardDataDTO
 
    var holderName: String {
        return dto.holderName ?? ""
    }
}
