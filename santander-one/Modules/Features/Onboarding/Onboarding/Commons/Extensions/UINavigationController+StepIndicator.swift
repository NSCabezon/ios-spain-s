//
//  UINavigationController+StepIndicator.swift
//  Onboarding
//
//  Created by Jose Camallonga on 17/1/22.
//

import UIKit
import UI
import CoreFoundationLib

extension UINavigationController {
    public func addOnboardingStepIndicatorBar(currentPosition: Int, total: Int) {
        let textBar = UILabel()
        textBar.accessibilityIdentifier = "onboarding_label_steps"
        textBar.font = .santander(family: .text, type: .regular, size: 16)
        textBar.textColor = .lisboaGray
        let placeHolders = [StringPlaceholder(.number, "\(currentPosition)"),
                            StringPlaceholder(.number, "\(total)")]
        let localizedText = localized("onboarding_label_steps", placeHolders)
        textBar.configureText(withLocalizedString: localizedText)
        textBar.sizeToFit()
        let barItem = UIBarButtonItem(customView: textBar)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 18
        topViewController?.navigationItem.setLeftBarButtonItems([spacer, barItem], animated: false)
    }
}
