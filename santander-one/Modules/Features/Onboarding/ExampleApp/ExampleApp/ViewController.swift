//
//  ViewController.swift
//  ExampleApp
//
//  Created by Jose Ignacio de Juan Díaz on 22/11/21.
//

import UIKit
import UI
import QuickSetup
import CoreFoundationLib
import CoreTestData
import Localization
import Onboarding
import CoreDomain
import OpenCombine
import SANLegacyLibrary

final class ViewController: UIViewController {
    let label = UILabel()
    let rootNavigationController = UINavigationController()
    
    private lazy var servicesProvider: ServicesProvider = {
        return QuickSetupForCoreTestData()
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [OnboardingServiceInjector()]
    }
    
    var childCoordinators: [Coordinator] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gotoOnboardingModule()
    }
    
    private lazy var dependenciesResolver: DependenciesResolver & DependenciesInjector = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: UINavigationController.self) { _ in
            return self.rootNavigationController
        }
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        ModuleDependencies(dependenciesResolver: defaultResolver)
            .registerRetailLegacyDependencies()
        return defaultResolver
    }()
}

private extension ViewController {
    func gotoOnboardingModule() {
        rootNavigationController.modalPresentationStyle = .fullScreen
        self.present(rootNavigationController, animated: false, completion: { [weak self] in
            guard let self = self else { return }
            let coordinator = OnboardingCoordinator(dependencies: self.dependenciesResolver)
            coordinator.start()
            coordinator.onFinish = {
                let termination: OnboardingTermination? = coordinator.dataBinding.get()
                if let termination = termination {
                    print(termination)
                }
            }
        })
    }
}

// MARK: global dependencies
public protocol TimeManagerResolver {
    var timeManager: TimeManager { get }
    func resolve() -> TimeManager
}

public extension TimeManagerResolver {
    func resolve() -> TimeManager {
        return timeManager
    }
}

public protocol TrackerManagerResolver {
    func resolve() -> TrackerManager
}

public extension TrackerManagerResolver {
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}

public protocol AppConfigRepositoryResolver {
    func resolve() -> AppConfigRepositoryProtocol
}

public extension AppConfigRepositoryResolver {
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: MockDataInjector())
    }
}

public typealias GlobalResolver = TimeManagerResolver & TrackerManagerResolver & AppConfigRepositoryResolver

// MARK: Onboarding dependencies
class ModuleDependencies: GlobalResolver, OnboardingExternalDependenciesResolver {
    
    var dependenciesResolver: DependenciesInjector & DependenciesResolver
    var timeManager: TimeManager
    
    init(dependenciesResolver: DependenciesInjector & DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        let local = LocaleManager(dependencies: dependenciesResolver)
        local.updateCurrentLanguage(language: .createFromType(languageType: .spanish, isPb: true))
        timeManager = local
    }
    
    func resolve() -> UINavigationController {
        return dependenciesResolver.resolve(for: UINavigationController.self)
    }
    
    func resolve() -> DependenciesResolver {
        return dependenciesResolver
    }
    
    func resolve() -> LocalAppConfig {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> AppRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> LocationPermissionsManagerProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> CompilationProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> PushNotificationPermissionsManagerProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol {
        dependenciesResolver.resolve()
    }
    
    func resolve() -> UserPreferencesRepository {
        return UserPreferencesRepositoryMock()
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
        dependenciesResolver.resolve()
    }
    
    func resolve() -> UserSessionRepository {
        return MockUserSessionRepository()
    }
    
    func resolve() -> OnboardingRepository {
        return MockOnboardingRepository()
    }
    
    func resolve() -> MenuRepository {
        return MockMenuRepository()
    }
    
    func resolve() -> GlobalPositionWithUserPrefsRepresentable {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> BSANManagersProvider {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> ApplePayEnrollmentManagerProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> BackgroundImageRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> DeleteBackgroundImageRepositoryProtocol {
        return dependenciesResolver.resolve()
    }
    
    func resolve() -> PhotoThemeModifierProtocol? {
        return nil
    }
    
    func resolve() -> OnboardingConfiguration {
        return DefaultOnboardingConfiguration()
    }
        
    func resolve() -> GlobalPositionDataRepository {
        return DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> OnboardingPermissionOptionsProtocol? {
        return DefaultOnboardingPermissionOptions()
    }
    
    func resolve() -> PersonalAreaRepository {
        DefaultPersonalAreaRepository(dependenciesResolver: dependenciesResolver.resolve())
    }
    
    func resolveOnBoardingCustomStepView(for identifier: String, coordinator: StepsCoordinator<OnboardingStep>) -> StepIdentifiable {
        return CustomStepViewController()
    }
}

extension ModuleDependencies {
    func registerRetailLegacyDependencies() {
        dependenciesResolver.register(for: OnboardingExternalDependenciesResolver.self) { _ in
            return self
        }
    }
}
