//
//  SignatureWithOTP.swift
//  SANLegacyLibrary
//
//  Created by Juan Carlos López Robles on 3/1/21.
//

import CoreDomain

public struct SignatureAndOTP: SignatureAndOTPRepresentable {
    public let signature: SCARepresentable
    
    public init(signature: SCARepresentable) {
        self.signature = signature
    }
}

extension SignatureAndOTP: SCARepresentable {
    public var type: SCARepresentableType {
        return .signatureAndOTP(self)
    }
}
