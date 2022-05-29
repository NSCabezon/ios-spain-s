//
//  SCA.swift
//  Operative
//
//  Created by Juan Carlos López Robles on 2/23/21.
//

import CoreDomain

public protocol SCACapable {}

public protocol SCA {
    func prepareForVisitor(_ visitor: SCACapable)
}

public protocol SCANoneWithResponseCapable: SCACapable {
    func prepareForSCANone(_ scaNone: SCANoneWithResponseEntity)
}

public protocol SCASignatureCapable: SCACapable {
    func prepareForSignature(_ signature: SignatureRepresentable)
}

public protocol SCASignatureWithTokenCapable: SCACapable {
    func prepareForSignatureWithToken(_ signature: SignatureWithTokenEntity)
}

public protocol SCAOTPCapable {
    func prepareForOTP(_ otp: OTPValidationEntity?)
}

public protocol SCAOAPCapable {
    func prepareForOAP(_ authorizationId: String?)
}
