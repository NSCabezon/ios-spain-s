//
//  ManualPaymentEntity.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 21/05/2020.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public final class ConsultTaxCollectionFormatsEntity {
    public var dto: ConsultTaxCollectionFormatsDTO
    
    public init(_ dto: ConsultTaxCollectionFormatsDTO) {
        self.dto = dto
    }
    
    public var fields: [TaxCollectionFieldEntity] {
        return dto.fields.map(TaxCollectionFieldEntity.init)
    }
    
    public var systemDate: Date {
        return self.dto.systemDate
    }
    
    public var signature: SignatureRepresentable {
        return self.dto.signature
    }
}
