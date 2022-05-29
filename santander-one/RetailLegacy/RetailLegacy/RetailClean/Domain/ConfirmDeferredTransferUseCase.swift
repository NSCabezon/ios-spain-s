import CoreFoundationLib
import SANLegacyLibrary

class ConfirmDeferredTransferUseCase: UseCase<ConfirmDeferredTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    init(appConfigRepository: AppConfigRepository, managersProvider: BSANManagersProvider, trusteerRepository: TrusteerRepositoryProtocol) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.trusteerRepository = dependenciesResolver.resolve()
    }
    
    var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessionId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersDeferred) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: ConfirmDeferredTransferUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let response = try provider.getBsanTransfersManager().confirmModifyDeferredTransfer(
            originAccountDTO: requestValues.account.accountDTO,
            modifyScheduledTransferInput: requestValues.modifyScheduledTransferInput,
            modifyDeferredTransferDTO: requestValues.modifyDeferredTransfer.dto,
            transferScheduledDTO: requestValues.transferScheduled.transferDTO,
            transferScheduledDetailDTO: requestValues.transferScheduledDetail.transferDetailDTO,
            otpValidationDTO: requestValues.otp.otpValidationDTO,
            otpCode: requestValues.code ?? "",
            trusteerInfo: trusteerInfo
        )
        guard response.isSuccess() else {
            let error = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(error, otpType, errorCode))
        }
        return UseCaseResponse.ok()
    }
}
struct ConfirmDeferredTransferUseCaseInput {
    let account: Account
    let modifyScheduledTransferInput: ModifyScheduledTransferInput
    let modifyDeferredTransfer: ModifyDeferredTransfer
    let transferScheduled: TransferScheduled
    let transferScheduledDetail: ScheduledTransferDetail
    let otp: OTPValidation
    let code: String?
}
