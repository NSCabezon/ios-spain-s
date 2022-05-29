//
//  TestOnboardingExternalDependenciesResolver.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import UI
import Foundation
import QuickSetup
import CoreDomain
import CoreFoundationLib
import CoreTestData
import SANLegacyLibrary
@testable import Onboarding
@testable import ExampleApp

final class TestOnboardingExternalDependencies: OnboardingExternalDependenciesResolver {
    lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        return defaultResolver
    }()
    private let onboardingRepository = MockOnboardingRepository()
    private let trackerManager = TrackerManagerMock()
    
    func resolve() -> LocalAppConfig {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> AppRepositoryProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> TrackerManager {
        return trackerManager
    }
    
    func resolve() -> OnboardingRepository {
        return onboardingRepository
    }
    
    func resolve() -> UserPreferencesRepository {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> UINavigationController {
        return UINavigationController()
    }
    
    func resolve() -> PhotoThemeModifierProtocol? {
        return nil
    }
    
    func resolve() -> BackgroundImageRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> DeleteBackgroundImageRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> LocationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> GlobalPositionWithUserPrefsRepresentable {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> PushNotificationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> ApplePayEnrollmentManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> CoreSessionManager {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> PublicFilesManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> SessionDataManager {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> StringLoader {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> CompilationProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> MenuRepository {
        MockMenuRepository()
    }
    
    func resolve() -> OnboardingConfiguration {
        return OnboardingConfigurationMock()
    }
        
    func resolve() -> GlobalPositionDataRepository {
        return DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> OnboardingPermissionOptionsProtocol? {
        return DefaultOnboardingPermissionOptions()
    }
    
    func resolve() -> PersonalAreaRepository {
        return MockPersonalAreaRepository()
    }
    
    func resolveOnBoardingCustomStepView(for identifier: String, coordinator: StepsCoordinator<OnboardingStep>) -> StepIdentifiable {
        return ViewController()
    }
    
    private class ViewController: UIViewController, StepIdentifiable {}
}
