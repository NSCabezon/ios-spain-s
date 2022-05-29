//
//  TaxCollectionFieldEntity.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 21/05/2020.
//

import Foundation
import SANLegacyLibrary

public final class TaxCollectionFieldEntity {
    public var dto: TaxCollectionFieldDTO
    
    public init(_ dto: TaxCollectionFieldDTO) {
        self.dto = dto
    }
    
    public var fieldDescription: String {
        return self.dto.fieldDescription
    }
    
    public var fieldId: String {
        return self.dto.fieldId
    }
    
    public var fieldLength: String {
        return self.dto.fieldLength
    }
    
    public var referenceId: String {
        return self.dto.referenceId
    }
}

extension TaxCollectionFieldEntity: Equatable {
    public static func == (lhs: TaxCollectionFieldEntity, rhs: TaxCollectionFieldEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension TaxCollectionFieldEntity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fieldDescription)
        hasher.combine(fieldId)
        hasher.combine(fieldLength)
    }
}
