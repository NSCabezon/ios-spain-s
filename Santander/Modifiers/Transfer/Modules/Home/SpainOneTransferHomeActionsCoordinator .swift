//
//  SpainOneTransferHomeActionsCoordinator .swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 23/12/21.
//

import Foundation
import UI
import CoreFoundationLib
import Bizum

class SpainOneTransferHomeActionsCoordinator: BindableCoordinator {
    weak var navigationController: UINavigationController?
    var dependencies: DependenciesResolver
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var dataBinding: DataBinding = DataBindingObject()
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func start() {
        guard let type: String = dataBinding.get(),
              let actionType = SpainSendMoneyActionTypeIdentifier(rawValue: type)
        else { return }
        switch actionType {
        case .bizum:
            dependencies.resolve(for: BizumStartCapable.self).launchBizum()
        case .onePayFx:
            break
        case .correosCash:
            break
        }
    }
}
