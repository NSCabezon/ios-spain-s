import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetAllUsualTransfersUseCase: UseCase<Void, GetAllUsualTransfersUseCaseOkOutput, GetAllUsualTransfersUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAllUsualTransfersUseCaseOkOutput, GetAllUsualTransfersUseCaseErrorOutput> {
        let bsanTransfersManager = bsanManagersProvider.getBsanTransfersManager()
        let bsanResponse = try bsanTransfersManager.loadAllUsualTransfers()
        
        if bsanResponse.isSuccess(), let transfersDTO = try bsanResponse.getResponseData() {
            let transfers = transfersDTO.map { Favourite.create($0) }
            return UseCaseResponse.ok(GetAllUsualTransfersUseCaseOkOutput(transfers: transfers))
        }
        return UseCaseResponse.error(GetAllUsualTransfersUseCaseErrorOutput(try bsanResponse.getErrorMessage()))
    }
    
}

struct GetAllUsualTransfersUseCaseOkOutput {
    let transfers: [Favourite]
}

class GetAllUsualTransfersUseCaseErrorOutput: StringErrorOutput {}
