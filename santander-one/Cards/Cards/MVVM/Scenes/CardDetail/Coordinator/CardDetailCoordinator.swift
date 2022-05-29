//  
//  CardDetailCoordinator.swift
//  Cards
//
//  Created by Gloria Cano López on 17/2/22.
//

import Foundation
import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

public protocol CardDetailCoordinator: BindableCoordinator {
    func openMenu()
    func activeCard(card: CardRepresentable)
    func showPAN(card: CardRepresentable)
    func share(_ shareable: Shareable, type: ShareType) 
}

public final class DefaultCardDetailCoordinator: CardDetailCoordinator {
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: CardDetailExternalDependenciesResolver
    public lazy var dataBinding: DataBinding = dependencies.resolve()
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: CardDetailExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
    
    public func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }
}

extension DefaultCardDetailCoordinator {
    public func openMenu() {
        let coordinator = dependencies.external.privateMenuCoordinator()
        coordinator.start()
        append(child: coordinator)
    }
    
    public func activeCard(card: CardRepresentable) {
        let coordinator = dependencies.external.cardActivateCoordinator()
        coordinator
            .set(card)
            .start()
        append(child: coordinator)
    }
    
    public func showPAN(card: CardRepresentable) {
        let coordinator = dependencies.external.showPANCoordinator()
        coordinator
            .set(card)
            .start()
        append(child: coordinator)
    }
    
    public func share(_ shareable: Shareable, type: ShareType) {
        let coordinator: ShareCoordinator = dependencies.external.resolve()
        coordinator
            .set(shareable)
            .set(type)
            .start()
        append(child: coordinator)
    }
    
}

private extension DefaultCardDetailCoordinator {
    struct Dependency: CardDetailDependenciesResolver {
        let dependencies: CardDetailExternalDependenciesResolver
        let coordinator: CardDetailCoordinator
        let dataBinding = DataBindingObject()
        
        var external: CardDetailExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> CardDetailCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
    }
}
