//
//  PGPersonalizationModuleCoordinator.swift
//  PersonalArea
//
//  Created by alvola on 10/03/2020.
//

import UI
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

final class DefaultPGPersonalizationModuleCoordinator: ModuleCoordinator {

    public weak var navigationController: UINavigationController?
    private lazy var dependencies = Dependency(external: externalDependencies)
    private lazy var legacyDependenciesEngine = DependenciesDefault(father: dependencies.external.resolve())
    private let externalDependencies: PersonalAreaPGPersonalizationExternalDependenciesResolver
    
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    public init(dependenciesResolver: PersonalAreaPGPersonalizationExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependenciesResolver
        self.setupDependencies()
    }
    
    public func start() {
        let pgPersonalizationView = legacyDependenciesEngine.resolve(for: PGPersonalizationViewProtocol.self)
        self.navigationController?.blockingPushViewController(pgPersonalizationView, animated: true)
    }
    
    func end() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDependencies() {
        self.legacyDependenciesEngine.register(for: PGPersonalizationPresenterProtocol.self) { dependenciesResolver in
            return PGPersonalizationPresenter(dependenciesResolver: dependenciesResolver, section: .pgPersonalization)
        }
        
        self.legacyDependenciesEngine.register(for: PGPersonalizationViewProtocol.self) { dependenciesResolver in
            var presenter = dependenciesResolver.resolve(for: PGPersonalizationPresenterProtocol.self)
            let viewController = PGPersonalizationViewController(nibName: "PGPersonalizationViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            presenter.moduleCoordinator = self
            return viewController
        }
        
        self.legacyDependenciesEngine.register(for: OperativeSelectorViewController.self) { _ in
            OperativeSelectorViewController(nibName: "OperativeSelectorViewController", bundle: Bundle.module)
        }
        
        self.legacyDependenciesEngine.register(for: SmartSelectorPersonalAreaViewController.self) { _ in
            SmartSelectorPersonalAreaViewController(nibName: "SmartSelectorPersonalAreaViewController", bundle: Bundle.module)
        }
        
        self.legacyDependenciesEngine.register(for: GPCustomizationCoordinator.self) { dependenciesResolver in
            let coordinator = GPCustomizationCoordinator(dependenciesResolver: dependenciesResolver,
                                                         navigationController: self.navigationController)
            return coordinator
        }
        
        self.legacyDependenciesEngine.register(for: GeneralBudgetCoordinator.self) { dependenciesResolver in
            let coordinator = GeneralBudgetCoordinator(dependenciesResolver: dependenciesResolver, navigationController: self.navigationController)
            return coordinator
        }
    }
    
    public func goToGeneralBudget() {
        let coordinator = legacyDependenciesEngine.resolve(for: GeneralBudgetCoordinator.self)
        coordinator.start()
    }
    
    public func goToOperativeSelector(delegate: OtherOperativesViewControllerDelegate, viewModels: [GpOperativesViewModel]) {
        let operativeSelectorViewController = legacyDependenciesEngine.resolve(for: OperativeSelectorViewController.self)
        operativeSelectorViewController.setData(delegate: delegate, viewModels: viewModels)
        self.navigationController?.blockingPushViewController(operativeSelectorViewController, animated: true)
    }
    
    public func goToSmartOperativeSelector(delegate: OtherOperativesViewControllerDelegate, viewModels: [GpOperativesViewModel], gpColorMode: PGColorMode) {
        let operativeSelectorViewController = legacyDependenciesEngine.resolve(for: SmartSelectorPersonalAreaViewController.self)
        operativeSelectorViewController.setData(delegate: delegate, viewModels: viewModels, gpColorMode: gpColorMode)
        self.navigationController?.blockingPushViewController(operativeSelectorViewController, animated: true)
    }
}

extension DefaultPGPersonalizationModuleCoordinator: PersonalAreaPGPersonalizationCoordinator {}

private extension DefaultPGPersonalizationModuleCoordinator {
    struct Dependency: PersonalAreaPGPersonalizationDependenciesResolver {
        let external: PersonalAreaPGPersonalizationExternalDependenciesResolver
    }
}
