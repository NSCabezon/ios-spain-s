import SANLegacyLibrary

struct MockBSANCashWithdrawalManager: BSANCashWithdrawalManager {
    func getCardDetailToken(cardDTO: CardDTO, cardTokenType: CardTokenType) throws -> BSANResponse<CardDetailTokenDTO> {
        fatalError()
    }
    
    func validatePIN(cardDTO: CardDTO, cardDetailTokenDTO: CardDetailTokenDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        fatalError()
    }
    
    func validateOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        fatalError()
    }
    
    func confirmOTP(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, amount: AmountDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<CashWithDrawalDTO> {
        fatalError()
    }
    
    func getHistoricalWithdrawal(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<HistoricalWithdrawalDTO> {
        fatalError()
    }
}
