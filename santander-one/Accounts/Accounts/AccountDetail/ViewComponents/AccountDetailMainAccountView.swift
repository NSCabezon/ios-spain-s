//
//  AccountDetailMainAccount.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 12/02/2021.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountDetailMainAccountView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var switchButton: UIButton!
    
    weak var delegate: AccountDetailMainAccountViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func didTapOnMain(_ sender: Any) {
        self.switchButton.isSelected.toggle()
        self.delegate?.didTapSwitch()
    }
    
    func isEnabledSwitch() {
        if self.switchButton.isSelected == true {
            self.switchButton.isUserInteractionEnabled = false
        }
    }
}

private extension AccountDetailMainAccountView {
    func setupView() {
        self.titleLabel.textColor = .brownishGray
        self.titleLabel?.configureText(withKey: "pt_accountDetail_label_mainAccount",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
        self.view?.backgroundColor = .skyGray
        self.switchButton.setImage(Assets.image(named: "icnOnSwich"), for: .selected)
        self.switchButton.setImage(Assets.image(named: "icnOffSwich"), for: .normal)
        self.setAccessibilityIdentifiers()
        self.setAccessibilityLabels()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAccountDetail.titleMainView
        self.switchButton.accessibilityIdentifier = AccessibilityAccountDetail.switchMainButton
    }
    
    func setAccessibilityLabels() {
        self.switchButton.accessibilityTraits = .none
        if self.switchButton.isEnabled {
            self.switchButton.accessibilityLabel = localized(AccessibilityAccountDetail.selectedAsMainAccount)
        }
    }
}
