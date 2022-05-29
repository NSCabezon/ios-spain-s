//
//  UINavigationController.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 11/09/2019.
//

import Foundation

extension UINavigationController {
    
    func pushWithTransition(viewController: UIViewController) {
        self.view.layer.add(fromBottomTransition(), forKey: nil)
        self.pushViewController(viewController, animated: false)
    }
    
    func popWithTransition() {
        self.view.layer.add(fromTopTransition(), forKey: nil)
        self.popViewController(animated: false)
    }
    
    func fromBottomTransition() -> CATransition {
        let transition = getTransition()
        transition.subtype = .fromTop
        return transition
    }
    
    func fromTopTransition() -> CATransition {
        let transition = getTransition()
        transition.subtype = .fromBottom
        return transition
    }
    
    func transition(_ subType: CATransitionSubtype) {
        let transition = getTransition()
        transition.subtype = subType
        view.layer.add(transition, forKey: nil)
    }
    
    func setViewControllersWithTransition(viewControllers: [UIViewController]) {
        self.view.layer.add(fromBottomTransition(), forKey: nil)
        setViewControllers(viewControllers, animated: true)
    }
    
    private func getTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        return transition
    }
    
}
