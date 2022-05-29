import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class DeleteStockOrdersUseCase: UseCase<Void, Void, DeleteStockOrdersUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, DeleteStockOrdersUseCaseErrorOutput> {
        _ = try provider.getBsanStocksManager().deleteStockOrders()
        
        return UseCaseResponse.ok()
    }
}

class DeleteStockOrdersUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
