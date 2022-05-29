//
//  SantanderKeyRegisterValidationWithPINUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 10/3/22.
//

import OpenCombine
import CoreDomain
import SANSpainLibrary
import SwiftyRSA

public protocol SantanderKeyRegisterValidationWithPINUseCase {
    func registerValidationPIN(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error>
}

struct DefaultSantanderKeyRegisterValidationWithPINUseCase {
    private var repository: SantanderKeyOnboardingRepository
    
    init(dependencies: SKExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultSantanderKeyRegisterValidationWithPINUseCase: SantanderKeyRegisterValidationWithPINUseCase {
    
    func registerValidationPIN(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        let encriptedPin = encryptPIN(pin)
        return repository.registerValidationWithPINReactive(sanKeyId: sanKeyId, cardPan: cardPan, cardType: cardType, pin: encriptedPin).eraseToAnyPublisher()
    }
}

private extension DefaultSantanderKeyRegisterValidationWithPINUseCase {
    func encryptPIN(_ pin: String) -> String {
        let pinPublicKey = """
        -----BEGIN RSA PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw799cpi7Sbga2YDR5ma/
        tzglZSGJRxqaz2FVY+uFHVe0Nz+dhwFviKs/rUs4H9qMQi+nQR7okpdAT9+ArwwA
        PqR2ijsxOjXl3bnFBsGtm10/j5lqVBAkfgFvk8NDTSWg5DXRBLijfC8kmeAV2gT1
        55Bzm3zxOu56FdWiX7cUWP4euEUk6vOVPO7lSggUfG07p8b4bbJ/3Fq8IliTwrIM
        iyiptE+gfT+veN/ReVAyBx+r0KHG8O42vCVzV/MDinnTvet+rG00Ni5kmTHtLun1
        a09Kq8hnY7cnMoch5RIu3TlDjUEaURIDYybYLhxplBl4sORMJa0WYC4T3Mpo0VZO
        QQIDAQAB
        -----END RSA PUBLIC KEY-----
        """

        guard let publicKey = try? PublicKey(pemEncoded: pinPublicKey),
              let clear = try? ClearMessage(string: pin, using: .utf8),
              let encrypted = try? clear.encrypted(with: publicKey, padding: .PKCS1) else { return "" }

        return encrypted.base64String
    }
}
