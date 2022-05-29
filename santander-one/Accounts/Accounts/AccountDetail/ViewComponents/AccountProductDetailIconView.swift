//
//  AccountProductDetailIconView.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 09/02/2021.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountProductDetailIconView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var shareImageView: UIImageView!
    
    weak var delegate: AccountProductDetailIconViewDelegate?
    private var titleAccessibilityID: String?
    private var valueAccessibilityID: String?
    private var iconAccessibilityID: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(title: String, value: String, titleAccessibilityID: String? = nil, valueAccessibilityID: String? = nil, iconAccessibilityID: String? = nil) {
        self.titleLabel?.text = title
        self.valueLabel.text = value
        self.titleAccessibilityID = titleAccessibilityID
        self.valueAccessibilityID = valueAccessibilityID
        self.iconAccessibilityID = iconAccessibilityID
        self.setAccessibilityIdentifiers()
    }
}

private extension AccountProductDetailIconView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
        self.shareImageView.image = Assets.image(named: "icnShareSlimGreen")
        self.imageShareTapped()
        self.setAccessbilityLabels()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAccountDetail.detailView
        self.titleLabel.accessibilityIdentifier = titleAccessibilityID != nil ? titleAccessibilityID : AccessibilityAccountDetail.titleDetail
        self.valueLabel.accessibilityIdentifier = valueAccessibilityID != nil ? valueAccessibilityID : AccessibilityAccountDetail.subtitleDetail
        self.shareImageView.accessibilityIdentifier = iconAccessibilityID != nil ? iconAccessibilityID : AccessibilityAccountDetail.shareIconDetail
    }
    
    func setAccessbilityLabels() {
        self.shareImageView.accessibilityLabel = localized(AccessibilityAccountDetail.buttonShare)
        self.shareImageView.accessibilityTraits = .button
    }
    
    func imageShareTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doShare(tapGestureRecognizer:)))
        self.shareImageView.isUserInteractionEnabled = true
        self.shareImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func doShare(tapGestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.didTapOnShare()
    }
}
