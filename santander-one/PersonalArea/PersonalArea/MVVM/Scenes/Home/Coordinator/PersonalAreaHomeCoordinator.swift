//
//  PersonalAreaHomeCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 4/4/22.
//

import Foundation
import UI
import CoreFoundationLib
import CoreDomain

protocol PersonalAreaHomeCoordinator: Coordinator {
    func didSelectMenu()
    func goToUserBasicInfo()
    func goToConfiguration()
    func goToSecurity()
    func goToPGPersonalization()
    func goToDigitalProfile()
    func goToOffer(_ offer: OfferRepresentable)
    func goToCustomAction(_ action: String)
    func gotoGlobalSearch()
    func openSettings(for permission: String)
}

final class DefaultPersonalAreaHomeCoordinator: PersonalAreaHomeCoordinator {
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    private let externalDependencies: PersonalAreaHomeExternalDependenciesResolver
    private lazy var dependencies: Dependency = {
        Dependency(external: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: PersonalAreaHomeExternalDependenciesResolver,
                navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultPersonalAreaHomeCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

extension DefaultPersonalAreaHomeCoordinator {
    func didSelectMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func gotoGlobalSearch() {
        let coordinator = dependencies.external.globalSearchCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToUserBasicInfo() {
        let coordinator = self.dependencies.external.personalAreaBasicInfoCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToConfiguration() {
        let coordinator = self.dependencies.external.personalAreaConfigurationCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToSecurity() {
        let coordinator = self.dependencies.external.personalAreaSecurityCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToPGPersonalization() {
        let coordinator = self.dependencies.external.personalAreaPGPersonalizationCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToCustomAction(_ action: String) {
        let coordinator = self.dependencies.external.personalAreaCustomActionCoordinator()
        coordinator
            .set(action)
            .start()
        append(child: coordinator)
    }
    
    func goToDigitalProfile() {
        let coordinator = self.dependencies.external.personalAreaDigitalProfileCoordinator()
        coordinator
            .start()
        append(child: coordinator)
    }
    
    func goToOffer(_ offer: OfferRepresentable) {
        let coordinator = self.dependencies.external.resolveOfferCoordinator()
        coordinator
            .set(offer)
            .start()
        append(child: coordinator)
    }
}

extension DefaultPersonalAreaHomeCoordinator: NavigateToSettingsDialogCapable {
    var associatedViewController: UIViewController {
        self.navigationController?.topVisibleViewController ?? self.dependencies.resolve()
    }
}

private extension DefaultPersonalAreaHomeCoordinator {
    struct Dependency: PersonalAreaHomeDependenciesResolver {
        let external: PersonalAreaHomeExternalDependenciesResolver
        let coordinator: PersonalAreaHomeCoordinator
        
        func resolve() -> PersonalAreaHomeCoordinator {
            return coordinator
        }
    }
}
