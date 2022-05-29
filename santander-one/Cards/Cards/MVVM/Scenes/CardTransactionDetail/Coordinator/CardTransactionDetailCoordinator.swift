//  
//  CardTransactionDetailCoordinator.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import Foundation
import UI
import CoreFoundationLib
import CoreDomain

protocol CardTransactionDetailCoordinator: BindableCoordinator {
    func openMenu()
    func goToCardAction(_ card: CardRepresentable, type: CardActionType)
    func goToEasyPay(card: CardRepresentable,
                     transaction: CardTransactionRepresentable,
                     easyPayOperativeDataEntity: EasyPayOperativeDataEntity?)
    func goToMapView(card: CardRepresentable, type: CardMapTypeConfiguration)
    func goToOffer(offer: OfferRepresentable)
}

final class DefaultCardTransactionDetailCoordinator: CardTransactionDetailCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: CardTransactionDetailExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: CardTransactionDetailExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultCardTransactionDetailCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
    
    func openMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    func goToCardAction(_ card: CardRepresentable, type: CardActionType) {
        let resolver = dependencies.external.cardExternalDependenciesResolver()
        let coordinator = type.getCoordinator(dependencies: resolver)
        switch type {
        case .share(let item):
            let shareableCard = item
            coordinator
                .set(shareableCard)
                .set(ShareType.text)
                .start()
        default:
            coordinator
                .set(card)
                .set(type)
                .start()
            append(child: coordinator)
        }
    }
    
    func goToEasyPay(card: CardRepresentable,
                     transaction: CardTransactionRepresentable,
                     easyPayOperativeDataEntity: EasyPayOperativeDataEntity?) {
        let coordinator = dependencies.external.cardExternalDependenciesResolver().easyPayCoordinator()
        coordinator
            .set(card)
            .set(transaction)
            .set(easyPayOperativeDataEntity)
            .start()
        append(child: coordinator)
    }
    
    func goToMapView(card: CardRepresentable, type: CardMapTypeConfiguration) {
        let configuration = CardMapConfiguration(type: type,
                                                 card: card)
        let coordinator = dependencies.external.shoppingMapCoordinator()
        coordinator
            .set(configuration)
            .start()
        append(child: coordinator)
        
    }
    
    func goToOffer(offer: OfferRepresentable) {
        let coordinator = dependencies.external.cardExternalDependenciesResolver().offersCoordinator()
        coordinator
            .set(offer)
            .start()
        append(child: coordinator)
    }
}

private extension DefaultCardTransactionDetailCoordinator {
    struct Dependency: CardTransactionDetailDependenciesResolver {
        let dependencies: CardTransactionDetailExternalDependenciesResolver
        let coordinator: CardTransactionDetailCoordinator
        let dataBinding = DataBindingObject()
        
        var external: CardTransactionDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func cardTransactionDetailCoordinator() -> CardTransactionDetailCoordinator {
            return coordinator
        }
    }
}
