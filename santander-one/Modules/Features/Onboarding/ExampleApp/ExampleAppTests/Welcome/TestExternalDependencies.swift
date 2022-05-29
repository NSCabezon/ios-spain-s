//
//  TestExternalDependencies.swift
//  ExampleAppTests
//
//  Created by José Norberto Hidalgo Romero on 7/12/21.
//

import UI
import Foundation
import QuickSetup
import CoreDomain
import CoreFoundationLib
import CoreTestData
import SANLegacyLibrary
@testable import Onboarding

class TestExternalDependencies: OnboardingWelcomeExternalDependenciesResolver {
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
    
    func resolve() -> OnboardingRepository {
        MockOnboardingRepository()
    }
    
    func resolve() -> UserPreferencesRepository {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> UINavigationController {
        return UINavigationController()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> AppRepositoryProtocol {
        return AppRepositoryMock()
    }
    
    func resolve() -> LocalAppConfig {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> LocationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> CompilationProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> PushNotificationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> StringLoader {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> MenuRepository {
        return MockMenuRepository()
    }
    
    func resolve() -> OnboardingConfiguration {
        return OnboardingConfigurationMock()
    }
        
    func resolve() -> GlobalPositionDataRepository {
        return DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> PersonalAreaRepository {
        return MockPersonalAreaRepository()
    }
    
    func resolve() -> OnboardingPermissionOptionsProtocol? {
        return OnboardingPermissionOptionsMock()
    }
}
