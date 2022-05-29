import SANLegacyLibrary

import Foundation

struct ValidatePrepaidCard {
    let dto: ValidateLoadPrepaidCardDTO
    let preliqData: PreliqData
    let token: String
    
    init(dto: ValidateLoadPrepaidCardDTO, preliqData: PreliqData, token: String) {
        self.dto = dto
        self.preliqData = preliqData
        self.token = token
    }
}
