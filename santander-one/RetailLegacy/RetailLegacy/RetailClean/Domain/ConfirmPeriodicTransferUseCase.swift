import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

class ConfirmPeriodicTransferUseCase: UseCase<ConfirmPeriodicTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmPeriodicTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        
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
        
        let response = try bsanManagersProvider.getBsanTransfersManager().confirmModifyPeriodicTransfer(originAccountDTO: requestValues.account.accountDTO, modifyScheduledTransferInput: modifyScheduledTransferInput, modifyPeriodicTransferDTO: requestValues.modifyPeriodicTransfer.dto, transferScheduledDTO: requestValues.scheduledTransfer.transferDTO, transferScheduledDetailDTO: requestValues.scheduledTransferDetail.transferDetailDTO, otpValidationDTO: requestValues.otpValidation.otpValidationDTO, otpCode: requestValues.code, scheduledDayType: requestValues.modifiedData.workingDayIssue.dto)
        
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        
        return .ok()
    }
    
    private func transferOperationType(for country: SepaCountryInfo) -> TransferOperationType {
        return country.code.lowercased() == "es" ? .NATIONAL_SEPA : .INTERNATIONAL_SEPA
    }
}
struct ConfirmPeriodicTransferUseCaseInput {
    let account: Account
    let scheduledTransfer: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
    let modifyPeriodicTransfer: ModifyPeriodicTransfer
    let modifiedData: ModifiedPeriodicTransfer
    let otpValidation: OTPValidation
    let code: String
    let country: SepaCountryInfo
}
