//
//  ActivateCardEntity.swift
//  Models
//
//  Created by Cristobal Ramos Laina on 20/10/2020.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public struct ActivateCardEntity: DTOInstantiable {
    
    public let dto: ActivateCardDTO

    public init(_ dto: ActivateCardDTO) {
        self.dto = dto
    }
        
    public var scaRepresentable: SCARepresentable? {
        return dto.scaRepresentable
    }
}
