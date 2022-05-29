//
//  PersonalAreaDependenciesInitializer.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 9/9/21.
//

import QuickSetup
import CoreFoundationLib
import Localization

public final class PersonalAreaDependenciesInitializer: ModuleDependenciesInitializer {
    private let dependencies: DependenciesInjector
    private let userPreferencesDependencies: UserPreferencesDependenciesResolver
    
    private lazy var pushNotificationPermissionsManagerProtocolMock: PushNotificationPermissionsManagerProtocol = {
        return PushNotificationPermissionsManagerProtocolMock()
    }()
    
    private let personalAreaModuleCoordinator: PersonalAreaModuleCoordinator
    
    public init(dependencies: DependenciesInjector & DependenciesResolver, userPreferencesDependencies: UserPreferencesDependenciesResolver) {
        self.dependencies = dependencies
        self.userPreferencesDependencies = userPreferencesDependencies
        self.personalAreaModuleCoordinator = PersonalAreaModuleCoordinator(dependenciesResolver: dependencies,
                                                                           navigationController: dependencies.resolve(for: UINavigationController.self), userPreferencesDependencies: userPreferencesDependencies)
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: PersonalAreaMainModuleCoordinatorDelegate.self) { _ in
            return PersonalAreaMainModuleCoordinatorDelegateMock()
        }
        self.dependencies.register(for: PersonalAreaConfiguration.self) { _ in
            return PersonalAreaConfiguration(
                pushNotificationPermissionsManager: self.pushNotificationPermissionsManagerProtocolMock,
                locationPermissionsManager: nil,
                localAuthPermissionsManager: nil,
                contactsPermissionsManager: nil)
        }
        self.dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: false)
            return merger
        }
        self.dependencies.register(for: PersonalAreaMainModuleNavigator.self) { _ in
            return self.personalAreaModuleCoordinator
        }
    }
}
