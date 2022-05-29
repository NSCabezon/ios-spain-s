//
//  FinanceableEmptyView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 25/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class FinanceableEmptyView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setDescriptionLabelHidden() {
        descriptionLabel.isHidden = true
    }
}

private extension FinanceableEmptyView {
    func setAppearance() {
        setTitleLabel()
        setDescriptionLabel()
        setViews()
        setAccessibilityIdentifiers()
    }
    
    func setTitleLabel() {
        titleLabel.textColor = .lisboaGray
        titleLabel.configureText(withKey: "financing_label_emptyNotNextBill",
                                      andConfiguration: LocalizedStylableTextConfiguration(
                                        font: .santander(family: .micro, type: .regular, size: 16)))
    }
    
    func setDescriptionLabel() {
        descriptionLabel.textColor = .lisboaGray
        descriptionLabel.configureText(withKey: "financing_text_emptyCards",
                                       andConfiguration: LocalizedStylableTextConfiguration(
                                                font: .santander(family: .text, type: .regular, size: 14),
                                                lineHeightMultiple: 0.75))
    }
    
    func setViews() {
        backgroundImageView.setLeavesLoader()
        backgroundImageView.contentMode = .scaleAspectFill
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AccessibilityFinancingEmptyView.title
        descriptionLabel.accessibilityIdentifier = AccessibilityFinancingEmptyView.description
        backgroundImageView.accessibilityIdentifier = AccessibilityFinancingEmptyView.background
    }
}
