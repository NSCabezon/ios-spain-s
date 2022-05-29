import CoreDomain

public protocol PublicMenuActionDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> PublicMenuActionsRepository
}

public extension PublicMenuActionDependenciesResolver {
    func resolve() -> PublicMenuActionsRepository {
        return asShared {
            DefaultPublicMenuActionRepository()
        }
    }
}
