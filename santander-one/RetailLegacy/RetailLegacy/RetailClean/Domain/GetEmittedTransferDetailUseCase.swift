import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetEmittedTransferDetailUseCase: UseCase<GetEmittedTransferDetailUseCaseInput, GetEmittedTransferDetailUseCaseOkOutput, GetEmittedTransferDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let sepaRepository: SepaInfoRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, sepaRepository: SepaInfoRepository, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.sepaRepository = sepaRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetEmittedTransferDetailUseCaseInput) throws -> UseCaseResponse<GetEmittedTransferDetailUseCaseOkOutput, GetEmittedTransferDetailUseCaseErrorOutput> {
        
        // Workaround for NoSepa transfers
        let transferDTO = requestValues.transfer.transferDTO
        guard transferDTO.amount?.currency?.currencyType == .eur, transferDTO.transferType != "NS" else {
            return .error(GetEmittedTransferDetailUseCaseErrorOutput("onePay_alert_emittedDetailNoSepa"))
        }
        
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.getEmittedTransferDetail(transferEmittedDTO: requestValues.transfer.transferDTO)
        
        if response.isSuccess() {
            let result: EmittedTransferDetail?
            if let data = try response.getResponseData() {
                result = EmittedTransferDetail.create(data)
            } else {
                result = nil
            }
            
            let sepaListDTO = sepaRepository.get()
            let sepaList = SepaInfoList(dto: sepaListDTO)
            guard sepaList.allCurrencies.count > 0, sepaList.allCurrencies.count > 0 else {
                return UseCaseResponse.error(GetEmittedTransferDetailUseCaseErrorOutput(nil))
            }
            return UseCaseResponse.ok(GetEmittedTransferDetailUseCaseOkOutput(transferEmittedDetail: result, sepaList: sepaList))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            
            return UseCaseResponse.error(GetEmittedTransferDetailUseCaseErrorOutput(errorDescription))
        }
    }
    
}

struct GetEmittedTransferDetailUseCaseInput {
    let transfer: TransferEmitted
}

struct GetEmittedTransferDetailUseCaseOkOutput {
    let transferEmittedDetail: EmittedTransferDetail?
    let sepaList: SepaInfoList
}

class GetEmittedTransferDetailUseCaseErrorOutput: StringErrorOutput {
    
}
