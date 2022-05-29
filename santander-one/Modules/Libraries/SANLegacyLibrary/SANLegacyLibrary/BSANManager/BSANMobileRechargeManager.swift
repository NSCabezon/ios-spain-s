public protocol BSANMobileRechargeManager {
    func getMobileOperators(card: CardDTO) throws -> BSANResponse<MobileOperatorListDTO>
    func validateMobileRecharge(card: CardDTO) throws -> BSANResponse<ValidateMobileRechargeDTO>
    func validateMobileRechargeOTP(card: CardDTO, signature: SignatureWithTokenDTO, mobile: String, amount: AmountDTO, mobileOperatorDTO: MobileOperatorDTO) throws -> BSANResponse<OTPValidationDTO>
    func confirmMobileRecharge(card: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
}
