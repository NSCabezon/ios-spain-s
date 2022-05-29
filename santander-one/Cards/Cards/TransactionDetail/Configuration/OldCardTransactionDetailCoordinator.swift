//
//  CardTransactionDetailCoordinator.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 20/11/2019.
//

import UI
import CoreFoundationLib
import SANLegacyLibrary

public protocol CardsTransactionDetailModuleCoordinatorDelegate: AnyObject {
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity)
    func easyPay(entity: CardEntity, transactionEntity: CardTransactionEntity, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?)
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectOffer(offer: OfferEntity)
}

public final class OldCardTransactionDetailCoordinator: ModuleCoordinator {
    private let externalDependencies: CardExternalDependenciesResolver
    private let cardsDependenciesEngine: DependenciesDefault
    public weak var navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver,
                navigationController: UINavigationController?,
                externalDependencies: CardExternalDependenciesResolver) {
        self.navigationController = navigationController
        self.cardsDependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.externalDependencies = externalDependencies
        self.setupDependencies()
    }
    
    public func start() {
        self.navigationController?.blockingPushViewController(cardsDependenciesEngine.resolve(for: OldCardTransactionDetailViewController.self), animated: true)
    }
    
    public func didSelectOffer(offer: OfferEntity) {
        cardsDependenciesEngine.resolve(for: CardsTransactionDetailModuleCoordinatorDelegate.self).didSelectOffer(offer: offer)
    }
        
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        let coordinator = externalDependencies.shoppingMapCoordinator()
        let configuration = CardMapConfiguration(type: type,
                                                 card: selectedCard.representable)
        coordinator.set(configuration)
        coordinator.start()
    }
    
    private func setupDependencies() {
        self.cardsDependenciesEngine.register(for: CardTransactionDetailPresenterProtocol.self) { dependenciesResolver in
            return CardTransactionDetailPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: CardTransactionDetailViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: OldCardTransactionDetailViewController.self)
        }
        
        self.cardsDependenciesEngine.register(for: OldCardTransactionDetailUseCase.self) { dependenciesResolver in
            return OldCardTransactionDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: OldGetMinEasyPayAmountUseCase.self) { _ in
            return OldGetMinEasyPayAmountUseCase()
        }
        
        self.cardsDependenciesEngine.register(for: ValidateEasyPayUseCase.self) { dependenciesResolver in
            return ValidateEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: OldGetSingleCardMovementLocationUseCase.self) { dependenciesResolver in
            return OldGetSingleCardMovementLocationUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: FirstFeeInfoEasyPayUseCase.self) { dependenciesResolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.cardsDependenciesEngine.register(for: OldCardTransactionDetailViewController.self) { dependenciesResolver in
            let presenter: CardTransactionDetailPresenterProtocol = dependenciesResolver.resolve(for: CardTransactionDetailPresenterProtocol.self)
            let viewController = OldCardTransactionDetailViewController(nibName: "CardTransactionDetail", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
    }
}
