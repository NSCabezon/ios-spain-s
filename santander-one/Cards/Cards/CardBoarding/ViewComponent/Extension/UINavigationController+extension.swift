//
//  UINavigationController+extension.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/6/20.
//

import Foundation
import CoreFoundationLib
import UI
import Operative

extension UINavigationController {
    
    func addStepIndicatorBar(currentPosition: Int, total: Int) {
        let textBar = UILabel()
        textBar.accessibilityIdentifier = "onboarding_label_steps"
        textBar.font = .santander(family: .text, type: .light, size: 16)
        textBar.textColor = .lisboaGray
        let placeHolders = [StringPlaceholder(.number, "\(currentPosition)"),
                            StringPlaceholder(.number, "\(total)")]
        let localizedText = localized("onboarding_label_steps", placeHolders)
        textBar.configureText(withLocalizedString: localizedText)
        textBar.sizeToFit()
        let barItem = UIBarButtonItem(customView: textBar)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 24
        self.topViewController?.navigationItem.setLeftBarButtonItems([spacer, barItem], animated: false)
    }
    
    func addCloseButtonItem(target: Any?, selector: Selector?) {
        let buttonItem = UIBarButtonItem(image: Assets.image(named: "icnCloseGray"), style: .done, target: target, action: selector)
        buttonItem.tintColor = .gray
        buttonItem.accessibilityIdentifier = "icnCloseGrey"
        self.topViewController?.navigationItem.setRightBarButtonItems([buttonItem], animated: false)
    }
    
    func dismissCardboarding() {
        self.enablePopGesture()
        let lasController = self.viewControllers.last(where: {
            !($0 is CardBoardingStepView)
            && !($0 is CardBoardingWelcomeViewController)
            && !($0 is  CardBoardingCardsSelectorViewController)
        })
        guard let viewController = lasController else {
            self.popViewController(animated: true)
            return
        }
        self.popToViewController(viewController, animated: true)
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        self.enablePopGesture()
        self.popToRootViewController(animated: animated)
        guard let transition = self.transitionCoordinator else {
            completion()
            return
        }
        transition.animate(alongsideTransition: nil) { _ in
            completion()
        }
    }
    
    func dismissOperative() {
        guard let transition = self.transitionCoordinator else { return }
        transition.animate(alongsideTransition: nil) { [weak self] _ in
            let viewControllerArray = self?.viewControllers.filter({ !($0 is OperativeView) }) ?? []
            guard !viewControllerArray.isEmpty else { return }
            self?.viewControllers = viewControllerArray
        }
    }
    
    func enablePopGesture() {
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func disablePopGesture() {
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}
