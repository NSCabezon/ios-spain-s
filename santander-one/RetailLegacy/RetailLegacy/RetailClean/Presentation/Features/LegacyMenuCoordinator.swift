//
//  LegacyMenuCoordinator.swift
//  RetailLegacy
//
//  Created by Adrian Arcalá Ocón on 11/1/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI
import UIKit

public protocol LegacyMenuCoordinatorDependenciesResolver {
    func resolve() -> NavigatorProvider
}

public final class LegacyMenuCoordinator: Coordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let dependenciesResolver: LegacyMenuCoordinatorDependenciesResolver
    
    init(dependenciesResolver: LegacyMenuCoordinatorDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func start() {
        dependenciesResolver.resolve().getModuleCoordinator(type: MenuCoordinatorNavigator.self).didSelectMenu()
    }
}
