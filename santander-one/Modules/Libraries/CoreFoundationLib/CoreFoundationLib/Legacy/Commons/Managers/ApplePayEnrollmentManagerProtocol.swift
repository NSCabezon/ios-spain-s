import Foundation

public protocol ApplePayEnrollmentManagerProtocol {
    func enrollCard(_ card: CardEntity, detail: CardDetailEntity, otpValidation: OTPValidationEntity, otpCode: String, completion: @escaping (Result<Void, Error>) -> Void)
    func alreadyAddedPaymentPasses() -> [String]
    func isEnrollingCardEnabled() -> Bool
}
