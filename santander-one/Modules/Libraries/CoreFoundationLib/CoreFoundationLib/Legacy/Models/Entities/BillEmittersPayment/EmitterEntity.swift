//
//  EmitterEntity.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/18/20.
//

import Foundation
import SANLegacyLibrary

public final class EmitterEntity: DTOInstantiable {
    public var dto: EmitterDTO
    
    public init(_ dto: EmitterDTO) {
        self.dto = dto
    }
    
    public var name: String {
        return self.dto.name
    }
    
    public var code: String {
        return self.dto.code
    }
}

extension EmitterEntity: Hashable {
    public static func == (lhs: EmitterEntity, rhs: EmitterEntity) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.code)
    }
}

public final class IncomeEntity: DTOInstantiable {
    public var dto: BillCollectionDTO
    
    public init(_ dto: BillCollectionDTO) {
          self.dto = dto
    }
    
    public var productIdentifier: String {
        return self.dto.productIdentifier
    }
    public var typeCode: String {
        return self.dto.typeCode
    }
    public var code: String {
        return self.dto.code
    }
    public var description: String {
        return self.dto.description
    }
    public var operationTypeCode: String {
        return self.dto.operationTypeCode
    }
    public var indicatorModifiesAmount: String {
        return self.dto.indicatorModifiesAmount
    }
    public var indicatorModifiesCurrency: String {
        return self.dto.indicatorModifiesCurrency
    }
}
