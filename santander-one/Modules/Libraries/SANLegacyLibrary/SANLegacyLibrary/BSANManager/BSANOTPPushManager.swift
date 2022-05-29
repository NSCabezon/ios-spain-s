public protocol BSANOTPPushManager {
    func requestDevice() throws -> BSANResponse<OTPPushDeviceDTO>
    func validateRegisterDevice(signature: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func registerDevice(otpValidation: OTPValidationDTO, otpCode: String, data: OTPPushConfirmRegisterDeviceInputDTO) throws -> BSANResponse<ConfirmOTPPushDTO>
    func updateTokenPush(currentToken: String, newToken: String) throws -> BSANResponse<Void>
    func validateDevice(deviceToken: String) throws -> BSANResponse<OTPPushValidateDeviceDTO>
    func getValidatedDeviceState() throws -> BSANResponse<ReturnCodeOTPPush>
}
