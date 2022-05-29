//
//  SKHeaderView.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 2/2/22.
//

import UIKit
import UI
import CoreFoundationLib
import OpenCombine
import ESUI

public enum SKHeaderHeight {
    case big
    case small
}

public final class SKHeaderView: XibView {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var moreInfoButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageWidth: NSLayoutConstraint!
    let didTapInMoreInfo = PassthroughSubject<Void, Never>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func hideMoreInfoButton(_ hide: Bool) {
        self.moreInfoButton.isHidden = hide
    }
    
    func configView(_ headerHeight: SKHeaderHeight) {
        switch headerHeight {
        case .big:
            self.imageHeight.constant = 40
            self.imageWidth.constant = 40
        case .small:
            self.imageHeight.constant = 24
            self.imageWidth.constant = 24
        }
    }
    
    func setTitleFontSize(_ fontSize: CGFloat) {
        setTitle(fontSize)
    }
    
    @IBAction func didTapInMoreInfo(_ sender: Any) {
        didTapInMoreInfo.send()
    }
}

private extension SKHeaderView {
    func setupView() {
        self.setView()
        self.setMoreInfoButton()
        self.setImageHeader()
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setView() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
    }
    
    func setMoreInfoButton() {
        self.moreInfoButton.setTitle(localized("ganeric_label_knowMore"), for: .normal)
        self.moreInfoButton.setTitleColor(.darkTorquoise, for: .normal)
        self.moreInfoButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 14)
        self.moreInfoButton.titleLabel?.numberOfLines = 1
    }
    
    func setImageHeader() {
        self.imageView.image = ESAssets.image(named: "IcnSanKeyLock")
    }
    
    func setTitle(_ fontSize: CGFloat = 18.0) {
        let font = UIFont.santander(family: .text, type: .regular, size: fontSize)
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: font, alignment: .left)
        self.titleLabel.configureText(withKey: "santanderKey_label_santanderKey", andConfiguration: localizedConfiguration)
        self.titleLabel.numberOfLines = 1
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setAccessibilityIds() {
        self.moreInfoButton.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.SkHeaderView.knowMoreButton
        self.titleLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.SkHeaderView.titleLabel
        self.imageView.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.SkHeaderView.imageView
    }
}
