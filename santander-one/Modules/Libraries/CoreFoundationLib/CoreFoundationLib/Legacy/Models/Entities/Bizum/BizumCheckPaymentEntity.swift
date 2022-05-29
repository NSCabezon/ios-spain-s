//
//  BizumCheckPaymentEntity.swift
//  Models
//
//  Created by Carlos Gutiérrez Casado on 11/09/2020.
//

import SANLegacyLibrary

public final class BizumCheckPaymentEntity: DTOInstantiable {
    public let dto: BizumCheckPaymentDTO
    
    public init(_ dto: BizumCheckPaymentDTO) {
        self.dto = dto
    }
    
    public var phone: String? {
        return dto.phone
    }
    
    public var cmc: String {
        return self.dto.contractIdentifier.center.empresa + self.dto.contractIdentifier.center.empresa + self.dto.contractIdentifier.subGroup + self.dto.contractIdentifier.contractNumber
    }

    public var initialDate: Date {
        return dto.initialDate
    }
    
    public var endDate: Date {
        return dto.endDate
    }
    
    public var back: String? {
        return dto.back
    }
    
    public var message: String? {
        return dto.message
    }
    
    public var ibanPlainCode: String {
        return self.dto.ibanCode.description
    }
    
    public var offset: String? {
        return dto.offset
    }
    
    public var offsetState: String? {
        return dto.offsetState
    }
    
    public var indMigrad: String? {
        return dto.indMigrad
    }
    
    public var xpan: String? {
        return dto.xpan
    }
}
