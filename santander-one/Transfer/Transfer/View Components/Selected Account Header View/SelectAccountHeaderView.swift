//
//  SelectAccountHeaderView.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 07/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

final class SelectedAccountHeaderView: UIView {
    
    private var view: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var accountAvailableAmountLabel: UILabel!
    @IBOutlet private weak var changeAccountButton: UIButton!
    @IBOutlet private weak var verticalSeparator: UIView!
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var bottomSeparator: UIView!
    
    private var viewModel: SelectedAccountHeaderViewModel?
    private var groupedAccessibilityElements: [Any]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setup(with viewModel: SelectedAccountHeaderViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = localized("transfer_label_originAccount")
        self.accountLabel.text = viewModel.alias
        self.accountAvailableAmountLabel.text = viewModel.currentBalanceAmount
    }
    
    private func setupView() {
        self.xibSetup()
        self.view.backgroundColor = .skyGray
        self.titleLabel.setSantanderTextFont(type: .bold, size: 12, color: .grafite)
        self.accountLabel.setSantanderTextFont(size: 15, color: .lisboaGray)
        self.accountAvailableAmountLabel.setSantanderTextFont(size: 15, color: .grafite)
        self.verticalSeparator.backgroundColor = .mediumSkyGray
        self.bottomSeparator.backgroundColor = .mediumSkyGray
        self.editImageView.image = Assets.image(named: "icnEdit")
        self.changeLabel.setSantanderTextFont(size: 10, color: .darkTorquoise)
        self.changeLabel.configureText(withKey: "generic_button_changeAccount", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.changeLabel.textAlignment = .center
        self.changeAccountButton.backgroundColor = .clear
        self.changeAccountButton.addTarget(self, action: #selector(changeAccountButtonSelected), for: .touchUpInside)
        self.setAccessibilityIdentifiers()
    }
    
    private func xibSetup() {
        self.view = self.loadViewFromNib()
        self.addSubview(self.view)
        self.view.fullFit()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    @objc private func changeAccountButtonSelected() {
        self.viewModel?.action()
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityTransfers.transferHeaderOriginAccount
        self.titleLabel.accessibilityIdentifier = AccessibilityTransfers.transferLabelOriginAccount
        self.titleLabel.accessibilityTraits = .header
        self.accountLabel.accessibilityIdentifier = AccessibilityTransfers.accountNumberLabel
        self.accountAvailableAmountLabel.accessibilityIdentifier = AccessibilityTransfers.availableAmountTitleLabel
        self.editImageView.accessibilityIdentifier = AccessibilityTransfers.icnEdit
        self.changeLabel.accessibilityIdentifier = AccessibilityTransfers.genericButtonChangeAccount
        self.changeAccountButton.accessibilityIdentifier = AccessibilityTransfers.btnChangeAccount.rawValue
        self.changeAccountButton.accessibilityLabel = localized(AccessibilityTransfers.genericButtonChangeAccount)
    }
}
