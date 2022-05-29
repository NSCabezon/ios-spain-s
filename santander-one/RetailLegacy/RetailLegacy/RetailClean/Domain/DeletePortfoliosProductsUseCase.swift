import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class DeletePortfoliosProductsUseCase: UseCase<Void, Void, DeletePortfoliosProductsUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, DeletePortfoliosProductsUseCaseErrorOutput> {
        try provider.getBsanPortfoliosPBManager().deletePortfoliosProducts()
        
        return UseCaseResponse.ok()
    }
}

class DeletePortfoliosProductsUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
