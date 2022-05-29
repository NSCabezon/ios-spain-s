//

import Foundation
import CoreFoundationLib

class GetSelectedProductUseCase: UseCase<Void, GetSelectedProductUseCaseOkOutput, GetSelectedProductUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSelectedProductUseCaseOkOutput, GetSelectedProductUseCaseErrorOutput> {
        if let selectedProduct = try appRepository.getSelectedProduct().getResponseData() {
            return UseCaseResponse.ok(GetSelectedProductUseCaseOkOutput(selectedProduct))
        }
        return UseCaseResponse.error(GetSelectedProductUseCaseErrorOutput("Error getting selectedProduct"))
    }
}

struct GetSelectedProductUseCaseOkOutput {
    
    let selectedProduct: SelectedProduct
    
    init(_ selectedProduct: SelectedProduct) {
        self.selectedProduct = selectedProduct
    }
}

class GetSelectedProductUseCaseErrorOutput: StringErrorOutput {

}
