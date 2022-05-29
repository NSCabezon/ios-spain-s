import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import Operative

public protocol ConfirmOTPDeferredInternalTransferUseCaseProtocol: UseCase<ConfirmOTPInternalTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> { }

class ConfirmOTPDeferredInternalTransferUseCase: UseCase<ConfirmOTPInternalTransferUseCaseInput, Void, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.trusteerRepository = dependenciesResolver.resolve()
    }
    
    enum Constants {
        static let isTrusteerEnabled = "enableTrusteer"
        static let isTrusteerTransfersDeferredEnabled = "enableTrusteerTransfersDeferred"
    }
    
    private var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessiondId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(Constants.isTrusteerTransfersDeferredEnabled) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessiondId, appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: ConfirmOTPInternalTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let pgResponse = try self.provider.getBsanPGManager().getGlobalPosition()
        guard case .day(date: let date) = requestValues.time, let otpValidation = requestValues.otpValidation, let code = requestValues.code, let originAccount = requestValues.originAccount, let amount = requestValues.amount, pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        guard let iban = requestValues.destinationAccount?.getIban() else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        let scheduledTransfer = requestValues.scheduledTransfer
        let scheduledTransferInput = ScheduledTransferInput(
            dateStartValidity: nil,
            dateEndValidity: nil,
            scheduledDayType: nil,
            periodicalType: nil,
            indicatorResidence: true,
            concept: requestValues.concept,
            dateNextExecution: DateModel(date: date),
            currency: amount.dto.currency?.getSymbol() ?? "",
            nameBankIbanBeneficiary: scheduledTransfer?.nameBeneficiaryBank,
            actuanteCompany: scheduledTransfer?.company,
            actuanteCode: scheduledTransfer?.code,
            actuanteNumber: scheduledTransfer?.number,
            ibanDestination: iban.dto,
            saveAsUsual: false,
            saveAsUsualAlias: "",
            beneficiary: pgData.clientName,
            transferAmount: amount.dto,
            company: nil,
            subType: .NATIONAL_TRANSFER
        )
        let response = try provider.getBsanTransfersManager().confirmDeferredTransfer(
            originAccountDTO: originAccount.dto,
            scheduledTransferInput: scheduledTransferInput,
            otpValidationDTO: otpValidation.dto,
            otpCode: code,
            trusteerInfo: trusteerInfo
        )
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

extension ConfirmOTPDeferredInternalTransferUseCase: ConfirmOTPDeferredInternalTransferUseCaseProtocol { }
