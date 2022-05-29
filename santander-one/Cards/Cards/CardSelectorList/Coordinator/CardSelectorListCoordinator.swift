//
//  CardSelectorListCoordinator.swift
//  Cards
//
//  Created by Ignacio González Miró on 10/6/21.
//

import UI
import CoreFoundationLib

protocol CardSelectorListCoordinatorDelegate: AnyObject {
    func dismiss()
    func didTapInCardSelector(_ viewModel: CardboardingCardCellViewModel)
}

protocol CardSelectorItemCoordinatorDelegate: AnyObject {
    func didSelectCard(_ cardEntity: CardEntity)
}

final public class CardSelectorListCoordinator: ModuleCoordinator {
    public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }

    public func start() {
        let controller = self.dependenciesEngine.resolve(for: CardSelectorListViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension CardSelectorListCoordinator {
    var coordinatorDelegate: CardSelectorItemCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: CardSelectorItemCoordinatorDelegate.self)
    }
    var cardHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        dependenciesEngine.register(for: CardSelectorListViewController.self) { resolver in
            var presenter = self.dependenciesEngine.resolve(for: CardSelectorListPresenterProtocol.self)
            let viewController = CardSelectorListViewController(dependenciesResolver: resolver, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        dependenciesEngine.register(for: CardSelectorListGenericViewProtocol.self) { resolver in
            return resolver.resolve(for: CardSelectorListViewController.self)
        }
        dependenciesEngine.register(for: CardSelectorListPresenterProtocol.self) { resolver in
            return CardSelectorListPresenter(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: CardSelectorListUseCase.self) { resolver in
            return CardSelectorListUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: CardSelectorListCoordinatorDelegate.self) { resolver in
            return CardSelectorListCoordinator(dependenciesResolver: resolver, navigationController: self.navigationController)
        }
        dependenciesEngine.register(for: CardBoardingCardsSelectorConfiguration.self) { _ in
            return CardBoardingCardsSelectorConfiguration(cards: [])
        }
    }
}

extension CardSelectorListCoordinator: CardSelectorListCoordinatorDelegate {
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapInCardSelector(_ viewModel: CardboardingCardCellViewModel) {
        coordinatorDelegate.didSelectCard(viewModel.entity)
    }
}
