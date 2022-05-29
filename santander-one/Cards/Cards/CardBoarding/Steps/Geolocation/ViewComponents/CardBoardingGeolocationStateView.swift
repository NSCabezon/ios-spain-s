//
//  CardBoardingGeolocationStateView.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 11/11/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol CardBoardingGeolocationStateDelegate: AnyObject {
    func didSelectSwitchButton()
}

class CardBoardingGeolocationStateView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet private weak var locationStateLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    @IBOutlet private weak var locationStateContainerView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    weak var delegate: CardBoardingGeolocationStateDelegate?
    private var isLocationEnabled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    @IBAction func switchButtonPressed(_ sender: Any) {
        self.delegate?.didSelectSwitchButton()
    }
    
    func setLocationState(_ isLocationEnabled: Bool) {
        self.isLocationEnabled = isLocationEnabled
        self.setLocationState()
    }
}

private extension CardBoardingGeolocationStateView {
    func setAppearance() {
        self.mapImageView.image = Assets.image(named: "imgMapOnboarding")
        self.setSubViews()
        self.locationStateLabel.font = .santander(family: .text, type: .regular, size: 17)
        self.setLocationState()
        self.setAccessibilityIdentifiers()
    }
    
    func setSubViews() {
        self.view?.backgroundColor = .clear
        self.locationStateContainerView.backgroundColor = .clear
        self.containerView.backgroundColor = .white
        self.containerView?.drawRoundedAndShadowedNew(radius: 6, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setAccessibilityIdentifiers() {
        self.mapImageView.accessibilityIdentifier = AccessibilityCardBoarding.Geolocation.mapImageView
        self.locationStateLabel.accessibilityIdentifier = AccessibilityCardBoarding.Geolocation.locationStateLabel
        self.switchButton.accessibilityIdentifier = AccessibilityCardBoarding.Geolocation.switchActivateLocation
    }
    
    func setLocationState() {
        if self.isLocationEnabled {
            self.locationStateLabel.text = localized("onboarding_label_enabled")
            self.switchButton.isOn = true
        } else {
            self.locationStateLabel.text = localized("onboarding_label_disabled")
            self.switchButton.isOn = false
        }
    }
}
