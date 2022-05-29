import CoreDomain
import Foundation
import OpenCombine

public protocol SantanderKeyOnboardingRepository {
    // Client Status
    func getClientStatusReactive(santanderKeyID: String?, deviceId: String?) -> AnyPublisher<SantanderKeyStatusRepresentable, Error>
    func getClientStatus(santanderKeyID: String?, deviceId: String?) throws -> SantanderKeyStatusRepresentable
    // Update Token push
    func updateTokenPushReactive(input: SantanderKeyUpdateTokenPushInput, signature: String) -> AnyPublisher<Void, Error>
    func updateTokenPush(input: SantanderKeyUpdateTokenPushInput, signature: String) throws -> Void
    // Automatic Register
    func automaticRegisterReactive(deviceId: String, tokenPush: String, publicKey: String, signature: String) -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error>
    func automaticRegister(deviceId: String, tokenPush: String, publicKey: String, signature: String) throws -> SantanderKeyAutomaticRegisterResultRepresentable
    // Register
    func registerGetAuthMethodReactive() -> AnyPublisher<(SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable), Error>
    func registerGetAuthMethod() throws -> (SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable)
    func registerValidationWithPINReactive(sanKeyId: String, cardPan: String, cardType: String, pin: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error>
    func registerValidationWithPIN(sanKeyId: String, cardPan: String, cardType: String, pin: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable)
    func registerValidationWithPositionsReactive(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error>
    func registerValidationWithPositions(sanKeyId: String, positions: String, valuePositions: String) throws -> (SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable)
    func registerConfirmationReactive(input: SantanderKeyRegisterConfirmationInput, signature: String) -> AnyPublisher<SantanderKeyRegisterConfirmationResultRepresentable, Error>
    func registerConfirmation(input: SantanderKeyRegisterConfirmationInput, signature: String) throws -> SantanderKeyRegisterConfirmationResultRepresentable
    // Detail
    func getSantanderKeyDetailReactive(sanKeyId: String?) -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error>
    func getSantanderKeyDetail(sanKeyId: String?) throws -> SantanderKeyDetailResultRepresentable
}
