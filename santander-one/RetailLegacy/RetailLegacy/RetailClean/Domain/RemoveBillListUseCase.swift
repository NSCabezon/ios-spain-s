import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class RemoveBillListUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = try provider.getBsanBillTaxesManager().deleteBillList()
        return .ok()
    }
}
