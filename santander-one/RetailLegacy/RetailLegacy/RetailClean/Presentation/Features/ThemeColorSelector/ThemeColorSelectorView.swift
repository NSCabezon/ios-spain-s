//
//  ThemeColorSelectorView.swift
//  RetailClean
//
//  Created by Boris Chirino Fernandez on 17/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UI
import CoreFoundationLib

protocol ThemeColorSelectorViewDelegate: class {
    func didSelectButton(_ buttonType: ButtonType)
}

/// Component to select between 2 buttons mutually exclusives, used on PGSmart
class ThemeColorSelectorView: DesignableView {

    weak var themeSelectorDelegate: ThemeColorSelectorViewDelegate?
    private var currentSelectedButton: SpotImageView?

    @IBOutlet weak var redButton: SpotImageView!
    @IBOutlet weak var greyButton: SpotImageView!
    
    override func commonInit() {
        super.commonInit()
        setupUI()
    }
    
    func toggleButtonType(buttonType: ButtonType, toActive active: Bool) {
        switch buttonType {
        case .red:
            self.updateButton(redButton, toActive: active)
        case .black:
            self.updateButton(greyButton, toActive: active)
        }
    }
    
    private func updateButton(_ button: SpotImageView, toActive: Bool) {
        guard button != self.currentSelectedButton else { return }
        if toActive == true {
            self.currentSelectedButton?.isActive = false
            button.isActive = true
            self.currentSelectedButton = button
            self.themeSelectorDelegate?.didSelectButton(button.buttonType)
        } else {
            self.currentSelectedButton?.isActive = false
            button.isActive = false
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
}

private extension ThemeColorSelectorView {
    func setupUI() {
        self.backgroundColor = UIColor.clear
        self.redButton.fillColor = UIColor.bostonRed
        self.redButton.buttonType = .red
        self.redButton.clipsToBounds = false
        self.redButton.layer.cornerRadius =  self.redButton.frame.size.width / 2
        self.redButton.accessibilityIdentifier = AccesibilityPresentation.onboardingBtnSelectColor1
        self.redButton.setAccesibilityIdentifiers(AccesibilityPresentation.onboardingBtnSelectColor1)
        self.redButton.didTap = { [weak self] (v, active) in
            self?.updateButton(v, toActive: active)
        }
        self.greyButton.fillColor = UIColor.lisboaGrayNew
        self.greyButton.buttonType = .black
        self.greyButton.clipsToBounds = false
        self.greyButton.layer.cornerRadius =  self.redButton.frame.size.width / 2
        self.greyButton.accessibilityIdentifier = AccesibilityPresentation.onboardingBtnSelectColor2
        self.greyButton.setAccesibilityIdentifiers(AccesibilityPresentation.onboardingBtnSelectColor2)
        self.greyButton.didTap = { [weak self] (v, active) in
            self?.updateButton(v, toActive: active)
        }
    }
}

extension ThemeColorSelectorView {
    func getSelectedButtonType() -> ButtonType? {
        return self.currentSelectedButton?.buttonType
    }
}
