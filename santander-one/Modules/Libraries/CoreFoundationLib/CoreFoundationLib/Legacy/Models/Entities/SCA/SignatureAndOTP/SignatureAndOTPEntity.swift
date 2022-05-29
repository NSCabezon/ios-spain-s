//
//  SignatureAndOTPEntity.swift
//  RetailLegacy
//
//  Created by Juan Carlos López Robles on 3/1/21.
//

import CoreDomain

public class SignatureAndOTPEntity {
    public let signature: SCA
    
    public init(signature: SCA) {
        self.signature = signature
    }
}

extension SignatureAndOTPEntity: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        self.signature.prepareForVisitor(visitor)
        (visitor as? SCAOTPCapable)?.prepareForOTP(nil)
    }
}
