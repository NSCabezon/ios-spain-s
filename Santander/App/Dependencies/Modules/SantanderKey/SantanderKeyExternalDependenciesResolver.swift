import SantanderKey
import CoreFoundationLib
import Login
import SANSpainLibrary

extension ModuleDependencies: SKExternalDependenciesResolver {
    func resolve() -> DefaultSKOperativeCoordinator {
        return DefaultSKOperativeCoordinator(dependencies: self)
    }

    func resolve() -> SantanderKeyOnboardingRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }

    func resolve() -> NotificationDeviceInfoProvider {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }

    func resolve() -> TrusteerRepositoryProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
}

extension ModuleDependencies: SKFirstLoginModifierDependenciesResolver {
    func resolve() -> SKRegisteredAnotherDeviceExternalDependenciesResolver {
        return self
    }
    
    func resolve() -> SKFirstStepOnboardingExternalDependenciesResolver {
        return self
    }
    
    func resolve() -> SantanderKeyGetClientStatusUseCaseProtocol {
        return SantanderKeyGetClientStatusUseCase(dependenciesResolver: oldResolver)
    }
}

extension ModuleDependencies: SKUpdateTokenModifierDependenciesResolver {
    func resolve() -> SantanderKeyUpdateTokenUseCaseProtocol {
        return DefaultSantanderKeyUpdateTokenUseCase(dependencies: oldResolver)
    }
}

extension ModuleDependencies: SKCustomerDetailsExternalDependenciesResolver {    
}

