//
//  SCANoneWithResponse.swift
//  Operative
//
//  Created by Juan Carlos López Robles on 2/26/21.
//

import Foundation

public final class SCANoneWithResponseEntity {
    private let value: Any
    
    public init(value: Any) {
        self.value = value
    }
    
    public func getResponse<T: DTOInstantiable>() -> T {
        guard let dto = self.value as? T.DTO else {
            fatalError()
        }
        return T(dto)
    }
}

extension SCANoneWithResponseEntity: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCANoneWithResponseCapable)?.prepareForSCANone(self)
    }
}
