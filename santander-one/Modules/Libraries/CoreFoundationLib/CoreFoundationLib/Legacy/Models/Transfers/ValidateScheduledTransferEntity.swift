//
//  ValidateScheduledTransferEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import SANLegacyLibrary

public final class ValidateScheduledTransferEntity: DTOInstantiable {
    
    public let dto: ValidateScheduledTransferDTO
    
    public init(_ dto: ValidateScheduledTransferDTO) {
        self.dto = dto
    }
    
    public var dataMagicPhrase: String? {
        return dto.dataMagicPhrase
    }
    
    public var bankChargeAmount: AmountEntity? {
        guard let commission = dto.commission else { return nil }
        return AmountEntity(commission)
    }
    
    public var nameBeneficiaryBank: String? {
        return dto.nameBeneficiaryBank
    }
    
    public var code: String? {
        return dto.actuanteCode
    }
    
    public var number: String? {
        return dto.actuanteNumber
    }
    
    public var company: String? {
        return dto.actuanteCompany
    }
}
