import Foundation
import CoreFoundationLib

import SANLegacyLibrary

class LoadGlobalPositionV2UseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, appConfigRepository: AppConfigRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        self.accountDescriptorRepository = accountDescriptorRepository
    }
        
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(GetPGProductsUseCaseErrorOutput(nil))
        }
        
        let isPB = globalPositionWrapper.isPb
        let response = try bsanManagersProvider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true, isPB: isPB)
        
        if response.isSuccess() {
            return UseCaseResponse.ok()
        } else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
    }
    
}
