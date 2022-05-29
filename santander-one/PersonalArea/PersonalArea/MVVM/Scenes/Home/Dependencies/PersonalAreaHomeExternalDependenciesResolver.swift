//
//  PersonalAreaHomeExternalDependenciesResolver.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import Foundation
import UI
import CoreDomain
import CoreFoundationLib

public protocol PersonalAreaHomeExternalDependenciesResolver: NavigationBarExternalDependenciesResolver {
    func resolve() -> NavigationBarItemBuilder
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> AppRepositoryProtocol
    func resolve() -> LocalAppConfig
    func resolve() -> PersonalAreaRepository
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> ReactivePullOffersRepository
    func resolve() -> GetCandidateOfferUseCase
    func resolve() -> GetDigitalProfileUseCase
    func resolve() -> GetPersonalAreaHomeConfigurationUseCase
    func resolve() -> GetPersonalAreaHomeFieldsUseCase
    func resolve() -> PersistUserAvatarUseCase
    func resolve() -> GetUsernameUseCase
    func resolve() -> GetUserAvatarUseCase
    func resolve() -> GetHomeUserPreferencesUseCase
    func resolve() -> UINavigationController
    func resolve() -> DependenciesResolver
    func resolve() -> TrackerManager
    func resolve() -> EmmaTrackEventListProtocol
    func personalAreaHomeCoordinator() -> Coordinator
    func personalAreaBasicInfoCoordinator() -> Coordinator
    func personalAreaConfigurationCoordinator() -> Coordinator
    func personalAreaSecurityCoordinator() -> BindableCoordinator
    func personalAreaPGPersonalizationCoordinator() -> Coordinator
    func personalAreaDigitalProfileCoordinator() -> Coordinator
    func personalAreaCustomActionCoordinator() -> BindableCoordinator
    func resolveOfferCoordinator() -> BindableCoordinator
}

public extension PersonalAreaHomeExternalDependenciesResolver {
    func personalAreaHomeCoordinator() -> Coordinator {
        return DefaultPersonalAreaHomeCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolve() -> PersistUserAvatarUseCase {
        return DefaultPersistUserAvatarUseCase(dependencies: self)
    }
    
    func resolve() -> GetDigitalProfileUseCase {
        return DefaultGetDigitalProfileUseCase(dependencies: self)
    }
    
    func resolve() -> GetPersonalAreaHomeFieldsUseCase {
        return DefaultGetPersonalAreaHomeFieldsUseCase()
    }
    
    func resolve() -> GetUsernameUseCase {
        return DefaultGetUsernameUseCase(dependencies: self)
    }
    
    func resolve() -> GetUserAvatarUseCase {
        return DefaultGetUserAvatarUseCase(dependencies: self)
    }
}
