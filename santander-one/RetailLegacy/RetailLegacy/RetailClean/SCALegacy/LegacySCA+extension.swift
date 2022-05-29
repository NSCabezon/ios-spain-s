//
//  SCA.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/14/21.
//

import Foundation
import CoreFoundationLib

extension SCANoneWithResponse: SCA {
    func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCANoneWithResponseCapable)?.prepareForSCANone(self)
    }
}

extension Signature: SCA {
    func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCASignatureCapable)?.prepareForSignature(self)
    }
}

extension OTP: SCA {
    func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCAOTPCapable)?.prepareForOTP(self)
    }
}

extension SignatureWithToken: SCA {
    func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCASignatureWithTokenCapable)?.prepareForSignatureWithToken(self)
    }
}

extension SignatureAndOTP: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        self.signature.prepareForVisitor(visitor)
        (visitor as? SCAOTPCapable)?.prepareForOTP(nil)
    }
}
