import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Operative

class ConfirmOTPPeriodicInternalTransferUseCase: UseCase<ConfirmOTPInternalTransferUseCaseInput, Void, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol {
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOTPInternalTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let pgResponse = try self.provider.getBsanPGManager().getGlobalPosition()
        guard case .periodic(startDate: let startDate, endDate: let endDate, periodicity: let periodicity, workingDayIssue: let workingDayIssue) = requestValues.time, pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        guard let otpValidation = requestValues.otpValidation, let code = requestValues.code, let originAccount = requestValues.originAccount, let amount = requestValues.amount else {
                return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        guard let iban = requestValues.destinationAccount?.getIban() else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        let endDateValue: DateModel?
        switch endDate {
        case .never:
            endDateValue = nil
        case .date(let date):
            endDateValue = DateModel(date: date)
        }
        let scheduledTransfer = requestValues.scheduledTransfer
        let scheduledTransferInput = ScheduledTransferInput(
            dateStartValidity: DateModel(date: startDate),
            dateEndValidity: endDateValue,
            scheduledDayType: workingDayIssue.dto,
            periodicalType: periodicity.dto,
            indicatorResidence: true,
            concept: requestValues.concept,
            dateNextExecution: nil,
            currency: amount.dto.currency?.getSymbol() ?? "",
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.dto,
            saveAsUsual: false,
            saveAsUsualAlias: nil,
            beneficiary: pgData.clientName,
            transferAmount: amount.dto,
            company: nil,
            subType: .NATIONAL_TRANSFER
        )
        let response = try provider.getBsanTransfersManager().confirmScheduledTransfer(originAccountDTO: originAccount.dto, scheduledTransferInput: scheduledTransferInput, otpValidationDTO: otpValidation.dto, otpCode: code)
        if response.isSuccess() {
            return .ok()
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}
