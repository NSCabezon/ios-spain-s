import SANLegacyLibrary
import CoreFoundationLib

class ConfirmCreateUsualTransferUseCase: UseCase<ConfirmCreateUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCreateUsualTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        
        let response = try provider.getBsanTransfersManager().confirmCreateSepaPayee(otpValidationDTO: requestValues.otp.otpValidationDTO, otpCode: requestValues.code ?? "")
        
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        
        return UseCaseResponse.ok()
    }
}

struct ConfirmCreateUsualTransferUseCaseInput {
    let otp: OTPValidation
    let code: String?
}
