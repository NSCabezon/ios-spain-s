import SANSpainLibrary

extension ModuleDependencies: SPGetAllTransfersReactiveUseCaseDependenciesResolver {    
    func resolve() -> SpainGlobalPositionRepository {
        oldResolver.resolve()
    }
    
    func resolve() -> GetAllTransfersUseCaseModifierProtocol? {
        return oldResolver.resolve(forOptionalType: GetAllTransfersUseCaseModifierProtocol.self)
    }
}
