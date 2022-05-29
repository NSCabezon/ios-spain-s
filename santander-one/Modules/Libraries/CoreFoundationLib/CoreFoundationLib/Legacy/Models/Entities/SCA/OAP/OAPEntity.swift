//
//  OAPEntity.swift
//  Models
//
//  Created by Carlos Monfort Gómez on 26/10/21.
//

import Foundation

public final class OAPEntity {
    private let authorizationId: String
    
    public init(authorizationId: String) {
        self.authorizationId = authorizationId
    }
}

extension OAPEntity: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCAOAPCapable)?.prepareForOAP(self.authorizationId)
    }
}
