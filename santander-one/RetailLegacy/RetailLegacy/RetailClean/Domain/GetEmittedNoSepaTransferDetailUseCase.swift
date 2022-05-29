import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetEmittedNoSepaTransferDetailUseCase: UseCase<GetEmittedNoSepaTransferDetailUseCaseInput, GetEmittedNoSepaTransferDetailUseCaseOkOutput, GetEmittedNoSepaTransferDetailUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let sepaRepository: SepaInfoRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, sepaRepository: SepaInfoRepository, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        self.sepaRepository = sepaRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: GetEmittedNoSepaTransferDetailUseCaseInput) throws -> UseCaseResponse<GetEmittedNoSepaTransferDetailUseCaseOkOutput, GetEmittedNoSepaTransferDetailUseCaseErrorOutput> {
        
        let transferDTO = requestValues.transfer.transferDTO
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.loadEmittedNoSepaTransferDetail(transferEmittedDTO: transferDTO)
        
        if response.isSuccess() {
            let result: EmittedNoSepaTransferDetail?
            if let noSepaTransferEmittedDetailDTO = try response.getResponseData() {
                result = EmittedNoSepaTransferDetail(dto: noSepaTransferEmittedDetailDTO)
            } else {
                result = nil
            }
            
            let sepaListDTO = sepaRepository.get()
            let sepaList = SepaInfoList(dto: sepaListDTO)
            guard sepaList.allCurrencies.count > 0, sepaList.allCurrencies.count > 0 else {
                return UseCaseResponse.error(GetEmittedNoSepaTransferDetailUseCaseErrorOutput(nil))
            }
            return UseCaseResponse.ok(GetEmittedNoSepaTransferDetailUseCaseOkOutput(noSepaTransferEmittedDetail: result, sepaList: sepaList))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            
            return UseCaseResponse.error(GetEmittedNoSepaTransferDetailUseCaseErrorOutput(errorDescription))
        }
    }    
}

struct GetEmittedNoSepaTransferDetailUseCaseInput {
    let transfer: TransferEmitted
}

struct GetEmittedNoSepaTransferDetailUseCaseOkOutput {
    let noSepaTransferEmittedDetail: EmittedNoSepaTransferDetail?
    let sepaList: SepaInfoList
}

class GetEmittedNoSepaTransferDetailUseCaseErrorOutput: StringErrorOutput {}
