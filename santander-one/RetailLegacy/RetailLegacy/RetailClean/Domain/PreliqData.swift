import SANLegacyLibrary

import Foundation

struct PreliqData {
    let dto: PreliqDataDTO
    
    public var liqConcept: String? {
        return dto.liqConcept
    }
    public var chargeTypeInd: String? {
        return dto.chargeTypeInd
    }
    public var bankCharge: Amount {
        return Amount.createFromDTO(dto.bankCharge)
    }
    public var standardAmount: Amount {
        return Amount.createFromDTO(dto.standardAmount)
    }
    public var operationAmount: Amount {
        return Amount.createFromDTO(dto.operationAmount)
    }
    public var notionalAmount: Amount {
        return Amount.createFromDTO(dto.notionalAmount)
    }
    public var commercialChannel: String? {
        return dto.commercialChannel
    }
    public var prepaidCurrentBalance: Amount {
        return Amount.createFromDTO(dto.prepaidCurrentBalance)
    }
    public var totalOperationAmount: Amount {
        return Amount.createFromDTO(dto.totalOperationAmount)
    }
    public var receivableAmount: Amount {
        return Amount.createFromDTO(dto.receivableAmount)
    }
    public var referenceStandard: ReferenceStandardDTO? {
        return dto.referenceStandard
    }
}
