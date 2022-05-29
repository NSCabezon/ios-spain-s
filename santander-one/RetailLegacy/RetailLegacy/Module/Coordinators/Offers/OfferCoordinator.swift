//
//  OfferCoordinator.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 23/12/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
import UIKit

public final class LegacyOfferCoordinator: BindableCoordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public let dataBinding: DataBinding = DataBindingObject()
    private let dependenciesResolver: LegacyCoreDependenciesResolver
    
    init(dependenciesResolver: LegacyCoreDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func start() {
        guard let offer: OfferRepresentable = dataBinding.get() else { return }
        let navigatorProvider: NavigatorProvider = dependenciesResolver.resolve()
        navigatorProvider.getModuleCoordinator(type: ModuleCoordinatorNavigator.self).executeOffer(offer)
    }
}
