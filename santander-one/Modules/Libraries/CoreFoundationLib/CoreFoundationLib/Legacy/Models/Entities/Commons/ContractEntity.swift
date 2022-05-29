//
//  Contract.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import SANLegacyLibrary
import CoreDomain

public final class ContractEntity {
    
    public let representable: ContractRepresentable
    
    public init(_ dto: ContractDTO) {
        self.representable = dto
    }
    
    public init(_ representable: ContractRepresentable) {
        self.representable = representable
    }
    
    public var contractPK: String {
        return representable.contratoPK ?? ""
    }
    
    public var contractNumber: String? {
        return representable.contractNumber
    }
    
    public var shortContract: String {
        guard let contractNumber = representable.contractNumber else { return "****" }
        return "***" + (contractNumber.substring(contractNumber.count - 4) ?? "*")
    }
}

extension ContractEntity {
    
    public var dto: ContractDTO {
        return representable as? ContractDTO ?? ContractDTO()
    }
}
