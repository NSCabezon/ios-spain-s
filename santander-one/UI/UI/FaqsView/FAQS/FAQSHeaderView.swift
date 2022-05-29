//
//  FAQSHeaderView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib

final class FAQSHeaderView: XibView {
    @IBOutlet private var headerView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.setAccessibilityIdentifiers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
        self.setAccessibilityIdentifiers()
    }
    
    func setup() {
        self.titleLabel?.textColor = UIColor.white
        self.titleLabel.configureText(withKey: "helpCenter_title_faqs", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 20.0)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addGradientLayer()
    }
}

private extension FAQSHeaderView {
    func addGradientLayer() {
        self.headerView.applyGradientBackground(colors: [.darkTorquoise, .lightNavy])
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = FAQSHeaderViewComponent.viewLabelAnyQuestion
    }
}
