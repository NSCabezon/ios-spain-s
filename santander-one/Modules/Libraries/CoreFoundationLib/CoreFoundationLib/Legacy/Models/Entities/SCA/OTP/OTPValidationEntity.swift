//
//  OTPValidation.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/12/2019.
//

import SANLegacyLibrary
import CoreDomain

final public class OTPValidationEntity {
    
    public let otpValidationRepresentable: OTPValidationRepresentable
    public var dto: OTPValidationDTO {
        return otpValidationRepresentable as? OTPValidationDTO ?? OTPValidationDTO(magicPhrase: otpValidationRepresentable.magicPhrase,
                                                                                   ticket: otpValidationRepresentable.ticket,
                                                                                   otpExcepted: otpValidationRepresentable.otpExcepted)
    }
    
    public init(_ representable: OTPValidationRepresentable) {
        self.otpValidationRepresentable = representable
    }
    
    public var magicPhrase: String? {
        dto.magicPhrase
    }
    
    public var ticket: String? {
        dto.ticket
    }
    
    public var isOTPExcepted: Bool {
        dto.otpExcepted
    }
}

extension OTPValidationEntity: SCA {
    public func prepareForVisitor(_ visitor: SCACapable) {
        (visitor as? SCAOTPCapable)?.prepareForOTP(self)
    }
}
