import SANLegacyLibrary

struct MockBSANMobileRechargeManager: BSANMobileRechargeManager {
    func getMobileOperators(card: CardDTO) throws -> BSANResponse<MobileOperatorListDTO> {
        fatalError()
    }
    
    func validateMobileRecharge(card: CardDTO) throws -> BSANResponse<ValidateMobileRechargeDTO> {
        fatalError()
    }
    
    func validateMobileRechargeOTP(card: CardDTO, signature: SignatureWithTokenDTO, mobile: String, amount: AmountDTO, mobileOperatorDTO: MobileOperatorDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmMobileRecharge(card: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        fatalError()
    }
}
