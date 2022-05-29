import CoreFoundationLib
import SANLegacyLibrary

class ValidateDeferredTransferUseCase: UseCase<ValidateDeferredTransferUseCaseInput, ValidateDeferredTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateDeferredTransferUseCaseInput) throws -> UseCaseResponse<ValidateDeferredTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let response = try provider.getBsanTransfersManager().validateModifyDeferredTransfer(originAccountDTO: requestValues.account.accountDTO, modifyScheduledTransferInput: requestValues.modifyScheduledTransferInput, modifyDeferredTransferDTO: requestValues.modifyDeferredTransfer.dto, transferScheduledDetailDTO: requestValues.transferScheduledDetail.transferDetailDTO)
        
        guard response.isSuccess(), try response.getResponseData() != nil else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateDeferredTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidateDeferredTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ValidateDeferredTransferUseCaseInput {
    let account: Account
    let modifyScheduledTransferInput: ModifyScheduledTransferInput
    let modifyDeferredTransfer: ModifyDeferredTransfer
    let transferScheduledDetail: ScheduledTransferDetail
}

struct ValidateDeferredTransferUseCaseOkOutput {
    let otp: OTP
}
