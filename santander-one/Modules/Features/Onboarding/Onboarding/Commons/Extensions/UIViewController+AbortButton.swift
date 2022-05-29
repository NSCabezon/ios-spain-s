//
//  UIViewController+AbortButton.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import UIKit
import UI
import CoreFoundationLib

extension UIViewController {
    func showOnboardingAbortButton(_ show: Bool, target: Any?, action: Selector?) {
        navigationController?.navigationBar.setClearBackground(flag: true)
        navigationItem.setHidesBackButton(true, animated: false)
        setPopGestureEnabled(false)
        
        guard show else {
            navigationItem.rightBarButtonItems = nil
            return
        }
        
        let button = UIBarButtonItem(title: localized("onboarding_link_notNow").text,
                                     style: .plain,
                                     target: target,
                                     action: action)
        button.tintColor = .darkTorquoise
        button.setTitleTextAttributes([.font: UIFont.santander(family: .text, type: .regular, size: 15)],
                                      for: .normal)
        button.setTitleTextAttributes([.font: UIFont.santander(family: .text, type: .regular, size: 15)],
                                      for: .highlighted)
        button.accessibilityIdentifier = "SideMenuButton"
        viewController.navigationItem.rightBarButtonItems = [button]
    }
    
    func onboardingAbortAction(response: @escaping (Bool, Bool) -> Void) {
        let onBoardingButtonsFont = UIFont.santander(family: .text, type: .regular, size: 14)
        ResumePopupView.presentPopup(title: localized("onboarding_alert_title_completeActivation"),
                                     description: localized("onboarding_alert_text_completeActivation"),
                                     confirmTitle: localized("onboarding_alert_button_useApp"),
                                     cancelTitle: localized("onboarding_alert_button_notPersonaliseApp"),
                                     font: onBoardingButtonsFont,
                                     hideCheckView: false,
                                     response: response)
    }
}
