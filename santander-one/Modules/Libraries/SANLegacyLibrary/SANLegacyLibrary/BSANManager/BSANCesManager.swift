public protocol BSANCesManager {
    func validateOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO, phone: String) throws -> BSANResponse<OTPValidationDTO>
    func confirmOTP(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
}
