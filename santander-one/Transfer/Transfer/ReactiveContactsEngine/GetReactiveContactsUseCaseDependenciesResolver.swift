import CoreFoundationLib
import CoreDomain

public protocol GetReactiveContactsUseCaseDependenciesResolver {
    func resolve() -> AppRepositoryProtocol
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> TransfersRepository
    func resolve() -> GetReactiveContactsUseCase
}
