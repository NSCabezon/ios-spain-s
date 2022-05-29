//
//  NextReceiptsDetailCoordinator.swift
//  Bills
//
//  Created by alvola on 03/06/2020.
//

import UI
import CoreFoundationLib

protocol NextReceiptsDetailCoordinatorProtocol {
    func end()
}

final class NextReceiptsDetailCoordinator: ModuleCoordinator {
    private let dependenciesEngine: DependenciesDefault
    weak var navigationController: UINavigationController?
    
    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func start() {
        guard let viewController = dependenciesEngine.resolve(for: NextReceiptsDetailViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(viewController, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: NextReceiptsDetailCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: NextReceiptsDetailPresenterProtocol.self) { dependenciesResolver in
            return NextReceiptsDetailPresenter(dependenciesResolver: self.dependenciesEngine)
        }
        
        self.dependenciesEngine.register(for: NextReceiptsDetailViewProtocol.self) { dependenciesResolver in
            let presenter: NextReceiptsDetailPresenterProtocol = dependenciesResolver.resolve(for: NextReceiptsDetailPresenterProtocol.self)
            let viewController = NextReceiptsDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension NextReceiptsDetailCoordinator: NextReceiptsDetailCoordinatorProtocol {
    func end() {
        self.navigationController?.popViewController(animated: true)
    }
}
