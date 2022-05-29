//
//  BankDetailProductsConfigFooterView.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 14/7/21.
//

import CoreFoundationLib
import UI

protocol BankDetailProductsConfigFooterDelegate: AnyObject {
    func didPressRecoveryKeys()
    func didPressRemoveConnection()
}

final class BankDetailProductsConfigFooterView: XibView {
    @IBOutlet private weak var recoveryImageView: UIImageView!
    @IBOutlet private weak var recoveryLabel: UILabel!
    @IBOutlet private weak var removeConnectionImageView: UIImageView!
    @IBOutlet private weak var removeConnectionLabel: UILabel!
    weak var delegate: BankDetailProductsConfigFooterDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction private func didPressRecoveryKeysButton(_ sender: Any) {
        self.delegate?.didPressRecoveryKeys()
    }
    @IBAction private func didPressRemoveConnectionButton(_ sender: Any) {
        self.delegate?.didPressRemoveConnection()
    }
}

private extension BankDetailProductsConfigFooterView {
    func setupView() {
        self.setRecoveryStackView()
        self.setRemoveConnectionStackView()
        self.setAccessibilityIdentifiers()
    }
    
    func setRecoveryStackView() {
        self.recoveryLabel.font = .santander(family: .micro, type: .regular, size: 14)
        self.recoveryLabel.textColor = .darkTorquoise
        self.recoveryLabel.text = localized("analysis_button_updateAccessKeys")
        self.recoveryImageView.image = Assets.image(named: "icnRecoverKeyGreen")
    }
    
    func setRemoveConnectionStackView() {
        self.removeConnectionLabel.font = .santander(family: .micro, type: .regular, size: 14)
        self.removeConnectionLabel.textColor = .darkTorquoise
        self.removeConnectionLabel.text = localized("analysis_button_removeConnection")
        self.removeConnectionImageView.image = Assets.image(named: "icnRemoveGreen")
    }
    
    func setAccessibilityIdentifiers() {
        self.recoveryLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.accessKeyUpdateLabel
        self.recoveryImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.lockerImage
        self.removeConnectionLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.deleteConnectionLabel
        self.removeConnectionImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisBankConfigDetail.trashCanImage
    }
}
