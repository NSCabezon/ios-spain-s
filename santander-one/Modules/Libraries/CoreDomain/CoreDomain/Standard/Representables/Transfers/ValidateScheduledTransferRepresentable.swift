//
//  ValidateScheduledTransferRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//

import Foundation

public protocol ValidateScheduledTransferRepresentable {
    var scaRepresentable: SCARepresentable? { get }
    var lengthSignature: String? { get }
    var serTuBancoBelongs: String? { get }
    var nameBeneficiaryBank: String? { get }
    var dataMagicPhrase: String? { get }
    var actuanteCode: String? { get }
    var actuanteNumber: String? { get }
    var actuanteCompany: String? { get }
    var bankChargeAmountRepresentable: AmountRepresentable? { get }
}

public extension ValidateScheduledTransferRepresentable {
    var bankChargeAmountRepresentable: AmountRepresentable? { nil }
}

public protocol SCARepresentable {
    var type: SCARepresentableType { get }
}

public enum SCARepresentableType {
    case oap(String)
    case signature(SignatureRepresentable)
    case signatureWithToken(SignatureWithTokenRepresentable)
    case otp(OTPValidationRepresentable)
    case signatureAndOTP(SignatureAndOTPRepresentable)
    case none(Any)
}

public protocol SignatureWithTokenRepresentable  {
    var magicPhrase: String? { get }
    var signatureRepresentable: SignatureRepresentable? { get }
}

public protocol SignatureAndOTPRepresentable {
    var signature: SCARepresentable { get }
}

public protocol OAPRepresentable {
    var authorizationId: String? { get }
}
