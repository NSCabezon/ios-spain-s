//
//  NoSepaPayeeDetailEntity.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 04/05/2020.
//

import SANLegacyLibrary
import Foundation

public final class NoSepaPayeeDetailEntity: DTOInstantiable {
    
    public let dto: NoSepaPayeeDetailDTO
    
    public init(_ dto: NoSepaPayeeDetailDTO) {
        self.dto = dto
    }
    
    public var bicSwift: String? {
        return self.payee?.swiftCode
    }
    
    public var transferAmount: AmountEntity? {
        return self.dto.amount.map(AmountEntity.init)
    }
    
    public var destinationCountryCode: String? {
        return self.bankCountryCode?.isEmpty == false ? bankCountryCode : countryCode
    }
    
    public var countryCode: String? {
        return self.payee?.countryCode
    }
    
    public var payee: NoSepaPayeeEntity? {
        return self.dto.payee.map(NoSepaPayeeEntity.init)
    }
    
    public var concept1: String? {
        return self.dto.concept
    }
    
    public var alias: String? {
        return self.dto.alias
    }
    
    public var codePayee: String? {
        return self.dto.codPayee
    }
    
    public var accountType: NoSepaAccountType? {
        return self.dto.accountType
    }
    
    public var payeeAddress: String? {
        return self.payee?.address
    }
    
    public var payeeLocation: String? {
        return self.payee?.town
    }
    
    public var bankCountryCode: String? {
        return self.payee?.bankCountryCode
    }
}
