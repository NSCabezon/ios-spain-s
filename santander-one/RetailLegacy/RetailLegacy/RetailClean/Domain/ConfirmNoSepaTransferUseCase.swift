import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmNoSepaTransferUseCase: ConfirmUseCase<ConfirmNoSepaTransferUseCaseInput, ConfirmNoSepaTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmNoSepaTransferUseCaseInput) throws -> UseCaseResponse<ConfirmNoSepaTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let noSepaTransferValidation = requestValues.noSepaTransferValidation
        noSepaTransferValidation.signature = requestValues.signature
        let response = try bsanManagersProvider.getBsanTransfersManager().validationOTPIntNoSEPA(
            validationIntNoSepaDTO: noSepaTransferValidation.dto,
            noSepaTransferInput: requestValues.toNoSepaTransferInput(beneficiaryAccount: requestValues.beneficiaryAccount, beneficiaryAddress: requestValues.beneficiaryAddress)
        )
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ConfirmNoSepaTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ConfirmNoSepaTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmNoSepaTransferUseCaseInput: NoSEPATransferInputConvertible {
    let signature: Signature
    let originAccount: Account
    let beneficiary: String
    let beneficiaryAccount: InternationalAccount
    let beneficiaryAddress: Address?
    let dateOperation: Date?
    let transferAmount: Amount
    let expensiveIndicator: NoSepaTransferExpenses
    let countryCode: String
    let concept: String
    let noSepaTransferValidation: NoSepaTransferValidation
}

struct ConfirmNoSepaTransferUseCaseOkOutput {
    let otp: OTP
}
