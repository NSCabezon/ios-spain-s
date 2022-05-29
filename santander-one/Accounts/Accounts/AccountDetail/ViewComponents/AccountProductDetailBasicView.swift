//
//  AccountProductDetailBasicView.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 10/02/2021.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountProductDetailBasicView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    private var titleAccessibilityID: String?
    private var valueAccessibilityID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(title: String, value: String, titleAccessibilityID: String? = nil, valueAccessibilityID: String? = nil) {
        self.titleLabel?.text = title
        self.valueLabel.text = value
        self.titleAccessibilityID = titleAccessibilityID
        self.valueAccessibilityID = valueAccessibilityID
        self.setAccessibilityIdentifiers()
    }
}

private extension AccountProductDetailBasicView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityAccountDetail.detailView
        self.titleLabel.accessibilityIdentifier = titleAccessibilityID != nil ? titleAccessibilityID : AccessibilityAccountDetail.titleDetail
        self.valueLabel.accessibilityIdentifier = valueAccessibilityID != nil ? valueAccessibilityID : AccessibilityAccountDetail.subtitleDetail
    }
}
