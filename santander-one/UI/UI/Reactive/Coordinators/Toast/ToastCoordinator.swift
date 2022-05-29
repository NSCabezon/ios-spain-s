//
//  ToastCoordinator.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 8/11/21.
//

import Foundation
import CoreFoundationLib

public final class ToastCoordinator: BindableCoordinator {
    
    public weak var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    public var dataBinding: DataBinding = DataBindingObject()
    private var text: String = ""
    
    public init(_ text: String = "") {
        self.text = text
    }
    
    public func start() {
        Toast.show(localized(text))
        Async.after(seconds: 1.0) {
            self.onFinish?()
        }
    }
}
