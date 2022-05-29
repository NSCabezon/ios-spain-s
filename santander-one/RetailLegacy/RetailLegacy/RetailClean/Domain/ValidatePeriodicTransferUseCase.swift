import CoreDomain
import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidatePeriodicTransferUseCase: UseCase<ValidatePeriodicTransferUseCaseInput, ValidatePeriodicTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ValidatePeriodicTransferUseCaseInput) throws -> UseCaseResponse<ValidatePeriodicTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        
        let endDateValidity: DateModel?
        switch requestValues.modifiedData.endDate {
        case .never:
            endDateValidity = nil
        case .date(let date):
            endDateValidity = DateModel(date: date)
        }
        
        let modifyScheduledTransferInput = ModifyScheduledTransferInput(
            beneficiaryIBAN: requestValues.modifiedData.iban.ibanDTO,
            nextExecutionDate: DateModel(date: requestValues.scheduledTransferDetail.nextExecutionDate ?? DomainConstant.periodicTransferMinimumDate),
            amount: requestValues.modifiedData.amount.amountDTO,
            concept: requestValues.modifiedData.concept ?? "",
            beneficiary: requestValues.scheduledTransferDetail.beneficiaryName ?? "",
            transferOperationType: transferOperationType(for: requestValues.country),
            startDateValidity: DateModel(date: requestValues.modifiedData.startDate),
            endDateValidity: endDateValidity,
            periodicalType: requestValues.modifiedData.periodicity.dto,
            scheduledDayType: requestValues.modifiedData.workingDayIssue.dto
        )
        
        let response = try bsanManagersProvider.getBsanTransfersManager().validateModifyPeriodicTransfer(originAccountDTO: requestValues.account.accountDTO, modifyScheduledTransferInput: modifyScheduledTransferInput, modifyPeriodicTransferDTO: requestValues.modifyPeriodicTransfer.dto, transferScheduledDetailDTO: requestValues.scheduledTransferDetail.transferDetailDTO)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidatePeriodicTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return .ok(ValidatePeriodicTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
    
    private func transferOperationType(for country: SepaCountryInfo) -> TransferOperationType {
        return country.code.lowercased() == "es" ? .NATIONAL_SEPA : .INTERNATIONAL_SEPA
    }
}

struct ValidatePeriodicTransferUseCaseInput {
    let account: Account
    let scheduledTransfer: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
    let modifyPeriodicTransfer: ModifyPeriodicTransfer
    let modifiedData: ModifiedPeriodicTransfer
    let country: SepaCountryInfo
}

struct ValidatePeriodicTransferUseCaseOkOutput {
    let otp: OTP
}
