import SANLegacyLibrary
import CoreFoundationLib

class ConfirmCreateNoSepaUsualTransferUseCase: UseCase<ConfirmCreateNoSepaUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmCreateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        
        let response = try provider.getBsanTransfersManager().confirmCreateNoSepaPayee(otpValidationDTO: requestValues.otp.otpValidationDTO, otpCode: requestValues.code ?? "")
        
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        
        return UseCaseResponse.ok()
    }
}

struct ConfirmCreateNoSepaUsualTransferUseCaseInput {
    let otp: OTPValidation
    let code: String?
}
