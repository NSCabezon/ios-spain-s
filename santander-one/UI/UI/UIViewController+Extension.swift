//
//  UIViewController+Extension.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 29/06/2020.
//

import UIKit

extension UIViewController {
    
    public func addChildViewController(_ viewController: UIViewController, on view: UIView) {
        self.addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewController.didMove(toParent: self)
    }
    
    public func removeChildViewController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.removeFromParent()
        child.view.removeFromSuperview()
    }
    
    public func setPopGestureEnabled(_ value: Bool) {
        guard
            let transitionCoordinator = transitionCoordinator,
            transitionCoordinator.isInteractive else {
                navigationController?.interactivePopGestureRecognizer?.isEnabled = value
                return
        }
        
        transitionCoordinator.notifyWhenInteractionChanges { [weak self] (context) in
            guard
                !context.isInteractive,
                !context.isCancelled
                else { return }
            self?.navigationController?.interactivePopGestureRecognizer?.isEnabled = value
        }
    }
    
    public func enablePopGestureRecognizer(_ enable: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = enable
    }
    
    public func disableEditing(force: Bool) {
        self.view.endEditing(force)
    }
}
