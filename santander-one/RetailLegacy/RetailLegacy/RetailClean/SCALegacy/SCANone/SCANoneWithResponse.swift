//
//  SCANoneWithResponse.swift
//  RetailLegacy
//
//  Created by Juan Carlos López Robles on 3/1/21.
//

import Foundation
import CoreFoundationLib

final class SCANoneWithResponse {
    private let value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    func getResponse<T: DTOInstantiable>() -> T {
        guard let dto = self.value as? T.DTO else {
            fatalError()
        }
        return T(dto)
    }
}
