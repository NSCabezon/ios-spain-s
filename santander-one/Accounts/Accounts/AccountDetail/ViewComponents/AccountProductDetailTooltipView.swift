//
//  AccountProductDetailTooltipView.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 15/02/2021.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountProductDetailTooltipView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var tooltipButton: UIButton!
    private var tooltipText: String?
    private var titleAccessibilityID: String?
    private var valueAccessibilityID: String?
    private var tooltipAccesibilityID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView(title: String, value: String, tooltipText: String, titleAccessibilityID: String? = nil, valueAccessibilityID: String? = nil, tooltipAccesibilityID: String? = nil) {
        self.titleLabel?.text = title
        self.valueLabel.text = value
        self.tooltipText = tooltipText
        self.titleAccessibilityID = titleAccessibilityID
        self.valueAccessibilityID = valueAccessibilityID
        self.tooltipAccesibilityID = tooltipAccesibilityID
        self.setAccessibilityIdentifiers()
    }
}

private extension AccountProductDetailTooltipView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
        self.tooltipButton.setImage(Assets.image(named: "icnInfoRedLight")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.tooltipButton.isAccessibilityElement = true
        self.setAccessibilityLabels()
    }
    
    @IBAction func didTapOnTooltip(_ sender: UIButton) {
        let styledText: LocalizedStylableText = localized(self.tooltipText ?? "")
        BubbleLabelView.startWith(associated: sender, text: styledText.text, position: .bottom)
    }

    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAccountDetail.detailView
        self.titleLabel.accessibilityIdentifier = titleAccessibilityID != nil ? titleAccessibilityID : AccessibilityAccountDetail.titleDetail
        self.valueLabel.accessibilityIdentifier = valueAccessibilityID != nil ? valueAccessibilityID : AccessibilityAccountDetail.subtitleDetail
        self.tooltipButton.accessibilityIdentifier = tooltipAccesibilityID != nil ? tooltipAccesibilityID : AccessibilityAccountDetail.tooltipButton
    }
    
    func setAccessibilityLabels() {
        self.tooltipButton.accessibilityLabel = localized(AccessibilityAccountsHome.tooltipButton)
    }
}
