//
//  LegacyCoreDependenciesResolver.swift
//  RetailLegacy
//
//  Created by José Carlos Estela Anguita on 23/12/21.
//

import CoreFoundationLib
import CoreDomain
import UI
import SANLegacyLibrary

public protocol LegacyCoreDependenciesResolver:
    GlobalPositionDependenciesResolver,
    OffersDependenciesResolver,
    UserPreferencesDependenciesResolver,
    PersonalAreaDependenciesResolver {
    func resolve() -> DependenciesResolver
    func resolve() -> OffersRepository
    func resolve() -> PullOffersRepositoryProtocol
    func resolve() -> RulesRepository
    func resolveOfferCoordinator() -> BindableCoordinator
    func resolveSavingsShowPDFCoordinator() -> BindableCoordinator
    func resolve() -> UserPreferencesRepository
    func resolve() -> NavigatorProvider
    func resolve() -> PersonalAreaRepository
    func resolve() -> GlobalPositionWithUserPrefsRepresentable
    func resolve() -> BSANManagersProvider
    func resolve() -> PushNotificationPermissionsManagerProtocol?
    func resolve() -> LocationPermissionsManagerProtocol?
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol?
    func resolve() -> AppRepositoryProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> ApplePayEnrollmentManagerProtocol
    func resolve() -> BackgroundImageRepositoryProtocol
    func resolve() -> DeleteBackgroundImageRepositoryProtocol
    func resolve() -> LoadBackgroundImageRepositoryProtocol
    func resolve() -> ManageBackgroundImageRepositoryProtocol
    func resolve() -> AccountNumberFormatterProtocol
    func resolveOTPCoordinator() -> BindableCoordinator
}

public extension LegacyCoreDependenciesResolver {
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return LegacyOfferCoordinator(dependenciesResolver: self)
    }
    
    func resolveSavingsShowPDFCoordinator() -> BindableCoordinator {
        return LegacySavingsShowPDFCoordinator(dependenciesResolver: self)
    }
    
    func resolve() -> NavigatorProvider {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> GlobalPositionRepresentable {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> OffersRepository {
        return asShared {
            OffersRepository(netClient: NetClientImplementation(), assetsClient: AssetsClient(), fileClient: FileClient(), parameters: resolve())
        }
    }
    
    func resolve() -> PullOffersRepositoryProtocol {
        return asShared {
            DefaultPullOffersRepository(pullOffersPersistenceDataSource: resolve())
        }
    }
    
    func resolve() -> RulesRepository {
        return asShared {
            RulesRepository(netClient: NetClientImplementation(), assetsClient: AssetsClient(), fileClient: FileClient())
        }
    }
    
    func resolve() -> UserPreferencesRepository {
        return asShared {
            let oldResolver: DependenciesResolver = resolve()
            return DefaultUserPreferencesRepository(persistenceDataSource: oldResolver.resolve())
        }
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> PersonalAreaRepository {
        return asShared {
            return DefaultPersonalAreaRepository(dependenciesResolver: self)
        }
    }
    
    func resolve() -> GlobalPositionWithUserPrefsRepresentable {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> BSANManagersProvider {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> PushNotificationPermissionsManagerProtocol? {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    func resolve() -> LocationPermissionsManagerProtocol? {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve(forOptionalType: LocationPermissionsManagerProtocol.self)
    }
    
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol? {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve(forOptionalType: LocalAuthenticationPermissionsManagerProtocol.self)
    }
    
    func resolve() -> EngineInterface {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
        
    func resolve() -> AppConfigRepositoryProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }

    func resolve() -> BaseURLProvider {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
        
    func resolve() -> ApplePayEnrollmentManagerProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> BackgroundImageRepositoryProtocol {
        return BackgroundImageRepository(
            loadImageRepository: resolve(),
            manageImageRepositoryProtocol: resolve())
    }
    
    func resolve() -> DeleteBackgroundImageRepositoryProtocol {
        return DocumentsBackgroundImageRepository()
    }
    
    func resolve() -> LoadBackgroundImageRepositoryProtocol {
        return FtpBackgroundImageRepository()
    }
    
    func resolve() -> ManageBackgroundImageRepositoryProtocol {
        return DocumentsBackgroundImageRepository()
    }
    
    func resolve() -> AccountNumberFormatterProtocol {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) ?? DefaultAccountNumberFormatter()
    }
    
    func resolveOTPCoordinator() -> BindableCoordinator {
        return LegacyOTPCoordinator(dependenciesResolver: self)
    }
}
