//

import Foundation
import SANLegacyLibrary

struct DirectMoney {
    let dto: DirectMoneyDTO
    
    var minAmountDescription: String? {
        return dto.minAmountDescription
    }
}

extension DirectMoney: OperativeParameter {}
