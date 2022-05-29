
import CoreDomain

public protocol BSANSignatureManager {
    func getCMCSignature() throws -> BSANResponse<SignStatusInfo>
    func loadCMCSignature() throws -> BSANResponse<Void>
    func validateSignatureActivation() throws -> BSANResponse<SignatureWithTokenDTO>
    func validateOTPOperability(newOperabilityInd: String, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO>
    func confimOperabilityChange(newOperabilityInd: String, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void>
    func confirmSignatureActivation(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func confirmSignatureChange(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func changePassword(oldPassword: String, newPassword: String) throws -> BSANResponse<Void>
    func consultPensionSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultSendMoneySignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultCardsPayOffSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultCashWithdrawalSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultChangeSignSignaturePositions() throws -> BSANResponse<SCARepresentable>
    func consultScheduledSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultCardLimitManagementPositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func requestOTPPushRegisterDevicePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func consultBillAndTaxesSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO>
    func requestApplePaySignaturePositions( )throws -> BSANResponse<SignatureWithTokenDTO>
}
