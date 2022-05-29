//
//  SpainOneTransferHomeCoordinator.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 23/12/21.
//

import Foundation
import CoreFoundationLib
import UI

class SpainOneTransferHomeCoordinator: BindableCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    var dataBinding: DataBinding = DataBindingObject()
    
    func start() {
        guard let type: String = dataBinding.get() else { return }
        switch type {
        case "bizum": break
        default: ToastCoordinator().start()
        }
    }
}
