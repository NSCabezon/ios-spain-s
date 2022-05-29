//
//  QuickBalanceHeaderView.swift
//  Login
//
//  Created by Iván Estévez on 02/04/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol QuickBalanceHeaderViewDelegate: AnyObject {
    func didTapReloadButton()
}

final class QuickBalanceHeaderView: XibView {

    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var updatedDateLabel: UILabel!
    @IBOutlet private weak var reloadButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    weak var delegate: QuickBalanceHeaderViewDelegate?
    
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
    
    func setDefaultStatus() {
        titleLabel.text = localized("quickBalance_title_quickBalance")
        balanceLabel.attributedText = NSAttributedString(string: "")
        updatedDateLabel.text = ""
        reloadButton.isHidden = true
    }
    
    func setViewModel(_ viewModel: QuickBalanceHeaderViewModel) {
        reloadButton.isHidden = viewModel.updatedDate.isEmpty
        titleLabel.text = viewModel.title
        balanceLabel.attributedText = viewModel.amountAttributedString
        updatedDateLabel.text = viewModel.updatedDate
    }
    
    @IBAction private func reloadAction(_ sender: UIButton) {
        delegate?.didTapReloadButton()
    }
}

private extension QuickBalanceHeaderView {
    func setupView() {
        logoImageView.image = Assets.image(named: "icnSantanderBalance")
        separatorView.backgroundColor = .mediumSkyGray
        titleLabel.font = .santander(family: .text, type: .regular, size: 26)
        titleLabel.textColor = .black
        balanceLabel.font = .santander(family: .text, type: .bold, size: 26)
        balanceLabel.textColor = .black
        updatedDateLabel.font = .santander(family: .text, type: .regular, size: 12)
        updatedDateLabel.textColor = .lisboaGray
        reloadButton.setBackgroundImage(Assets.image(named: "icnUpdate"), for: .normal)
    }
    
    func setAccessibility() {
        logoImageView?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.logoImageView.rawValue
        titleLabel?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.balanceTitleLabel.rawValue
        balanceLabel?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.balanceLabel.rawValue
        updatedDateLabel?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.updatedDateLabel.rawValue
        reloadButton?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.reloadButton.rawValue
        reloadButton?.titleLabel?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.reloadButtonLabel.rawValue
        separatorView?.accessibilityIdentifier = AccessibilityQuickBalanceHeader.separatorView.rawValue
    }
}
