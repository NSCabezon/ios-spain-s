//

import Foundation
import CoreFoundationLib

class SetSelectedProductUseCase: UseCase<SetSelectedProductUseCaseInput, Void, SetSelectedProductUseCaseErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: SetSelectedProductUseCaseInput) throws -> UseCaseResponse<Void, SetSelectedProductUseCaseErrorOutput> {
        _ = appRepository.setSelectedProduct(selectedProduct: requestValues.selectedProduct)
        return UseCaseResponse.ok()
    }
}

struct SetSelectedProductUseCaseInput {
    
    let selectedProduct: SelectedProduct
    
    init(selectedProduct: SelectedProduct) {
        self.selectedProduct = selectedProduct
    }
}

class SetSelectedProductUseCaseErrorOutput: StringErrorOutput {
    
}
