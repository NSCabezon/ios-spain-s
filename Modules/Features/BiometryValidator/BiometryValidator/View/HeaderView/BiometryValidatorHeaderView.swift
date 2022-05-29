//
//  EcommerceHeaderView.swift
//  Ecommerce
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol DidTapInHeaderButtonsDelegate: class {
    func didTapInMoreInfo()
    func didTapInDismiss()
}

public final class BiometryValidatorHeaderView: XibView {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var moreInfoButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var totalHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Attributes

    weak var delegate: DidTapInHeaderButtonsDelegate?
    
    // MARK: - Initializers

    public override func layoutSubviews() {
        self.contentView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapInMoreInfo(_ sender: Any) {
        delegate?.didTapInMoreInfo()
    }
    
    @IBAction func didTapInDismiss(_ sender: Any) {
        delegate?.didTapInDismiss()
    }
}

private extension BiometryValidatorHeaderView {
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
        self.titleLabel.textColor = .black
    }
    
    func setAccessibilityIds() {
        self.closeButton.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.closeButton
        self.moreInfoButton.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.moreInfoButton
        self.titleLabel.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.titleLabel
        self.topImageView.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.topImageView
        self.contentView.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.contentView
        self.accessibilityIdentifier = AccessibilityBiometryValidatorHeaderView.baseView
    }
}
