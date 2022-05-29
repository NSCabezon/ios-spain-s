//
//  OnboardingWelcomeCoordinator.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 11/10/21.
//

import CoreFoundationLib
import UI

final class OnboardingWelcomeCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private var navigator: OnboardingNavigatorProtocol?
    private var useCaseHandler: UseCaseHandler {
        self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
    }
    
    func start() {
        let configuration = dependenciesEngine.resolve(for: OnboardingConfigurationProtocol.self)
        let navigatorProvider = dependenciesEngine.resolve(for: NavigatorProvider.self)
        let welcomePresenter = navigatorProvider.presenterProvider.onboardingWelcomePresenter
        welcomePresenter.delegate = configuration.onboardingDelegate
        welcomePresenter.onboardingUserData = configuration.userData
        self.navigationController?.blockingPushViewController(welcomePresenter.view, animated: true)
    }
}
