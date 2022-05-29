//
//  QuickBalanceMovementView.swift
//  Login
//
//  Created by Iván Estévez on 03/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol QuickBalanceNotActivatedViewDelegate: AnyObject {
    func didTapActivateButton()
    func didTapImageView()
}

final class QuickBalanceNotActivatedView: XibView {

    @IBOutlet private weak var sectionView: QuickBalanceSectionView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var playImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var enterButton: RedLisboaButton!
    
    weak var delegate: QuickBalanceNotActivatedViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setAccessibility()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setAccessibility()
    }

    func setImage(_ image: UIImage?) {
        guard let image = image else { return }
        imageView.image = image
        imageView.isHidden = false
        playImageView.isHidden = false
    }
}

private extension QuickBalanceNotActivatedView {
    func setupView() {
        playImageView.image = Assets.image(named: "icnPlay")
        sectionView.setTitle(localized("quickBalance_text_what"))
        descriptionLabel.text = localized("quickBalance_text_newfunctionality")
        descriptionLabel.font = .santander(family: .text, type: .regular, size: 14)
        descriptionLabel.textColor = .lisboaGray
        enterButton.setTitle(localized("quickBalance_button_activate"), for: .normal)
        enterButton.backgroundPressedColor = .redGraphic
        enterButton.addAction { [weak self] in
            self?.delegate?.didTapActivateButton()
        }
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
    }
    
    func setAccessibility() {
        enterButton?.accessibilityIdentifier = AccessibilityQuickBalance.btnActivate.rawValue
        enterButton?.titleLabel?.accessibilityIdentifier = AccessibilityQuickBalance.btnActivateLabel.rawValue
        descriptionLabel?.accessibilityIdentifier = AccessibilityQuickBalance.descriptionLabel.rawValue
        playImageView?.accessibilityIdentifier = AccessibilityQuickBalance.playImageView.rawValue
        imageView?.accessibilityIdentifier = AccessibilityQuickBalance.imageView.rawValue
        sectionView?.accessibilityIdentifier = AccessibilityQuickBalance.sectionView.rawValue
    }

    @objc func didTapImageView() {
        delegate?.didTapImageView()
    }
}
