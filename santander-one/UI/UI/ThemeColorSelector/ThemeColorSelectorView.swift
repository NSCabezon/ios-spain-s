//
//  ThemeColorSelectorView.swift
//  RetailClean
//
//  Created by Boris Chirino Fernandez on 17/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol ThemeColorSelectorViewDelegate: AnyObject {
    func didSelectButton(_ buttonType: ButtonType)
}

/// Component to select between 2 buttons mutually exclusives, used on PGSmart
public class ThemeColorSelectorView: UIView {

    public weak var themeSelectorDelegate: ThemeColorSelectorViewDelegate?
    private var currentSelectedButton: SpotImageView?

    @IBOutlet private weak var redButton: SpotImageView!
    @IBOutlet private weak var greyButton: SpotImageView!
    @IBOutlet weak var contentView: UIView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    internal func internalInit() {
        let nibName = String(describing: type(of: self))
        Bundle.module?.loadNibNamed(nibName, owner: self, options: nil)
        guard let content = contentView else { return }
        addSubview(content)
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupUI()
    }
    
    public func toggleButtonType(buttonType: ButtonType, toActive active: Bool) {
        switch buttonType {
        case .red:
            self.updateButton(redButton, toActive: active)
        case .black:
            self.updateButton(greyButton, toActive: active)
        }
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
    }
}

private extension ThemeColorSelectorView {
    func setupUI() {
        self.backgroundColor = UIColor.clear
        self.setRedButton()
        self.setGreyButton()
        self.setAccessibilityIdentifiers()
    }
    
    func setRedButton() {
        self.redButton.fillColor = UIColor.bostonRed
        self.redButton.buttonType = .red
        self.redButton.clipsToBounds = false
        self.redButton.layer.cornerRadius =  self.redButton.frame.size.width / 2
        self.redButton.didTap = { [weak self] (image, active) in
            self?.updateButton(image, toActive: active)
        }
    }
    
    func setGreyButton() {
        self.greyButton.fillColor = UIColor.lisboaGray
        self.greyButton.buttonType = .black
        self.greyButton.clipsToBounds = false
        self.greyButton.layer.cornerRadius =  self.redButton.frame.size.width / 2
        self.greyButton.didTap = { [weak self] (image, active) in
            self?.updateButton(image, toActive: active)
        }
    }
    
    func updateButton(_ button: SpotImageView, toActive: Bool) {
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
    
    func setAccessibilityIdentifiers() {
        self.redButton.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.themeColorSelectorRedBtn
        self.greyButton.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.themeColorSelectorGreyBtn
    }
}

extension ThemeColorSelectorView {
    public func getSelectedButtonType() -> ButtonType? {
        return self.currentSelectedButton?.buttonType
    }
}
