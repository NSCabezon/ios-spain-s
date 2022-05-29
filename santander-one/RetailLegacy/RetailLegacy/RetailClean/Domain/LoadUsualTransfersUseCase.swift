import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadUsualTransfersUseCase: UseCase<Void, Void, LoadUsualTransfersUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, LoadUsualTransfersUseCaseErrorOutput> {
        let bsanTransfersManager = bsanManagersProvider.getBsanTransfersManager()
        let bsanResponse = try bsanTransfersManager.loadUsualTransfers()

        if bsanResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(LoadUsualTransfersUseCaseErrorOutput(try bsanResponse.getErrorMessage()))
    }
    
}

class LoadUsualTransfersUseCaseErrorOutput: StringErrorOutput {}
