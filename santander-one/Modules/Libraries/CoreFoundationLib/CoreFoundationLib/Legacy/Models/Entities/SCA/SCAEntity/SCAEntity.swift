//
//  SCAEntity.swift
//  Models
//
//  Created by Juan Carlos López Robles on 3/4/21.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public final class SCAEntity {
    private let scaRepresentable: SCARepresentable
    
    public init(_ representable: SCARepresentable) {
        self.scaRepresentable = representable
    }
    
    public var sca: SCA {
        return self.mapSCA(self.scaRepresentable)
    }
}

private extension SCAEntity {
    func mapSCA(_ scaRepresentable: SCARepresentable) -> SCA {
        switch scaRepresentable.type {
        case .none(let value):
            return SCANoneWithResponseEntity(value: value)
        case .signature(let dto):
            return SCARepresentableCapable(signatureRepresentable: dto)
        case .signatureWithToken(let dto):
            return SignatureWithTokenEntity(dto)!
        case .otp(let dto):
            return OTPValidationEntity(dto)
        case .signatureAndOTP(let dto):
            return SignatureAndOTPEntity(signature: self.mapSCA(dto.signature))
        case .oap(let authorizationId):
            return OAPEntity(authorizationId: authorizationId)
        }
    }
}

struct SCARepresentableCapable: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCASignatureCapable)?.prepareForSignature(signatureRepresentable)
    }
    
    let signatureRepresentable: SignatureRepresentable
}

public extension SCARepresentable {
    func mapSCA() -> SCA {
        switch self.type {
        case .none(let value):
            return SCANoneWithResponseEntity(value: value)
        case .signature(let dto):
            return SCARepresentableCapable(signatureRepresentable: dto)
        case .signatureWithToken(let dto):
            return SignatureWithTokenEntity(dto)!
        case .otp(let dto):
            return OTPValidationEntity(dto)
        case .signatureAndOTP(let dto):
            return SignatureAndOTPEntity(signature: dto.signature.mapSCA())
        case .oap(let authorizationId):
            return OAPEntity(authorizationId: authorizationId)
        }
    }
}
