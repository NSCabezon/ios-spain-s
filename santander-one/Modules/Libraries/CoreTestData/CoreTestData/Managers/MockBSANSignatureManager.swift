import SANLegacyLibrary
import CoreDomain

struct MockBSANSignatureManager: BSANSignatureManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getCMCSignature() throws -> BSANResponse<SignStatusInfo> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.getCMCSignature
        return BSANOkResponse(dto)
    }
    
    func loadCMCSignature() throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func validateSignatureActivation() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.validateSignatureActivation
        return BSANOkResponse(dto)
    }
    
    func validateOTPOperability(newOperabilityInd: String, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.validateOTPOperability
        return BSANOkResponse(dto)
    }
    
    func confimOperabilityChange(newOperabilityInd: String, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmSignatureActivation(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmSignatureChange(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func changePassword(oldPassword: String, newPassword: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func consultPensionSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultPensionSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultSendMoneySignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultSendMoneySignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultCardsPayOffSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultCardsPayOffSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultCashWithdrawalSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultCashWithdrawalSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultChangeSignSignaturePositions() throws -> BSANResponse<SCARepresentable> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultChangeSignSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultScheduledSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultScheduledSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func consultCardLimitManagementPositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultCardLimitManagementPositions
        return BSANOkResponse(dto)
    }
    
    func requestOTPPushRegisterDevicePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.requestOTPPushRegisterDevicePositions
        return BSANOkResponse(dto)
    }
    
    func consultBillAndTaxesSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.consultBillAndTaxesSignaturePositions
        return BSANOkResponse(dto)
    }
    
    func requestApplePaySignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        let dto = self.mockDataInjector.mockDataProvider.signatureData.requestApplePaySignaturePositions
        return BSANOkResponse(dto)
    }
}
