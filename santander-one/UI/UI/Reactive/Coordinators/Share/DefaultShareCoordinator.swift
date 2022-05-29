//
//  DefaultShareCoordinator.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/11/21.
//

import CoreFoundationLib
import Foundation

public protocol ShareCoordinator: BindableCoordinator {}

public final class DefaultShareCoordinator: ShareCoordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public var dataBinding: DataBinding = DataBindingObject()
    private let dependencies: ShareDependenciesResolver
    
    init(dependencies: ShareDependenciesResolver, navigationController: UINavigationController?) {
        self.dependencies = dependencies
        self.navigationController = navigationController
    }
    
    public func start() {
        guard let sharable: Shareable = dataBinding.get(), let viewController = navigationController?.topViewController else { return }
        dependencies.resolve().doShare(for: sharable, in: viewController, type: dataBinding.get())
    }
}
