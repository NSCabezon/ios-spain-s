import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

final class LegacySCAEntity {
    private let scaRepresentable: SCARepresentable
    
    init(_ representable: SCARepresentable) {
        self.scaRepresentable = representable
    }
    
    var sca: SCA {
        return self.mapSCA(self.scaRepresentable)
    }
}

private extension LegacySCAEntity {
    
    func mapSCA(_ scaRepresentable: SCARepresentable) -> SCA {
        switch scaRepresentable.type {
        case .none(let value):
            return SCANoneWithResponse(value: value)
        case .signature(let dto):
            return Signature(dto)
        case .signatureWithToken(let dto):
            return SignatureWithToken(dto)!
        case .otp(let dto):
            return self.mapOTP(dto)
        case .signatureAndOTP(let dto):
            return SignatureAndOTP(signature: self.mapSCA(dto.signature))
        case .oap(let authorizationId):
            return OAPEntity(authorizationId: authorizationId)
        }
    }
    
    func mapOTP(_ dto: OTPValidationRepresentable) -> SCA {
        if dto.otpExcepted  {
            return OTP.userExcepted(OTPValidation(dto))
        } else {
            return OTP.validation(OTPValidation(dto))
        }
    }
}

