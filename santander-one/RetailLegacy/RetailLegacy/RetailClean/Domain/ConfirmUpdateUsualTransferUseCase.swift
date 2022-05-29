import SANLegacyLibrary
import CoreFoundationLib

class ConfirmUpdateUsualTransferUseCase: UseCase<ConfirmUpdateUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmUpdateUsualTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        
        let response = try provider.getBsanTransfersManager().confirmUpdateSepaPayee(otpValidationDTO: requestValues.otp.otpValidationDTO, otpCode: requestValues.code ?? "")
        
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        
        return UseCaseResponse.ok()
    }
}
struct ConfirmUpdateUsualTransferUseCaseInput {
    let otp: OTPValidation
    let code: String?
}
