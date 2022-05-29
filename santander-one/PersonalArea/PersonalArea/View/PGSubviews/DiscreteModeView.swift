//
//  DiscreteModeView.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 27/11/2019.
//

import Foundation
import CoreFoundationLib
import UI

protocol OfferViewDelegate: AnyObject {
    func offerViewDidPressed()
}

class DiscreteModeView: DesignableView {
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subTitleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var switchLabel: UILabel?
    @IBOutlet private weak var discreteSwitch: UISwitch?
    @IBOutlet private weak var offerImageView: UIImageView?
    @IBOutlet private weak var playImageView: UIImageView?
    @IBOutlet private weak var offerView: UIView?
    @IBOutlet private var separationViews: [UIView]?
    weak var offerViewDelegate: OfferViewDelegate?
    
    override func internalInit() {
        super.internalInit()
        self.commonInit()
    }
    
    func setDelegate(_ delegate: OfferViewDelegate?) {
        self.offerViewDelegate = delegate
    }
    
    func setSwitchIsOn(_ isOn: Bool) {
        self.discreteSwitch?.isOn = isOn
    }
    
    func getSwitchIsOn() -> Bool {
        return self.discreteSwitch?.isOn ?? false
    }
    
    func offerViewIsHidden(_ isHidden: Bool) {
        self.offerView?.isHidden = isHidden
    }
    
    func setOffer() {
        
    }
}

private extension DiscreteModeView {
    func commonInit() {
        self.configureLabels()
        self.configureViews()
        self.setAccessibilityIdentifiers()
    }
    
    func configureLabels() {
        self.setTitleLabel()
        self.setSubTitleLabel()
        self.setDescriptionLabel()
        self.setSwitchLabel()
    }
    
    func setTitleLabel() {
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: "displayOptions_title_seeOrder",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0),
                                                                                            alignment: .left))
    }
    
    func setSubTitleLabel() {
        self.subTitleLabel?.textColor = .lisboaGray
        self.subTitleLabel?.configureText(withKey: "pgCustomize_label_discreetModule",
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14),
                                                                                               alignment: .left,
                                                                                               lineHeightMultiple: 0.8))
    }
    
    func setDescriptionLabel() {
        self.descriptionLabel?.textColor = .lisboaGray
        self.descriptionLabel?.textAlignment = .left
        self.descriptionLabel?.configureText(withKey: "pgCustomize_text_discreetModule",
                                             andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 14),
                                                                                                  alignment: .left,
                                                                                                  lineHeightMultiple: 0.82))
    }
    
    func setSwitchLabel() {
        self.switchLabel?.textColor = .lisboaGray
        self.switchLabel?.configureText(withKey: "pgCustomize_text_activateDiscreetModule",
                                        andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                             alignment: .left))
    }
    
    func configureViews() {
        self.backgroundColor = .white
        self.offerImageView?.image = Assets.image(named: "imgVideo")
        self.offerImageView?.contentMode = .scaleAspectFill
        self.playImageView?.image = Assets.image(named: "icnPlay")
        let tap = UITapGestureRecognizer(target: self, action: #selector(offerViewDidPressed))
        self.offerView?.addGestureRecognizer(tap)
        self.offerView?.isHidden = true
        self.separationViews?.forEach { $0.backgroundColor = .mediumSkyGray }
    }
    
    @objc func offerViewDidPressed() {
        self.offerViewDelegate?.offerViewDidPressed()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeTitle
        self.subTitleLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeSubTitle
        self.descriptionLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeDescription
        self.switchLabel?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeSwitchLabel
        self.discreteSwitch?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeSwitch
        self.offerImageView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeOfferImage
        self.playImageView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModePlayImage
        self.offerView?.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.discreteModeOfferView
    }
}
