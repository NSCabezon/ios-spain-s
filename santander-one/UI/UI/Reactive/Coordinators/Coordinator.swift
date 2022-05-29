//
//  Coordinator.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 11/11/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public typealias BindableCoordinator = Coordinator & Bindable

public protocol Coordinator: AnyObject, UniqueIdentifiable {
    var identifier: String { get }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController? { get set }
    var onFinish: (() -> Void)? { get set }
    func start()
    func dismiss()
}

public extension Coordinator {
    var identifier: String {
        return String(describing: self)
    }
    
    var uniqueIdentifier: Int {
        return identifier.hashValue
    }
    
    var onFinish: (() -> Void)? {
        return nil
    }

    func append(child coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self = self, let coordinator = coordinator else { return }
            self.childCoordinators.remove(coordinator)
        }
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
        onFinish?()
    }
}

public extension Array where Element == Coordinator {
    
    mutating func remove(_ coordinator: Coordinator) {
        removeAll(where: { coordinator.identifier == $0.identifier })
    }
}
