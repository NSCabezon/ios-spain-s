import CoreDomain
import OpenCombine

public protocol GetMyProductsUseCase {
    func fetchMyProducts() -> AnyPublisher<[UserPrefBoxType: PGBoxRepresentable], Error>
}

struct DefaultGetMyProductsUseCase {
    let userPrefRepository: UserPreferencesRepository
    let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        userPrefRepository = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultGetMyProductsUseCase: GetMyProductsUseCase {    
    func fetchMyProducts() -> AnyPublisher<[UserPrefBoxType: PGBoxRepresentable], Error> {
        return boxes
    }
}

private extension DefaultGetMyProductsUseCase {
    var boxes: AnyPublisher<[UserPrefBoxType: PGBoxRepresentable], Error> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.userId)
            .flatMap { userId -> AnyPublisher<String, Error> in
                guard let userId = userId else { return Fail(error: NSError(description: "no-user-id")).eraseToAnyPublisher() }
                return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .map(userPrefRepository.getUserPreferences)
            .flatMap { $0 }
            .map(\.boxesRepresentable)
            .map(removeNotVisibles)
            .eraseToAnyPublisher()
    }
    
    func removeNotVisibles(_ boxesRepresentable: [UserPrefBoxType : PGBoxRepresentable]) -> [UserPrefBoxType : PGBoxRepresentable] {
        var newDict: [UserPrefBoxType : PGBoxRepresentable] = [:]
        boxesRepresentable.forEach { dict in
            if dict.value.productsRepresentable.filter { $0.value.isVisible == true }.isNotEmpty {
                newDict[dict.key] = dict.value
            }
        }
        return newDict
    }
}
