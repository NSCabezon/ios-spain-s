//
//  NextSettlementMovementsCoordinator.swift
//  Cards
//
//  Created by David Gálvez Alonso on 15/10/2020.
//

import CoreFoundationLib
import UI

final class NextSettlementMovementsCoordinator {
    private let externalDependencies: CardExternalDependenciesResolver
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    weak var navigationController: UINavigationController?
    
    init(dependenciesResolver: DependenciesResolver,
         navigationController: UINavigationController?,
         externalDependencies: CardExternalDependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.externalDependencies = externalDependencies
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: NextSettlementMovementsCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: NextSettlementMovementsPresenterProtocol.self) { dependenciesResolver in
            return NextSettlementMovementsPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: NextSettlementMovementsViewController.self) { dependenciesResolver in
            let presenter: NextSettlementMovementsPresenterProtocol = dependenciesResolver.resolve(for: NextSettlementMovementsPresenterProtocol.self)
            let viewController = NextSettlementMovementsViewController(nibName: "NextSettlementMovementsViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension NextSettlementMovementsCoordinator: ModuleCoordinator {
    func start() {
        let controller = self.dependenciesEngine.resolve(for: NextSettlementMovementsViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        let coordinator = externalDependencies.shoppingMapCoordinator()
        let configuration = CardMapConfiguration(type: type,
                                                 card: selectedCard.representable)
        coordinator.set(configuration)
        coordinator.start()
    }
}
