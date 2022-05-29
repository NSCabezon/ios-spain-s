import CoreFoundationLib
import SANLegacyLibrary


class SetUpCancelTransferUseCase: SetupUseCase<SetUpCancelTransferUseCaseInput, SetUpCancelTransferUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appRepository: AppRepository, managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetUpCancelTransferUseCaseInput) throws -> UseCaseResponse<SetUpCancelTransferUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let transferScheduled = requestValues.transferScheduled
        let account = requestValues.account
        let scheduledTransferDetail: ScheduledTransferDetail
        
        if let expectedTransfer = requestValues.scheduledTransferDetail {
            scheduledTransferDetail = expectedTransfer
            
        } else {
            let transferDetailResponse = try bsanManagersProvider.getBsanTransfersManager().getScheduledTransferDetail(account: account.accountDTO, transferScheduledDTO: transferScheduled.transferDTO)
            
            guard transferDetailResponse.isSuccess(), let dto = try transferDetailResponse.getResponseData() else {
                return UseCaseResponse.error(StringErrorOutput(try transferDetailResponse.getErrorMessage()))
            }
            
            scheduledTransferDetail = ScheduledTransferDetail.create(dto)
        }
        
        let response = try bsanManagersProvider.getBsanSignatureManager().consultScheduledSignaturePositions()
        
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
        }
        
        guard let signatureWithToken = SignatureWithToken(dto: dto) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        return UseCaseResponse.ok(SetUpCancelTransferUseCaseOkOutput(operativeConfig: operativeConfig, scheduledTransferDetail: scheduledTransferDetail, signatureToken: signatureWithToken))
    }
}

struct SetUpCancelTransferUseCaseInput {
    let transferScheduled: TransferScheduled
    let account: Account
    let scheduledTransferDetail: ScheduledTransferDetail?
}

struct SetUpCancelTransferUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    let scheduledTransferDetail: ScheduledTransferDetail
    let signatureToken: SignatureWithToken
}
