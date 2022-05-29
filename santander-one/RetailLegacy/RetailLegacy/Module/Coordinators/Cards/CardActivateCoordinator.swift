//
//  CardActivateCoordinator.swift
//  Cards
//
//  Created by Hernán Villamil on 1/2/22.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import UI
import Cards

final class DefaultCardActivateCoordinator: BindableCoordinator {
    public var onFinish: (() -> Void)?
    public var dataBinding: DataBinding = DataBindingObject()
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController?
    private let dependencies: RetailLegacyCardExternalDependenciesResolver
    private lazy var legacyDependencies: DependenciesResolver = dependencies.resolve()
    private let action: CardActionType = .enable
    
    public init(dependencies: RetailLegacyCardExternalDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    public func start() {
        guard let cardRepresentable: CardRepresentable = dataBinding.get() else {
            return
        }
        
        let selectedCard = CardEntity(cardRepresentable)
        
        legacyDependencies
            .resolve(for: CardsHomeCoordinatorNavigator.self)
            .didSelectAction(action, selectedCard)
    }
}
