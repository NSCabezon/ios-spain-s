import SANLegacyLibrary

struct MockBSANOTPPushManager: BSANOTPPushManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func requestDevice() throws -> BSANResponse<OTPPushDeviceDTO> {
        let dto = self.mockDataInjector.mockDataProvider.otpPushData.requestDevice
        return BSANOkResponse(dto)
    }
    
    func validateRegisterDevice(signature: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.otpPushData.validateRegisterDevice
        return BSANOkResponse(dto)
    }
    
    func registerDevice(otpValidation: OTPValidationDTO, otpCode: String, data: OTPPushConfirmRegisterDeviceInputDTO) throws -> BSANResponse<ConfirmOTPPushDTO> {
        let dto = self.mockDataInjector.mockDataProvider.otpPushData.registerDevice
        return BSANOkResponse(dto)
    }
    
    func updateTokenPush(currentToken: String, newToken: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func validateDevice(deviceToken: String) throws -> BSANResponse<OTPPushValidateDeviceDTO> {
        let dto = self.mockDataInjector.mockDataProvider.otpPushData.validateDevice
        return BSANOkResponse(dto)
    }
    
    func getValidatedDeviceState() throws -> BSANResponse<ReturnCodeOTPPush> {
        let dto = self.mockDataInjector.mockDataProvider.otpPushData.getValidatedDeviceState
        return BSANOkResponse(dto)
    }
}
