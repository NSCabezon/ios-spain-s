//
//  LastMovementsCoordinator.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 15/07/2020.
//

import CoreFoundationLib
import UI

protocol LastMovementsCoordinatorProtocol {
    func start()
    func dismiss()
}

final public class LastMovementsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: LastMovementsCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: LastMovementsPresenterProtocol.self) { dependenciesResolver in
            return LastMovementsPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: LastMovementsPresenterProtocol.self) { dependenciesResolver in
            return LastMovementsPresenter(dependenciesResolver: dependenciesResolver)
        }
                
        self.dependenciesEngine.register(for: LastMovementsViewProtocol.self) { _ in
            let presenter = self.dependenciesEngine.resolve(for: LastMovementsPresenterProtocol.self)
            let viewController = LastMovementsViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }

        self.dependenciesEngine.register(for: SetReadCardTransactionsUseCase.self) { dependenciesResolver in
            return SetReadCardTransactionsUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: AccountTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return AccountTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: CardTransactionPullOfferConfigurationUseCase.self) { dependenciesResolver in
            return CardTransactionPullOfferConfigurationUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension LastMovementsCoordinator: LastMovementsCoordinatorProtocol {
   public func start() {
        guard let controller = self.dependenciesEngine.resolve(for: LastMovementsViewProtocol.self) as? UIViewController else { return }
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
