public protocol BSANScaManager {
    func checkSca() throws -> BSANResponse<CheckScaDTO>
    func loadCheckSca() throws -> BSANResponse<CheckScaDTO>
    func isScaOtpOkForAccounts() throws -> BSANResponse<Bool>
    func saveScaOtpLoginTemporaryBlock() throws
    func saveScaOtpAccountTemporaryBlock() throws
    func isScaOtpAskedForLogin() throws -> BSANResponse<Bool>
    func validateSca(forwardIndicator: Bool, foceSMS: Bool, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ValidateScaDTO>
    func confirmSca(tokenOTP: String?, ticketOTP: String?, codeOTP: String, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ConfirmScaDTO>
}

