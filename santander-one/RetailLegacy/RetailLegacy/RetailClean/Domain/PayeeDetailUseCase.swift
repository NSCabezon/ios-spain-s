import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class PayeeDetailUseCase: UseCase<PayeeDetailUseCaseInput, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PayeeDetailUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let transferManager = provider.getBsanTransfersManager()
        
        let response = try transferManager.sepaPayeeDetail(of: requestValues.favourite.alias ?? "", recipientType: requestValues.favourite.recipientType ?? "")
        
        if response.isSuccess() {
            return .ok()
        }
        
        let errorDescription = try response.getErrorMessage() ?? ""
        return .error(NoSepaPayeeDetailUseCaseErrorOutput(errorDescription))
    }
}

struct PayeeDetailUseCaseInput {
    let favourite: Favourite
}
