import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class GetFavoriteTransfersUseCase: UseCase<Void, GetFavoriteTransfersUseCaseOkOutput, GetFavoriteTransfersUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    private let sepaRepository: SepaInfoRepository
    
    init(managersProvider: BSANManagersProvider, sepaRepository: SepaInfoRepository) {
        self.provider = managersProvider
        self.sepaRepository = sepaRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFavoriteTransfersUseCaseOkOutput, GetFavoriteTransfersUseCaseErrorOutput> {
        let transferManager = provider.getBsanTransfersManager()
        let response = try transferManager.getUsualTransfers()
        if response.isSuccess() {
            let list = try response.getResponseData() ?? []
            var result = [Favourite]()
            let sepaListDTO = sepaRepository.get()
            let sepaList = SepaInfoList(dto: sepaListDTO)
            for favourite in list {
                result.append(Favourite.create(favourite))
            }
            return UseCaseResponse.ok(GetFavoriteTransfersUseCaseOkOutput(favoriteList: result, sepaInfoList: sepaList))
        } else {
            let errorDescription = try response.getErrorMessage() ?? ""
            
            return UseCaseResponse.error(GetFavoriteTransfersUseCaseErrorOutput(errorDescription))
        }
    }
    
}

struct GetFavoriteTransfersUseCaseOkOutput {
    let favoriteList: [Favourite]
    let sepaInfoList: SepaInfoList
}

class GetFavoriteTransfersUseCaseErrorOutput: StringErrorOutput {
    
}
