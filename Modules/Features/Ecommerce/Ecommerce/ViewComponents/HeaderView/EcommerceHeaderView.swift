//
//  EcommerceHeaderView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public protocol DidTapInHeaderButtonsDelegate: class {
    func didTapInMoreInfo()
    func didTapInDismiss()
}

public final class EcommerceHeaderView: XibView {
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var moreInfoButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var totalHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageWidth: NSLayoutConstraint!
    
    weak var delegate: DidTapInHeaderButtonsDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func layoutSubviews() {
        self.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    func hideMoreInfoButton(_ hide: Bool) {
        self.moreInfoButton.isHidden = hide
    }
    
    func configView(_ headerHeight: EcommerceHeaderHeight) {
        switch headerHeight {
        case .big:
            self.stackViewHeight.constant = 130
            self.imageHeight.constant = 56
            self.imageWidth.constant = 35
        case .small:
            self.stackViewHeight.constant = 98
            self.imageHeight.constant = 39
            self.imageWidth.constant = 24
        }
    }
    
    func setPadlockSize(width: CGFloat, height: CGFloat) {
        topImageWidthConstraint.constant = width
        topImageHeightConstraint.constant = height
    }
    
    func setTitleFontSize(_ fontSize: CGFloat) {
        setTitle(fontSize)
    }
    
    func setTotalHeight(_ height: CGFloat) {
        totalHeightConstraint.constant = height
    }
    
    @IBAction func didTapInMoreInfo(_ sender: Any) {
        delegate?.didTapInMoreInfo()
    }
    
    @IBAction func didTapInDismiss(_ sender: Any) {
        delegate?.didTapInDismiss()
    }
}

private extension EcommerceHeaderView {
    func setupView() {
        self.setView()
        self.setMoreInfoButton()
        self.setDismissButton()
        self.setImage()
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setView() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .skyGray
        self.drawShadow(offset: (x: 0, y: -5), opacity: 0.1, color: .black, radius: 4)
    }
    
    func setMoreInfoButton() {
        self.moreInfoButton.setTitle(localized("ganeric_label_knowMore"), for: .normal)
        self.moreInfoButton.setTitleColor(.darkTorquoise, for: .normal)
        self.moreInfoButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 14)
        self.moreInfoButton.titleLabel?.numberOfLines = 2
    }
    
    func setDismissButton() {
        self.closeButton.setImage(Assets.image(named: "icnCloseGray")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func setImage() {
        self.topImageView.image = Assets.image(named: "icnBigSantanderLock")
    }
    
    func setTitle(_ fontSize: CGFloat = 20.0) {
        let font = UIFont.santander(family: .text, type: .regular, size: fontSize)
        let localizedConfiguration = LocalizedStylableTextConfiguration(font: font, alignment: .center, lineHeightMultiple: 0.8, lineBreakMode: .none)
        self.titleLabel.configureText(withKey: "ecommerce_label_SantanderKey", andConfiguration: localizedConfiguration)
        self.titleLabel.numberOfLines = 2
        self.titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setAccessibilityIds() {
        self.closeButton.accessibilityIdentifier = AccessibilityEcommerceHeaderView.closeButton
        self.moreInfoButton.accessibilityIdentifier = AccessibilityEcommerceHeaderView.moreInfoButton
        self.titleLabel.accessibilityIdentifier = AccessibilityEcommerceHeaderView.titleLabel
        self.topImageView.accessibilityIdentifier = AccessibilityEcommerceHeaderView.topImageView
        self.contentView.accessibilityIdentifier = AccessibilityEcommerceHeaderView.contentView
        self.accessibilityIdentifier = AccessibilityEcommerceHeaderView.baseView
    }
}
