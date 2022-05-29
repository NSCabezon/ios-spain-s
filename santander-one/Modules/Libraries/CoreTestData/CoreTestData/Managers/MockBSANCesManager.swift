import SANLegacyLibrary

struct MockBSANCesManager: BSANCesManager {
    func validateOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO, phone: String) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmOTP(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        fatalError()
    }
}
