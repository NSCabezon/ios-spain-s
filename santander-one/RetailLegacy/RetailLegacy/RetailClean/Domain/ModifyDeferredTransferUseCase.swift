import SANLegacyLibrary
import CoreFoundationLib

class ModifyDeferredTransferUseCase: UseCase<ModifyDeferredTransferUseCaseInput, ModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: ModifyDeferredTransferUseCaseInput) throws -> UseCaseResponse<ModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
        let response = try provider.getBsanTransfersManager().modifyDeferredTransferDetail(originAccountDTO: requestValues.account.accountDTO, transferScheduledDTO: requestValues.transferScheduled.transferDTO, transferScheduledDetailDTO: requestValues.scheduledTransferDetail.transferDetailDTO)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        
        guard let signatureDTO = data.signatureDTO else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }

        return UseCaseResponse.ok(ModifyDeferredTransferUseCaseOkOutput(modifyDeferredTransfer: ModifyDeferredTransfer(dto: data), signature: Signature(dto: signatureDTO)))
    }
}

struct ModifyDeferredTransferUseCaseInput {
    let account: Account
    let transferScheduled: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
}

struct ModifyDeferredTransferUseCaseOkOutput {
    let modifyDeferredTransfer: ModifyDeferredTransfer
    let signature: Signature
}
