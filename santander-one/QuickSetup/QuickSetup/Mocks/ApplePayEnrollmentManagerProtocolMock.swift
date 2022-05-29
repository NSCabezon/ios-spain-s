//
//  ApplePayEnrollmentManagerProtocolMock.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 10/9/21.
//

import CoreFoundationLib

public class ApplePayEnrollmentManagerProtocolMock: ApplePayEnrollmentManagerProtocol {
    public func enrollCard(_ card: CardEntity, detail: CardDetailEntity, otpValidation: OTPValidationEntity, otpCode: String, completion: @escaping (Result<Void, Error>) -> Void) {}
    
    public func alreadyAddedPaymentPasses() -> [String] {
        return []
    }
    
    public func isEnrollingCardEnabled() -> Bool {
        return true
    }
}
