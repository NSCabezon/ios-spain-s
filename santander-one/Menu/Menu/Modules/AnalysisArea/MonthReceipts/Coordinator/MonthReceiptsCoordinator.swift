//
//  MonthReceiptsCoordinator.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import UI
import CoreFoundationLib

protocol MonthReceiptsCoordinatorProtocol {
    func dismiss()
    func showDetailForMovement(_ movements: [TimeLineReceiptEntity], selected: Int)
}

public final class MonthReceiptsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let movementDetailCoordinator: MovementDetailCoordinator

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.movementDetailCoordinator = MovementDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.setupDependencies()
    }
    
    public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: MonthReceiptsViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension MonthReceiptsCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: MonthReceiptsCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: MonthReceiptsPresenterProtocol.self) { dependenciesResolver in
            return MonthReceiptsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: MonthReceiptsViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: MonthReceiptsPresenterProtocol.self)
            let viewController = MonthReceiptsViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        
    }
}

extension MonthReceiptsCoordinator: MonthReceiptsCoordinatorProtocol {
    func showDetailForMovement(_ movements: [TimeLineReceiptEntity], selected: Int) {
        self.dependenciesEngine.register(for: MovementDetailConfiguration.self) { _ in
            return MovementDetailConfiguration(receipts: movements, selectedIndex: selected)
        }
        movementDetailCoordinator.start()
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
