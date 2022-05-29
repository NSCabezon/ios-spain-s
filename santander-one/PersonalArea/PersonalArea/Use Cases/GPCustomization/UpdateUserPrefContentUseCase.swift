import CoreDomain
import CoreFoundationLib

class UpdateUserPrefContentUseCase: UseCase<UpdateUserPrefContentUseCaseInput, Void, StringErrorOutput> {
    override func executeUseCase(requestValues: UpdateUserPrefContentUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let userPrefDTOEntity = requestValues.userPref.userPrefDTOEntity
        
        for (index, products) in requestValues.globalPosition.enumerated() {
            guard let boxType = products.first?.productType, var box = userPrefDTOEntity.pgUserPrefDTO.boxes[UserPrefBoxType(type: boxType)] else { continue }
            let boxCopy = box
            box.order = index
            box.removeAllItems()
            for (productIndex, product) in products.enumerated() {
                guard boxCopy.getItem(withIdentifier: product.identifier)  != nil else { continue }
                let newItem = PGBoxItemDTOEntity(order: productIndex, isVisible: product.isVisible)
                box.set(item: newItem, withIdentifier: product.identifier)
            }
            userPrefDTOEntity.pgUserPrefDTO.boxes[UserPrefBoxType(type: boxType)] = box
        }
        
        appRepositoryProtocol.setUserPreferences(userPref: userPrefDTOEntity)
        return UseCaseResponse.ok()
    }
}

struct UpdateUserPrefContentUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let userPref: UserPrefEntity
    let globalPosition: [[GPCustomizationProductViewModel]]
}
