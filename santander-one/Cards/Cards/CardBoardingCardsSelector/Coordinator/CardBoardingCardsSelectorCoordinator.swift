//
//  CardBoardingCardsSelectorCoordinator.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/01/2021.
//

import CoreFoundationLib
import UI

public protocol CardBoardingCardsSelectorCoordinatorDelegate: AnyObject {
    func didSelectCard(_ card: CardEntity)
}

protocol CardBoardingCardsSelectorCoordinatorProtocol {
    func closeCardsSelector()
    func back()
    func didSelectCardEntity(card: CardEntity)
}

public final class CardBoardingCardsSelectorCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    var coordinatorDelegate: CardBoardingCardsSelectorCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: CardBoardingCardsSelectorCoordinatorDelegate.self)
    }
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: CardBoardingCardsSelectorViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: CardBoardingCardsSelectorPresenterProtocol.self) { dependenciesResolver in
            return CardBoardingCardsSelectorPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: CardBoardingCardsSelectorCoordinatorProtocol.self) { _ in
            return self
        }
        
        self.dependenciesEngine.register(for: CardBoardingCardsSelectorViewController.self) { dependenciesResolver in
            let presenter: CardBoardingCardsSelectorPresenterProtocol = dependenciesResolver.resolve(for: CardBoardingCardsSelectorPresenterProtocol.self)
            let viewController = CardBoardingCardsSelectorViewController(nibName: "CardBoardingCardsSelectorViewController", bundle: .module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}

extension CardBoardingCardsSelectorCoordinator: CardBoardingCardsSelectorCoordinatorProtocol {
    func didSelectCardEntity(card: CardEntity) {
        self.coordinatorDelegate.didSelectCard(card)
    }
    
    func closeCardsSelector() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
