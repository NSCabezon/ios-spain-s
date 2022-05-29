import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetScheduledTransferDetailUseCase: UseCase<GetScheduledTransferDetailUseCaseInput, GetScheduledTransferDetailUseCaseOkOutput, GetScheduledTransferDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let sepaRepository: SepaInfoRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, sepaRepository: SepaInfoRepository, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.sepaRepository = sepaRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetScheduledTransferDetailUseCaseInput) throws -> UseCaseResponse<GetScheduledTransferDetailUseCaseOkOutput, GetScheduledTransferDetailUseCaseErrorOutput> {

        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.getScheduledTransferDetail(account: requestValues.account.accountDTO, transferScheduledDTO: requestValues.transfer.transferDTO)

        if response.isSuccess() {
            let result: ScheduledTransferDetail?
            if let data = try response.getResponseData() {
                result = ScheduledTransferDetail.create(data)
            } else {
                result = nil
            }

            let sepaListDTO = sepaRepository.get()
            let sepaList = SepaInfoList(dto: sepaListDTO)
            guard sepaList.allCurrencies.count > 0, sepaList.allCurrencies.count > 0 else {
                return UseCaseResponse.error(GetScheduledTransferDetailUseCaseErrorOutput(nil))
            }

            return UseCaseResponse.ok(GetScheduledTransferDetailUseCaseOkOutput(scheduledTransferDetail: result, sepaList: sepaList))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""

            return UseCaseResponse.error(GetScheduledTransferDetailUseCaseErrorOutput(errorDescription))
        }
    }
}

struct GetScheduledTransferDetailUseCaseInput {
    let account: Account
    let transfer: TransferScheduled
}

struct GetScheduledTransferDetailUseCaseOkOutput {
    let scheduledTransferDetail: ScheduledTransferDetail?
    let sepaList: SepaInfoList
}

class GetScheduledTransferDetailUseCaseErrorOutput: StringErrorOutput {
    
}
