import Foundation
import CoreFoundationLib
import SANSpainLibrary
import ESCommons

public protocol SKExternalDependenciesResolver: SKFirstStepOnboardingExternalDependenciesResolver,
    SKSecondStepOnboardingExternalDependenciesResolver,
    SKBiometricsStepOnboardingExternalDependenciesResolver,
    SKOperativeExternalDependenciesResolver,
    SKRegisteredAnotherDeviceExternalDependenciesResolver {
    func resolve() -> SpainCompilationProtocol
    func resolve() -> TrusteerRepositoryProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> StringLoader
    func resolve() -> LocationPermissionsManagerProtocol?
    func resolve() -> SantanderKeyOnboardingRepository
    func resolve() -> NotificationDeviceInfoProvider
}

public extension SKExternalDependenciesResolver {
    
    func resolve() -> SantanderKeyTransparentRegisterUseCase {
        return DefaultSantanderKeyTransparentRegisterUseCase(dependencies: self)
    }
    
    func resolve() -> SantanderKeyRegisterAuthMethodUseCase {
        return DefaultSantanderKeyRegisterAuthMethodUseCase(dependencies: self)
    }
    
    func resolve() -> SantanderKeyRegisterConfirmationUseCase {
        return DefaultSantanderKeyRegisterConfirmationUseCase(dependencies: self)
    }
    
    func resolve() -> SantanderKeyRegisterValidationWithPositionsUseCase {
        return DefaultSantanderKeyRegisterValidationWithPositionsUseCase(dependencies: self)
    }
    
    func resolve() -> SantanderKeyRegisterValidationWithPINUseCase {
        return DefaultSantanderKeyRegisterValidationWithPINUseCase(dependencies: self)
    }
    
    func resolve() -> SKOperativeCoordinator {
        DefaultSKOperativeCoordinator(dependencies: self)
    }
}
