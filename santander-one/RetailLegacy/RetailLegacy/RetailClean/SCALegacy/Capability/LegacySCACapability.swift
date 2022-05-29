//
//  SCACapability.swift
//  RetailLegacy
//
//  Created by Juan Carlos López Robles on 3/1/21.
//

import Foundation
import CoreFoundationLib

protocol SCANoneWithResponseCapable: SCACapable {
    func prepareForSCANone(_ scaNone: SCANoneWithResponse)
}

protocol SCASignatureCapable: SCACapable {
    func prepareForSignature(_ signature: Signature)
}

protocol SCASignatureWithTokenCapable: SCACapable {
    func prepareForSignatureWithToken(_ signature: SignatureWithToken)
}

protocol SCAOTPCapable {
    func prepareForOTP(_ otp: OTP?)
}
